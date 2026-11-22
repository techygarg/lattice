#!/usr/bin/env bash
# Checks a built Claude.ai directory tree against the rules the Anthropic plugin
# directory applies to organizations that are not Verified. Reports every
# problem it finds, then exits non-zero if there were any.
#
# This is a local stand-in, not the directory's own review: the directory also
# runs a security scan and a policy review. Treat a pass here as necessary, not
# sufficient, and confirm with Validate in the developer portal.
#
# Usage: tools/claude-directory/check.sh <dir> [expected-version]
#   expected-version  version plugin.json must carry (a release tag without "v")
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "usage: $0 <dir> [expected-version]" >&2
  exit 2
fi
if [ ! -d "$1" ]; then
  echo "error: not a directory: $1" >&2
  exit 2
fi
DIR="$(cd "$1" && pwd)"
EXPECTED_VERSION="${2:-}"

MAX_FILES=512
MAX_TEXT_BYTES=262144   # 256 KiB: larger text files cannot be read in full
MAX_ICON_BYTES=2097152  # 2 MiB
ICON_MIN_PX=512
ICON_MAX_PX=2048
INSTALL_LINE='/plugin install lattice --marketplace techygarg/lattice'

ALLOWED_EXT_RE='\.(md|txt|json|ya?ml|png|jpe?g|gif|webp|ico)$'
ALLOWED_PATH_RE='^(\.claude-plugin/plugin\.json|\.claude-plugin/icon\.png|LICENSE|README\.md|skills/[a-z0-9-]+/(SKILL\.md|(references|assets)/[A-Za-z0-9._-]+\.md))$'
# Commands that download or run code. The directory refuses these from
# organizations that are not Verified, even inside documentation.
RISKY_CMD_RE='(^|[^A-Za-z])(curl|wget) |npx |uvx |pipx |pip3? install|npm (install|i|ci)( |$)|yarn add|pnpm (add|install)|brew install|go install|cargo install|\| *(ba|z)?sh( |$)|bash <\('

FAILED=0
fail() {
  echo "FAIL: $1" >&2
  FAILED=$((FAILED + 1))
}

json_field() { # json_field <file> <key>: the key's value when it is a string, else empty
  python3 -I -c 'import json, sys
v = json.load(open(sys.argv[1])).get(sys.argv[2], "")
print(v if isinstance(v, str) else "")' "$1" "$2"
}

check_icon() { # check_icon <file>
  local f="$1" magic w h
  magic="$(od -An -tx1 -N8 "$f" | tr -d ' \n')"
  if [ "$magic" != "89504e470d0a1a0a" ]; then
    fail "icon.png is not a PNG file"
    return 0
  fi
  # IHDR: width and height are big-endian 32-bit integers at byte 16 and 20.
  w=$((0x$(od -An -tx1 -j16 -N4 "$f" | tr -d ' \n')))
  h=$((0x$(od -An -tx1 -j20 -N4 "$f" | tr -d ' \n')))
  if [ "$w" -lt "$ICON_MIN_PX" ] || [ "$h" -lt "$ICON_MIN_PX" ] ||
    [ "$w" -gt "$ICON_MAX_PX" ] || [ "$h" -gt "$ICON_MAX_PX" ]; then
    fail "icon.png is ${w}x${h}px; each side must be ${ICON_MIN_PX} to ${ICON_MAX_PX}px"
  fi
}

# 1. Required files.
for required in .claude-plugin/plugin.json .claude-plugin/icon.png LICENSE README.md; do
  [ -f "$DIR/$required" ] || fail "missing required file: $required"
done

# 2. Symlinks are never allowed.
while IFS= read -r -d '' link; do
  fail "symlink not allowed: ${link#"$DIR"/}"
done < <(find "$DIR" -type l -print0)

# 3. Every skill folder holds a SKILL.md, and there is at least one skill.
skills=0
if [ -d "$DIR/skills" ]; then
  while IFS= read -r -d '' skill_dir; do
    skills=$((skills + 1))
    [ -f "$skill_dir/SKILL.md" ] || fail "skill folder without SKILL.md: ${skill_dir#"$DIR"/}"
  done < <(find "$DIR/skills" -mindepth 1 -maxdepth 1 -type d -print0)
