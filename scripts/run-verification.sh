#!/bin/bash
#
# Portable Lattice verification runner.
#
# Usage:
#   .lattice/scripts/run-verification.sh .lattice/verification.yaml
#
# This script intentionally supports a small Lattice-owned YAML subset, not
# arbitrary YAML:
#
#   version: 1
#   runsDir: tmp/verification        # optional
#   failureHint: >                   # optional folded block, copied to summary
#     Plain-language hint for agents.
#   stages:
#     - name: unit
#       command: dotnet test ...
#     - name: integration
#       command: make integration
#
# Stages within one run always execute sequentially, and verification always
# stops after the first failed stage. Every executed stage writes a full log
# file; stdout carries only marker lines and ids, never log content. The
# script writes a mechanical summary.json — status, exit code, and logFile
# path per stage, plus a run-level overallStatus/failedStages/headline
# verdict — that is the complete, final answer. Nothing downstream (agent or
# human) recomputes it; they only read it, on stdout or off disk.
#
# Multiple runs (e.g. several verifier subagents) may invoke this script
# concurrently: each run gets its own directory via a collision-checked
# mkdir, retried on collision rather than silently sharing a directory, and
# a run is never pruned while younger than a fixed grace period — even by
# its own end-of-run cleanup — so a sibling run's cleanup can never delete a
# just-finished run before its caller reads summary.json.

set -u

RUN_DIR_NAME_PATTERN='[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]Z-[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]'
PRUNE_GRACE_MINUTES=5
MAX_RUN_DIR_ATTEMPTS=20

script_error() {
  echo "___VERIFICATION_SCRIPT_ERROR___:$1"
  exit 2
}

# ---------------------------------------------------------------------------
# String helpers
# ---------------------------------------------------------------------------

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

