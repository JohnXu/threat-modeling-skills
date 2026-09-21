#!/usr/bin/env bash
# Installs threat-modeling-skills SKILL.md folders into an agent skills directory.
#
# Usage:
#   ./scripts/install-skills.sh [skill-name ...]
#   ./scripts/install-skills.sh --dir /custom/path threat-model-stride threat-model-linddun
#
# With no skill names, installs all skills. Requires Node.js (uses `npx degit`),
# which fetches each skill folder without cloning git history and without
# touching unrelated skills already present in the target directory.
set -euo pipefail

REPO="JohnXu/threat-modeling-skills"
BRANCH="main"
TARGET_DIR="${AGENT_SKILLS_DIR:-$HOME/.agents/skills}"

ALL_SKILLS=(
  threat-model-stride
  threat-model-linddun
  threat-model-pasta
  threat-model-attack-tree
  threat-model-dfd
  threat-model-trust-boundary
  threat-model-abuse-case
)

SKILLS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)
      TARGET_DIR="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--dir TARGET_DIR] [skill-name ...]"
      echo "Available skills: ${ALL_SKILLS[*]}"
      exit 0
      ;;
    *)
      SKILLS+=("$1")
      shift
      ;;
  esac
done

if [[ ${#SKILLS[@]} -eq 0 ]]; then
  SKILLS=("${ALL_SKILLS[@]}")
fi

if ! command -v npx >/dev/null 2>&1; then
  echo "error: npx (Node.js) is required to run this installer." >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

for skill in "${SKILLS[@]}"; do
  dest="$TARGET_DIR/$skill"
  echo "Installing $skill -> $dest"
  npx --yes degit "${REPO}/skills/${skill}#${BRANCH}" "$dest" --force
done

echo ""
echo "Installed ${#SKILLS[@]} skill(s) into $TARGET_DIR"
