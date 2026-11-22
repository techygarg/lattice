#!/usr/bin/env bash
# Publishes a built Claude.ai directory tree (see build.sh) to the
# claude-ai-directory branch, which the plugin directory listing tracks.
#
# - Runs check.sh first; an unchecked tree is never published.
# - Adds one commit per release on top of the branch (no force-push), so its
#   history is an audit trail and each release reaches the directory's webhook
#   as a new commit. The first run creates the branch with no history shared
#   with main.
# - Does nothing when the tree is identical to the branch tip.
# - Refuses to publish changed content under an unchanged version: installed
#   copies only update when plugin.json's version changes.
#
# Usage: tools/claude-directory/publish.sh <built-dir> [--dry-run]
#   --dry-run  run every check and show what would change, without committing
#              or pushing
#
# Environment (all optional):
#   EXPECTED_VERSION         version the tree must carry (a tag without its "v")
#   SOURCE_LABEL             what the tree was built from, for the commit message
#                            (default: the current branch)
#   PUBLISH_GIT_NAME / PUBLISH_GIT_EMAIL   commit identity
#                            (default: the GitHub Actions bot)
#   CLAUDE_DIRECTORY_BRANCH  target branch (default: claude-ai-directory)
#   CLAUDE_DIRECTORY_REMOTE  remote name (default: origin)
set -euo pipefail

usage() {
  echo "usage: $0 <built-dir> [--dry-run]" >&2
  exit 2
}

[ "$#" -ge 1 ] && [ "$#" -le 2 ] || usage
DRY_RUN=0
if [ "$#" -eq 2 ]; then
  [ "$2" = "--dry-run" ] || usage
  DRY_RUN=1
fi
[ -d "$1" ] || { echo "error: not a directory: $1" >&2; exit 2; }

BUILT="$(cd "$1" && pwd)"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BRANCH="${CLAUDE_DIRECTORY_BRANCH:-claude-ai-directory}"
REMOTE="${CLAUDE_DIRECTORY_REMOTE:-origin}"
GIT_NAME="${PUBLISH_GIT_NAME:-github-actions[bot]}"
GIT_EMAIL="${PUBLISH_GIT_EMAIL:-41898282+github-actions[bot]@users.noreply.github.com}"
cd "$ROOT"

"$ROOT/tools/claude-directory/check.sh" "$BUILT" ${EXPECTED_VERSION:+"$EXPECTED_VERSION"}

version_of() { # version_of: reads a plugin.json on stdin, prints its version
  python3 -I -c 'import json, sys; print(json.load(sys.stdin).get("version", ""))'
}
version="$(version_of < "$BUILT/.claude-plugin/plugin.json")"
sha="$(git rev-parse --short HEAD)"
label="${SOURCE_LABEL:-$(git rev-parse --abbrev-ref HEAD)}"

# Does the target branch exist on the remote? ls-remote exits 2 when it does not
# and something else when the remote cannot be reached.
rc=0
git ls-remote --exit-code "$REMOTE" "refs/heads/$BRANCH" > /dev/null 2>&1 || rc=$?
case "$rc" in
  0) have_branch=1 ;;
  2) have_branch=0 ;;
  *) echo "error: cannot reach remote '$REMOTE'" >&2; exit 1 ;;
esac

WT="$(mktemp -d)"
TMP_BRANCH=""
cleanup() {
  git worktree remove --force "$WT" > /dev/null 2>&1 || rm -rf "$WT"
  git worktree prune
  if [ -n "$TMP_BRANCH" ]; then
    git branch -D "$TMP_BRANCH" > /dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

previous=""
if [ "$have_branch" -eq 1 ]; then
  git fetch --quiet --no-tags "$REMOTE" "+refs/heads/$BRANCH:refs/remotes/$REMOTE/$BRANCH"
  git worktree add --quiet --detach "$WT" "refs/remotes/$REMOTE/$BRANCH"
  previous="$(git -C "$WT" show HEAD:.claude-plugin/plugin.json | version_of)"
else
  TMP_BRANCH="claude-directory-publish-$$"
  git worktree add --quiet --detach "$WT" HEAD
  git -C "$WT" checkout --quiet --orphan "$TMP_BRANCH"
  git -C "$WT" rm -rf --quiet --ignore-unmatch .
fi

# Replace the whole tree, so a file removed from the allowlist disappears too.
find "$WT" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
cp -R "$BUILT"/. "$WT"/
git -C "$WT" add --all

if [ "$have_branch" -eq 1 ] && git -C "$WT" diff --cached --quiet; then
  echo "$BRANCH is already up to date (v$version); nothing to publish"
  exit 0
fi
if [ "$have_branch" -eq 1 ] && [ "$previous" = "$version" ]; then
  echo "error: the content changed but plugin.json still says $version." >&2
  echo "Bump the version before releasing; installed copies only update when it changes." >&2
  exit 1
fi

if [ "$DRY_RUN" -eq 1 ]; then
  echo "dry run: would publish v$version to $REMOTE/$BRANCH (previous: ${previous:-none, branch would be created})"
  git -C "$WT" diff --cached --stat | tail -n 5
  exit 0
fi

git -C "$WT" -c "user.name=$GIT_NAME" -c "user.email=$GIT_EMAIL" commit --quiet \
  -m "Release v$version" \
  -m "Built by tools/claude-directory from $label ($sha)."
git -C "$WT" push --quiet "$REMOTE" "HEAD:refs/heads/$BRANCH"
echo "Published v$version to $REMOTE/$BRANCH (from $label, $sha)"
