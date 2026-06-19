#!/usr/bin/env bash
# Copy DotCore skills into a target project's .cursor/skills/
# Usage:
#   ./scripts/sync-to-project.sh /path/to/DotCoreBot
#   ./scripts/sync-to-project.sh . generate-readme
#   LINK=1 CLAUDE=1 ./scripts/sync-to-project.sh .

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <target-project-path> [skill-name]"
  exit 1
fi

TARGET="$(cd "$1" && pwd)"
SKILL_FILTER="${2:-}"
LINK="${LINK:-0}"
CLAUDE="${CLAUDE:-0}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"
CURSOR_DST="$TARGET/.cursor/skills"

mapfile -t SKILLS < <(find "$SKILLS_SRC" -mindepth 1 -maxdepth 1 -type d ! -name '_*' -exec basename {} \; | sort)
if [[ -n "$SKILL_FILTER" ]]; then
  SKILLS=("$SKILL_FILTER")
fi

mkdir -p "$CURSOR_DST"
echo "sync-to-project: $SKILLS_SRC -> $CURSOR_DST"

for name in "${SKILLS[@]}"; do
  src="$SKILLS_SRC/$name"
  dst="$CURSOR_DST/$name"
  rm -rf "$dst"
  if [[ "$LINK" == "1" ]]; then
    ln -s "$src" "$dst"
    echo "  symlink $name"
  else
    cp -R "$src" "$dst"
    echo "  copy $name"
  fi
  if [[ "$CLAUDE" == "1" ]]; then
    mkdir -p "$TARGET/.claude/skills"
    rm -rf "$TARGET/.claude/skills/$name"
    if [[ "$LINK" == "1" ]]; then
      ln -s "$src" "$TARGET/.claude/skills/$name"
    else
      cp -R "$src" "$TARGET/.claude/skills/$name"
    fi
    echo "  mirror -> .claude/skills/$name"
  fi
done

echo "Done."
