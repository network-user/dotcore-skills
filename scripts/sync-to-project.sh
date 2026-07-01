#!/usr/bin/env bash
# Copy DotCore skills into a target project's agent skill directories.
#
# Usage:
#   ./scripts/sync-to-project.sh /path/to/repo
#   ./scripts/sync-to-project.sh . generate-readme
#   LINK=1 ./scripts/sync-to-project.sh .
#   AGENTS=cursor,claude,agents ./scripts/sync-to-project.sh .
#   ALL_AGENTS=1 LINK=1 ./scripts/sync-to-project.sh .
#   ./scripts/sync-to-project.sh --list-agents

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"
CONFIG="$REPO_ROOT/scripts/agents.targets.json"

if [[ "${1:-}" == "--list-agents" ]]; then
  python3 - "$CONFIG" <<'PY'
import json, sys
for t in json.load(open(sys.argv[1], encoding="utf-8"))["projectTargets"]:
    print(f"  {t['id']:<10} {t['name']} -> ./{t['dir']}")
PY
  exit 0
fi

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <target-project-path> [skill-name]" >&2
  exit 1
fi

TARGET="$(cd "$1" && pwd)"
SKILL_FILTER="${2:-}"
LINK="${LINK:-0}"
AGENTS_FILTER="${AGENTS:-cursor}"
ALL_AGENTS="${ALL_AGENTS:-0}"

if [[ -n "$SKILL_FILTER" && ! "$SKILL_FILTER" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "Invalid skill name: '$SKILL_FILTER' (allowed: letters, digits, '.', '_', '-')" >&2
  exit 1
fi

python3 - "$CONFIG" "$TARGET" "$SKILLS_SRC" "$LINK" "$ALL_AGENTS" "$AGENTS_FILTER" "$SKILL_FILTER" <<'PY'
import json, os, shutil, sys

config_path, target, skills_src, link_flag, all_agents, agents_filter, skill_filter = sys.argv[1:8]
link = link_flag == "1"
all_agents = all_agents == "1"


def is_safe_rel(rel):
    """Reject dir values that are absolute or contain traversal."""
    if not rel or rel.startswith("/") or rel.startswith("\\"):
        return False
    if os.path.isabs(rel) or ":" in rel:
        return False
    parts = rel.replace("\\", "/").split("/")
    return ".." not in parts


def within(path, boundary):
    """True only if realpath(path) stays inside boundary."""
    base = os.path.realpath(boundary)
    full = os.path.realpath(path)
    return full == base or full.startswith(base + os.sep)


target = os.path.realpath(target)

cfg = json.load(open(config_path, encoding="utf-8"))
targets = cfg["projectTargets"]
if not all_agents:
    allowed = {a.strip().lower() for a in agents_filter.split(",") if a.strip()}
    targets = [t for t in targets if t["id"] in allowed]
if not targets:
    raise SystemExit("No matching agents. Use --list-agents.")

if skill_filter:
    skills = [skill_filter]
else:
    skills = sorted(
        name for name in os.listdir(skills_src)
        if not name.startswith("_") and os.path.isdir(os.path.join(skills_src, name))
    )

print("sync-to-project")
print(f"  from:   {skills_src}")
print(f"  target: {target}")
print(f"  agents: {', '.join(t['id'] for t in targets)}")
print(f"  skills: {', '.join(skills)}")
print()

for target_def in targets:
    if not is_safe_rel(target_def["dir"]):
        raise SystemExit(
            f"Unsafe dir '{target_def['dir']}' for agent '{target_def['id']}' - aborting."
        )
    dest_skills = os.path.join(target, *target_def["dir"].split("/"))
    parent = os.path.dirname(dest_skills)
    if not within(parent if os.path.exists(parent) else target, target):
        raise SystemExit(
            f"dir '{target_def['dir']}' for agent '{target_def['id']}' escapes target root - aborting."
        )
    os.makedirs(dest_skills, exist_ok=True)
    if not within(dest_skills, target):
        raise SystemExit(
            f"dir '{target_def['dir']}' for agent '{target_def['id']}' escapes target root - aborting."
        )
    print(f"{target_def['name']} -> {target_def['dir']}")
    for name in skills:
        src = os.path.join(skills_src, name)
        dst = os.path.join(dest_skills, name)
        if not os.path.isdir(src):
            print(f"  Skip {name} - not found")
            continue
        if not within(dst, dest_skills):
            raise SystemExit(f"Skill '{name}' resolves outside target dir - aborting.")
        if os.path.lexists(dst):
            if os.path.islink(dst):
                os.unlink(dst)
            else:
                shutil.rmtree(dst)
        if link:
            os.symlink(src, dst)
            print(f"  symlink {name}")
        else:
            shutil.copytree(src, dst)
            print(f"  copy {name}")
    print()
print("Done.")
PY
