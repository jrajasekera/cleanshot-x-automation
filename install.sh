#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="cleanshot-x-automation"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<USAGE
Install $SKILL_NAME for local agent runtimes.

Usage:
  ./install.sh --claude     Install to ~/.claude/skills/$SKILL_NAME
  ./install.sh --codex      Install to ~/.agents/skills/$SKILL_NAME
  ./install.sh --both       Install to both locations
  ./install.sh --project-codex /path/to/repo
                            Install to /path/to/repo/.agents/skills/$SKILL_NAME
  ./install.sh --project-claude /path/to/repo
                            Install to /path/to/repo/.claude/skills/$SKILL_NAME

USAGE
}

copy_skill() {
  local dest="$1"
  local parent
  parent="$(dirname "$dest")"
  mkdir -p "$parent"

  if [[ "$SCRIPT_DIR" == "$dest" ]]; then
    echo "Already installed at $dest"
    return 0
  fi

  rm -rf "$dest"
  if command -v ditto >/dev/null 2>&1; then
    ditto "$SCRIPT_DIR" "$dest"
  else
    cp -R "$SCRIPT_DIR" "$dest"
  fi
  chmod +x "$dest/scripts/cleanshotx" "$dest/install.sh" 2>/dev/null || true
  echo "Installed to $dest"
}

if [[ $# -eq 0 ]]; then
  usage
  exit 2
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --claude)
      copy_skill "$HOME/.claude/skills/$SKILL_NAME"
      shift
      ;;
    --codex)
      copy_skill "$HOME/.agents/skills/$SKILL_NAME"
      shift
      ;;
    --both)
      copy_skill "$HOME/.claude/skills/$SKILL_NAME"
      copy_skill "$HOME/.agents/skills/$SKILL_NAME"
      shift
      ;;
    --project-codex)
      [[ $# -ge 2 ]] || { echo "Missing project path" >&2; exit 2; }
      copy_skill "$2/.agents/skills/$SKILL_NAME"
      shift 2
      ;;
    --project-claude)
      [[ $# -ge 2 ]] || { echo "Missing project path" >&2; exit 2; }
      copy_skill "$2/.claude/skills/$SKILL_NAME"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done
