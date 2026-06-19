#!/usr/bin/env bash
# Install DotCore Agent Skills to supported AI coding agents.
#
# Usage:
#   ./scripts/install.sh
#   ./scripts/install.sh generate-readme
#   LINK=1 ./scripts/install.sh
#   AGENTS=cursor,claude,agents ./scripts/install.sh
#   ./scripts/install.sh --list-agents

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"
CONFIG="$REPO_ROOT/scripts/agents.targets.json"
SKILL_FILTER="${1:-}"
LINK="${LINK:-0}"
AGENTS_FILTER="${AGENTS:-}"

list_agents() {
  echo "Supported agent IDs (user-level):"
  python3 - "$CONFIG" <<'PY'
import json, sys
cfg = json.load(open(sys.argv[1], encoding="utf-8"))
for t in cfg["userTargets"]:
    aliases = t.get("aliases")
    extra = f" [{', '.join(aliases)}]" if aliases else ""
    print(f"  {t['id']:<10} {t['name']} -> ~/{t['dir']}{extra}")
PY
}

if [[ "${1:-}" == "--list-agents" ]]; then
  list_agents
  exit 0
fi

if [[ -n "$SKILL_FILTER" && "$SKILL_FILTER" == --* ]]; then
  echo "Unknown option: $SKILL_FILTER" >&2
  exit 1
fi

user_home() {
  local rel="$1"
  echo "$HOME/${rel//\//\/}"
}

install_skill() {
  local name="$1"
  local target_dir="$2"
  local agent="$3"
  local src="$SKILLS_SRC/$name"
  local dst="$target_dir/$name"

  [[ -d "$src" ]] || { echo "  Skip $name - not found"; return; }
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

mapfile -t SKILLS < <(find "$SKILLS_SRC" -mindepth 1 -maxdepth 1 -type d ! -name '_*' -exec basename {} \; | sort)
if [[ -n "$SKILL_FILTER" ]]; then
  SKILLS=("$SKILL_FILTER")
fi

echo "dotcore-skills install"
echo "Source: $SKILLS_SRC"
echo "Skills: ${SKILLS[*]}"
[[ -n "$AGENTS_FILTER" ]] && echo "Agents: $AGENTS_FILTER"
echo ""

python3 - "$CONFIG" "$AGENTS_FILTER" "$SKILLS_SRC" "$LINK" "${SKILLS[@]}" <<'PY'
import json, os, shutil, sys, subprocess

config_path, agents_filter, skills_src, link_flag = sys.argv[1:5]
skill_names = sys.argv[5:]
link = link_flag == "1"
home = os.path.expanduser("~")

cfg = json.load(open(config_path, encoding="utf-8"))
targets = cfg["userTargets"]
if agents_filter:
    allowed = {a.strip().lower() for a in agents_filter.split(",") if a.strip()}
    targets = [t for t in targets if t["id"] in allowed]
if not targets:
    raise SystemExit("No matching agents. Use --list-agents for IDs.")

for target in targets:
    target_dir = os.path.join(home, *target["dir"].split("/"))
    print(f"{target['name']} ({target['id']}):")
    os.makedirs(target_dir, exist_ok=True)
    for name in skill_names:
        src = os.path.join(skills_src, name)
        dst = os.path.join(target_dir, name)
        if not os.path.isdir(src):
            print(f"  Skip {name} - not found")
            continue
        if os.path.lexists(dst):
            if os.path.islink(dst) or os.path.isdir(dst):
                shutil.rmtree(dst) if os.path.isdir(dst) and not os.path.islink(dst) else os.unlink(dst)
        if link:
            os.symlink(src, dst)
            print(f"  [{target['name']}] symlink -> {dst}")
        else:
            shutil.copytree(src, dst)
            print(f"  [{target['name']}] copy -> {dst}")

    prompts_dir = target.get("promptsDir")
    prompt_source = target.get("promptSource")
    if prompts_dir and prompt_source:
        pdir = os.path.join(home, *prompts_dir.split("/"))
        os.makedirs(pdir, exist_ok=True)
        for name in skill_names:
            src = os.path.join(skills_src, name, prompt_source)
            if os.path.isfile(src):
                dst = os.path.join(pdir, f"{name}.md")
                shutil.copy2(src, dst)
                print(f"  [{target['name']} prompt] {name}.md -> {pdir}")
    print()
print("Done.")
PY
