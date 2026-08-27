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
# Stages always run sequentially and verification always stops after the first
# failed stage. Every executed stage writes a full log file; stdout carries only
# marker lines and ids, never log content. The script writes a mechanical
# summary.json — status, exit code, and logFile path per stage, plus a
# run-level overallStatus/failedStages/headline verdict — that is the complete,
# final answer. Nothing downstream (agent or human) recomputes it; they only
# read it, on stdout or off disk.

set -u

script_error() {
  echo "___VERIFICATION_SCRIPT_ERROR___:$1"
  exit 2
}

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

while IFS= read -r raw_line || [ -n "$raw_line" ]; do
  line="${raw_line%$'\r'}"
  trimmed="$(trim "$line")"

  if [ "$in_failure_hint" = true ]; then
    case "$line" in
      " "*|$'\t'*)
        hint_line="$(trim "$line")"
        if [ -n "$failure_hint" ]; then
          failure_hint="$failure_hint $hint_line"
        else
          failure_hint="$hint_line"
        fi
        continue
        ;;
      *)
        in_failure_hint=false
        ;;
    esac
  fi

  [ -z "$trimmed" ] && continue
  case "$trimmed" in \#*) continue ;; esac

  case "$line" in
    [![:space:]]*:*)
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
      item="$(trim "${line#*- }")"
      [ -z "$item" ] && continue
      case "$item" in
        name:*) parse_key_value "$item" name ;;
        command:*) parse_key_value "$item" command ;;
        *) script_error "unsupported stage item: $item" ;;
      esac
      ;;
    "    "*|$'\t'*)
      [ "$seen_stages" = true ] || script_error "indented key found before stages"
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
done < "$config_file"

append_stage

[ "$version" = "1" ] || script_error "expected version: 1"
[ -n "$runs_dir" ] || script_error "runsDir must not be empty"
[ "${#stage_names[@]}" -gt 0 ] || script_error "stages must contain at least one stage"

run_id="$(date -u +%Y%m%dT%H%M%SZ)-$(printf '%03x%03x' $((RANDOM % 4096)) $((RANDOM % 4096)))"
run_dir="$runs_dir/$run_id"

if ! mkdir -p "$run_dir" 2>/dev/null; then
  script_error "failed to create run directory: $run_dir"
fi

prune_old_runs() {
  local keep="${VERIFICATION_KEEP_RUNS:-20}"
  case "$keep" in ''|*[!0-9]*) return 0 ;; esac
  [ "$keep" -le 0 ] && return 0
  [ -d "$runs_dir" ] || return 0

  local n=0 d
  while IFS= read -r d; do
    case "$d" in
      [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]Z-[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]) ;;
      *) continue ;;
    esac
    n=$((n + 1))
    if [ "$n" -gt "$keep" ]; then
      rm -rf "${runs_dir:?}/$d"
    fi
  done <<EOF
$(ls -1 "$runs_dir" 2>/dev/null | sort -r)
EOF
}

stage_json=()
failed=false
halted_early=false
failed_stage_name=""
failed_exit_code=""
skipped_stage_names=()

run_stage() {
  local name="$1"
  local command="$2"
  local log="$run_dir/$name.log"
  local wall_start wall_end start_epoch end_epoch exit_code status entry

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

  entry=$(printf '{"name":"%s","status":"%s","exitCode":%s,"durationSeconds":%s,"wallStart":"%s","wallEnd":"%s","command":"%s","logFile":"%s"}' \
    "$(json_escape "$name")" "$status" "$exit_code" "$((end_epoch - start_epoch))" \
    "$wall_start" "$wall_end" "$(json_escape "$command")" "$(json_escape "$log")")
  stage_json+=("$entry")

  if [ "$exit_code" -ne 0 ]; then
    failed_stage_name="$name"
    failed_exit_code="$exit_code"
  fi

  return "$exit_code"
}

run_wall_start=$(date -u +%Y-%m-%dT%H:%M:%SZ)
run_start_epoch=$(date +%s)

echo "___VERIFICATION_RUN_ID___:$run_id"
echo "___VERIFICATION_RUN_DIR___:$run_dir"
echo "___VERIFICATION_RUN_WALL_START___:$run_wall_start"
echo "___VERIFICATION_RUN_START_EPOCH___:$run_start_epoch"

i=0
while [ "$i" -lt "${#stage_names[@]}" ]; do
  if [ "$failed" = true ]; then
    halted_early=true
    echo "___VERIFICATION_STAGE___:${stage_names[$i]}"
    echo "___VERIFICATION_SKIPPED___:true"
    skipped_stage_names+=("${stage_names[$i]}")
    stage_json+=("$(printf '{"name":"%s","status":"skipped","command":"%s"}' \
      "$(json_escape "${stage_names[$i]}")" "$(json_escape "${stage_commands[$i]}")")")
  else
    if ! run_stage "${stage_names[$i]}" "${stage_commands[$i]}"; then
      failed=true
    fi
  fi
  i=$((i + 1))
done

run_wall_end=$(date -u +%Y-%m-%dT%H:%M:%SZ)
run_end_epoch=$(date +%s)

echo "___VERIFICATION_RUN_WALL_END___:$run_wall_end"
echo "___VERIFICATION_RUN_END_EPOCH___:$run_end_epoch"

stages_joined=$(IFS=,; echo "${stage_json[*]}")
summary_file="$run_dir/summary.json"

if [ "$failed" = true ]; then
  overall_status="failed"
  failed_stages_joined="\"$(json_escape "$failed_stage_name")\""
  headline="Failed at $failed_stage_name: exit code $failed_exit_code"
  if [ "${#skipped_stage_names[@]}" -gt 0 ]; then
    skipped_joined=$(IFS=,; echo "${skipped_stage_names[*]}")
    headline="$headline; skipped: $skipped_joined"
  fi
else
  overall_status="passed"
  failed_stages_joined=""
  headline="All ${#stage_names[@]} stage(s) passed"
fi

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

echo "___VERIFICATION_SUMMARY_FILE___:$summary_file"

prune_old_runs || true

[ "$failed" = true ] && exit 1
exit 0