fi
[ "$skills" -gt 0 ] || fail "no skills found under skills/"

# 4. Per-file rules.
count=0
while IFS= read -r -d '' abs; do
  rel="${abs#"$DIR"/}"
  count=$((count + 1))

  if ! [[ "$rel" =~ $ALLOWED_PATH_RE ]]; then
    fail "not on the allowlist: $rel"
  fi
  if [ "$rel" != "LICENSE" ] && ! [[ "$rel" =~ $ALLOWED_EXT_RE ]]; then
    fail "file type not accepted by the directory: $rel"
  fi
  if [ "$(head -c 2 "$abs")" = '#!' ]; then
    fail "starts with #! (a script): $rel"
  fi

  size=$(($(wc -c < "$abs")))
  case "$rel" in
    *.png | *.jpg | *.jpeg | *.gif | *.webp | *.ico)
      [ "$size" -le "$MAX_ICON_BYTES" ] || fail "image over 2 MiB: $rel"
      if LC_ALL=C grep -qaF "$(printf 'PK\003\004')" "$abs"; then
        fail "image looks like it holds a zip archive: $rel"
      fi
      if [ "$rel" = ".claude-plugin/icon.png" ]; then
        check_icon "$abs"
      fi
      ;;
    *)
      [ "$size" -lt "$MAX_TEXT_BYTES" ] || fail "text file of 256 KiB or more: $rel"
      stripped=$(($(LC_ALL=C tr -d '\000' < "$abs" | wc -c)))
      [ "$stripped" -eq "$size" ] || fail "contains NUL bytes: $rel"
      # Python's strict decoder, not iconv: macOS iconv rejects some valid files.
      if ! python3 -I -c 'import sys; open(sys.argv[1], "rb").read().decode("utf-8")' "$abs" 2> /dev/null; then
        fail "not valid UTF-8: $rel"
      fi
      risky="$(grep -nE "$RISKY_CMD_RE" "$abs" | head -n 1 || true)"
      if [ -n "$risky" ]; then
        fail "command that downloads or runs code ($rel:$risky)"
      fi
      ;;
  esac
done < <(find "$DIR" -type f -print0)

[ "$count" -le "$MAX_FILES" ] || fail "$count files; the limit is $MAX_FILES"

# 5. plugin.json: valid JSON, expected name and version.
manifest="$DIR/.claude-plugin/plugin.json"
if [ -f "$manifest" ]; then
  if ! name="$(json_field "$manifest" name 2> /dev/null)"; then
    fail "plugin.json is not valid JSON"
  else
    version="$(json_field "$manifest" version)"
    description="$(json_field "$manifest" description)"
    [ "$name" = "lattice" ] || fail "plugin.json name is '$name', expected 'lattice'"
    [ -n "$description" ] || fail "plugin.json has no description"
    if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      fail "plugin.json version '$version' is not MAJOR.MINOR.PATCH"
    elif [ -n "$EXPECTED_VERSION" ] && [ "$version" != "$EXPECTED_VERSION" ]; then
      fail "plugin.json version is $version but this release is $EXPECTED_VERSION"
    fi
  fi
fi

# 6. README: installs from a marketplace, and every link is absolute.
readme="$DIR/README.md"
if [ -f "$readme" ]; then
  grep -qF -- "$INSTALL_LINE" "$readme" || fail "README.md has no install line: $INSTALL_LINE"
  relative="$({
    grep -oE '\]\([^)]*\)' "$readme" | grep -vE '^\]\((https?://|#|mailto:)' || true
    grep -oE '(src|href)="[^"]*"' "$readme" | grep -vE '="(https?://|#|mailto:)' || true
  } | tr '\n' ' ')"
  [ -z "$relative" ] || fail "README.md has relative links, which break outside the repo: $relative"
fi

if [ "$FAILED" -gt 0 ]; then
  echo "$FAILED check(s) failed for $DIR" >&2
  exit 1
fi
echo "OK: $count files in $DIR pass every check"
