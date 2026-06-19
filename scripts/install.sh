#!/usr/bin/env bash
# Install DotCore Agent Skills to Cursor, Claude Code, and Codex.
# Usage:
#   ./scripts/install.sh
#   ./scripts/install.sh generate-readme
#   LINK=1 ./scripts/install.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"
SKILL_FILTER="${1:-}"
LINK="${LINK:-0}"

install_skill() {
  local name="$1"
  local target_dir="$2"
  local agent="$3"
  local src="$SKILLS_SRC/$name"
  local dst="$target_dir/$name"

  [[ -d "$src" ]] || { echo "Skip $name - not found"; return; }
  mkdir -p "$target_dir"
  rm -rf "$dst"
  if [[ "$LINK" == "1" ]]; then
    ln -s "$src" "$dst"
    echo "  [$agent] symlink -> $dst"
  else
    cp -R "$src" "$dst"
    echo "  [$agent] copy -> $dst"
  fi
}

mapfile -t SKILLS < <(find "$SKILLS_SRC" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)
if [[ -n "$SKILL_FILTER" ]]; then
  SKILLS=("$SKILL_FILTER")
fi

echo "dotcore-skills install"
echo "Source: $SKILLS_SRC"
echo ""

for agent_pair in \
  "Cursor:$HOME/.cursor/skills" \
  "Claude Code:$HOME/.claude/skills" \
  "Codex:$HOME/.codex/skills"; do
  agent="${agent_pair%%:*}"
  dir="${agent_pair#*:}"
  echo "$agent:"
  for name in "${SKILLS[@]}"; do
    install_skill "$name" "$dir" "$agent"
  done
  echo ""
done

PROMPTS_DIR="$HOME/.codex/prompts"
mkdir -p "$PROMPTS_DIR"
for name in "${SKILLS[@]}"; do
  prompt="$SKILLS_SRC/$name/codex-prompt.md"
  if [[ -f "$prompt" ]]; then
    cp "$prompt" "$PROMPTS_DIR/$name.md"
    echo "  [Codex prompt] $name.md"
  fi
done

echo "Done."