strip_optional_quotes() {
  local s="$1"
  if [ "${#s}" -ge 2 ]; then
    case "$s" in
      \"*\") s="${s#\"}"; s="${s%\"}" ;;
      \'*\') s="${s#\'}"; s="${s%\'}" ;;
    esac
  fi
  printf '%s' "$s"
}

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

# ---------------------------------------------------------------------------
# Config parsing — populates: version, runs_dir, failure_hint, stage_names[],
# stage_commands[]
# ---------------------------------------------------------------------------

append_stage() {
  if [ -n "$current_name" ] || [ -n "$current_command" ]; then
    [ -n "$current_name" ] || script_error "stage $(( ${#stage_names[@]} + 1 )) is missing required key: name"
    [ -n "$current_command" ] || script_error "stage \"$current_name\" is missing required key: command"
    case "$current_name" in
      */*|*\\*) script_error "stage name \"$current_name\" must not contain '/' or '\\' because it is used as a log filename" ;;
      *[!A-Za-z0-9_.-]*) script_error "stage name \"$current_name\" must contain only letters, numbers, '.', '_' or '-'" ;;
    esac
    stage_names+=("$current_name")
    stage_commands+=("$current_command")
    current_name=""
    current_command=""
  fi
}

parse_key_value() {
  local line="$1"
  local key="$2"
  local value
  value="$(trim "${line#*:}")"
  value="$(strip_optional_quotes "$value")"
  case "$key" in
    version) version="$value" ;;
    runsDir) runs_dir="$value" ;;
    name) current_name="$value" ;;
    command) current_command="$value" ;;
    failureHint)
      if [ "$value" = ">" ] || [ "$value" = "|-" ] || [ "$value" = "|" ]; then
        in_failure_hint=true
        failure_hint=""
      else
        failure_hint="$value"
      fi
      ;;
  esac
}

parse_failure_hint_continuation() {
  local line="$1"
  case "$line" in
    " "*|$'\t'*)
      local hint_line
      hint_line="$(trim "$line")"
      if [ -n "$failure_hint" ]; then
        failure_hint="$failure_hint $hint_line"
      else
        failure_hint="$hint_line"
      fi
      return 0
      ;;
    *)
      in_failure_hint=false
      return 1
      ;;
  esac
}

parse_config_line() {
  local line="$1"
  local trimmed="$2"

  case "$line" in
    [![:space:]]*:*)
      local key
      key="$(trim "${line%%:*}")"
      case "$key" in
        version|runsDir|failureHint) parse_key_value "$line" "$key" ;;
        stages)
          seen_stages=true
          append_stage
          ;;
        *) script_error "unsupported top-level key: $key" ;;
      esac
      ;;
    "  - "*|"- "*)
      seen_stages=true
      append_stage
      local item
      item="$(trim "${line#*- }")"
      [ -z "$item" ] && return 0
      case "$item" in
        name:*) parse_key_value "$item" name ;;
        command:*) parse_key_value "$item" command ;;
        *) script_error "unsupported stage item: $item" ;;
      esac
      ;;
    "    "*|$'\t'*)
      [ "$seen_stages" = true ] || script_error "indented key found before stages"
      local stage_line
      stage_line="$(trim "$line")"
      case "$stage_line" in
        name:*) parse_key_value "$stage_line" name ;;
        command:*) parse_key_value "$stage_line" command ;;
        failureHint:*) script_error "unsupported stage key: failureHint; failureHint is top-level only and applies to all stages" ;;
        workingDirectory:*|timeoutSeconds:*) script_error "unsupported stage key: ${stage_line%%:*}; fold it into command instead" ;;
        *) script_error "unsupported stage key: ${stage_line%%:*}" ;;
      esac
      ;;
    *) script_error "unsupported YAML shape near: $trimmed" ;;
  esac
}

parse_config() {
  local config_file="$1"
  local raw_line line trimmed

  while IFS= read -r raw_line || [ -n "$raw_line" ]; do
    line="${raw_line%$'\r'}"
    trimmed="$(trim "$line")"

    if [ "$in_failure_hint" = true ] && parse_failure_hint_continuation "$line"; then
      continue
    fi

    [ -z "$trimmed" ] && continue
    case "$trimmed" in \#*) continue ;; esac

    parse_config_line "$line" "$trimmed"
  done < "$config_file"

  append_stage

  [ "$version" = "1" ] || script_error "expected version: 1"
  [ -n "$runs_dir" ] || script_error "runsDir must not be empty"
  [ "${#stage_names[@]}" -gt 0 ] || script_error "stages must contain at least one stage"
}

# ---------------------------------------------------------------------------
# Run directory lifecycle
# ---------------------------------------------------------------------------

# Concurrent invocations can land in the same wall-clock second, and bash's
# $RANDOM is seeded per-process from time+pid — sibling processes forked in
# the same instant can draw near-identical sequences, not independent ones.
# A plain `mkdir` (not `-p`) is the actual collision guard: it fails if the
# leaf already exists, so a same-run_id race is detected and retried instead
# of two runs silently sharing one directory and clobbering each other's log
# and summary.json. Sets run_id and run_dir on success.
claim_run_dir() {
  local attempt=0 candidate_id candidate_dir

  while :; do
    attempt=$((attempt + 1))
    candidate_id="$(date -u +%Y%m%dT%H%M%SZ)-$(printf '%03x%03x' $((RANDOM % 4096)) $((RANDOM % 4096)))"
    candidate_dir="$runs_dir/$candidate_id"
    if mkdir "$candidate_dir" 2>/dev/null; then
      run_id="$candidate_id"
      run_dir="$candidate_dir"
      return
    fi
    [ "$attempt" -ge "$MAX_RUN_DIR_ATTEMPTS" ] && \
      script_error "failed to create a unique run directory under $runs_dir after $attempt attempts"
  done
}

is_valid_run_dir_name() {
  case "$1" in
    $RUN_DIR_NAME_PATTERN) return 0 ;;
    *) return 1 ;;
  esac
}

# True if $1 is younger than PRUNE_GRACE_MINUTES — a sibling run that either
# hasn't finished or whose caller hasn't read summary.json yet.
is_within_prune_grace_period() {
  [ -n "$(find "$runs_dir" -mindepth 1 -maxdepth 1 -type d -name "$1" -mmin "-$PRUNE_GRACE_MINUTES" 2>/dev/null)" ]
}

prune_old_runs() {
  local keep="${VERIFICATION_KEEP_RUNS:-20}"
  case "$keep" in ''|*[!0-9]*) return 0 ;; esac
  [ "$keep" -le 0 ] && return 0
  [ -d "$runs_dir" ] || return 0

  local n=0 d
  while IFS= read -r d; do
    is_valid_run_dir_name "$d" || continue
    # Never prune this invocation's own run, or any run still inside the
    # grace period — same-second timestamps sort by an unrelated hex suffix,
    # so "newest N" can otherwise rank a just-written run outside the keep
    # window before its caller ever reads it.
    [ "$d" = "$run_id" ] && continue
    is_within_prune_grace_period "$d" && continue
    n=$((n + 1))
    if [ "$n" -gt "$keep" ]; then
      rm -rf "${runs_dir:?}/$d"
    fi
  done <<EOF
$(ls -1 "$runs_dir" 2>/dev/null | sort -r)
EOF
}

# ---------------------------------------------------------------------------
# Stage execution — populates: stage_json[], failed, failed_stage_name,
# failed_exit_code
# ---------------------------------------------------------------------------

stage_json_entry() {
  local name="$1" status="$2" exit_code="$3" duration="$4" wall_start="$5" wall_end="$6" command="$7" log="$8"
  printf '{"name":"%s","status":"%s","exitCode":%s,"durationSeconds":%s,"wallStart":"%s","wallEnd":"%s","command":"%s","logFile":"%s"}' \
    "$(json_escape "$name")" "$status" "$exit_code" "$duration" \
    "$wall_start" "$wall_end" "$(json_escape "$command")" "$(json_escape "$log")"
}

run_stage() {
  local name="$1"
  local command="$2"
  local log="$run_dir/$name.log"
  local wall_start wall_end start_epoch end_epoch exit_code status

  wall_start=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  start_epoch=$(date +%s)

  bash -c "$command" > "$log" 2>&1
  exit_code=$?

  end_epoch=$(date +%s)
  wall_end=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  status=$([ "$exit_code" -eq 0 ] && echo passed || echo failed)

  echo "___VERIFICATION_STAGE___:$name"
  echo "___VERIFICATION_EXIT_CODE___:$exit_code"
  echo "___VERIFICATION_DURATION___:$((end_epoch - start_epoch))"
  echo "___VERIFICATION_WALL_START___:$wall_start"
  echo "___VERIFICATION_WALL_END___:$wall_end"

  stage_json+=("$(stage_json_entry "$name" "$status" "$exit_code" "$((end_epoch - start_epoch))" \
    "$wall_start" "$wall_end" "$command" "$log")")

  if [ "$exit_code" -ne 0 ]; then
    failed_stage_name="$name"
    failed_exit_code="$exit_code"
  fi

  return "$exit_code"
}

skip_stage() {
  local name="$1"
  local command="$2"

  halted_early=true
  echo "___VERIFICATION_STAGE___:$name"
  echo "___VERIFICATION_SKIPPED___:true"
  skipped_stage_names+=("$name")
  stage_json+=("$(printf '{"name":"%s","status":"skipped","command":"%s"}' \
    "$(json_escape "$name")" "$(json_escape "$command")")")
}

run_all_stages() {
  local i=0
  while [ "$i" -lt "${#stage_names[@]}" ]; do
    if [ "$failed" = true ]; then
      skip_stage "${stage_names[$i]}" "${stage_commands[$i]}"
    elif ! run_stage "${stage_names[$i]}" "${stage_commands[$i]}"; then
      failed=true
    fi
    i=$((i + 1))
  done
}

# ---------------------------------------------------------------------------
# Verdict + summary.json — the complete, final answer (see header comment)
# ---------------------------------------------------------------------------

build_headline() {
  if [ "$failed" = true ]; then
    local headline="Failed at $failed_stage_name: exit code $failed_exit_code"
    if [ "${#skipped_stage_names[@]}" -gt 0 ]; then
      local skipped_joined
      skipped_joined=$(IFS=,; echo "${skipped_stage_names[*]}")
      headline="$headline; skipped: $skipped_joined"
    fi
    printf '%s' "$headline"
  else
    printf 'All %s stage(s) passed' "${#stage_names[@]}"
  fi
}

write_summary() {
  local stages_joined overall_status failed_stages_joined headline

  stages_joined=$(IFS=,; echo "${stage_json[*]}")
  headline="$(build_headline)"

  if [ "$failed" = true ]; then
    overall_status="failed"
    failed_stages_joined="\"$(json_escape "$failed_stage_name")\""
  else
    overall_status="passed"
    failed_stages_joined=""
  fi

  summary_file="$run_dir/summary.json"
  cat > "$summary_file" <<EOF
{
  "schemaVersion": 2,
  "runId": "$run_id",
  "runDir": "$(json_escape "$run_dir")",
  "configFile": "$(json_escape "$config_file")",
  "startedAt": "$run_wall_start",
  "finishedAt": "$run_wall_end",
  "durationSeconds": $((run_end_epoch - run_start_epoch)),
  "haltedEarly": $halted_early,
  "failureHint": "$(json_escape "$failure_hint")",
  "overallStatus": "$overall_status",
  "failedStages": [$failed_stages_joined],
  "headline": "$(json_escape "$headline")",
  "stages": [$stages_joined]
}
EOF
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

config_file="${1:-.lattice/verification.yaml}"

[ -f "$config_file" ] || script_error "verification config not found: $config_file"
[ -r "$config_file" ] || script_error "verification config is not readable: $config_file"

version=""
runs_dir="tmp/verification"
failure_hint=""
seen_stages=false
in_failure_hint=false
current_name=""
current_command=""
stage_names=()
stage_commands=()

parse_config "$config_file"

mkdir -p "$runs_dir" 2>/dev/null || script_error "failed to create runs directory: $runs_dir"

run_id=""
run_dir=""
claim_run_dir

stage_json=()
failed=false
halted_early=false
failed_stage_name=""
failed_exit_code=""
skipped_stage_names=()

run_wall_start=$(date -u +%Y-%m-%dT%H:%M:%SZ)
run_start_epoch=$(date +%s)

echo "___VERIFICATION_RUN_ID___:$run_id"
echo "___VERIFICATION_RUN_DIR___:$run_dir"
echo "___VERIFICATION_RUN_WALL_START___:$run_wall_start"
echo "___VERIFICATION_RUN_START_EPOCH___:$run_start_epoch"

run_all_stages

run_wall_end=$(date -u +%Y-%m-%dT%H:%M:%SZ)
run_end_epoch=$(date +%s)

echo "___VERIFICATION_RUN_WALL_END___:$run_wall_end"
echo "___VERIFICATION_RUN_END_EPOCH___:$run_end_epoch"

write_summary
echo "___VERIFICATION_SUMMARY_FILE___:$summary_file"

prune_old_runs || true

[ "$failed" = true ] && exit 1
exit 0
