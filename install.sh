#!/usr/bin/env bash
set -euo pipefail

# Optional convenience installer for the cleanshot-x-automation Agent Skill.
#
# A skill is just a directory. "Installing" means placing this directory where
# your agent scans for skills. You do not need this script -- you can also just
# clone or copy the folder into place, e.g.:
#
#   git clone <url> ~/.agents/skills/cleanshot-x-automation    # cross-client
#   git clone <url> ~/.claude/skills/cleanshot-x-automation    # Claude Code
#
# This script does the same thing, gets the directory name right, and can
# symlink instead of copy so `git pull` updates propagate.

SKILL_NAME="cleanshot-x-automation"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="copy"

usage() {
  cat <<USAGE
Install the $SKILL_NAME skill for local agent runtimes.

Usage:
  ./install.sh [--link] TARGET [TARGET ...]

Targets:
  --agents                ~/.agents/skills/$SKILL_NAME   (cross-client: Codex, VS Code, etc.)
  --codex                 alias for --agents
  --claude                ~/.claude/skills/$SKILL_NAME   (Claude Code)
  --both                  install to both user-level locations above
  --project PATH          PATH/.agents/skills/$SKILL_NAME (cross-client, project-scoped)
  --project-claude PATH   PATH/.claude/skills/$SKILL_NAME (Claude Code, project-scoped)

Options:
  --link                  symlink the skill instead of copying (recommended for
                          git checkouts, so updates propagate on git pull)
  -h, --help              show this help

Examples:
  ./install.sh --agents            # cross-client user install (copy)
  ./install.sh --link --both       # symlink into both ~/.agents and ~/.claude
  ./install.sh --project .         # install into ./.agents/skills for this repo
USAGE
}

install_to() {
  local dest="$1"
  local parent
  parent="$(dirname "$dest")"
  mkdir -p "$parent"

  if [[ "$SRC_DIR" == "$dest" ]]; then
    echo "Already installed at $dest"
    return 0
  fi

  rm -rf "$dest"

  if [[ "$MODE" == "link" ]]; then
    ln -s "$SRC_DIR" "$dest"
    echo "Linked  $dest -> $SRC_DIR"
    return 0
  fi

  # Copy the skill, excluding VCS and editor/tooling metadata.
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --exclude '.git' --exclude '.serena' --exclude '.DS_Store' "$SRC_DIR/" "$dest/"
  else
    cp -R "$SRC_DIR" "$dest"
    rm -rf "$dest/.git" "$dest/.serena"
  fi
  chmod +x "$dest/scripts/cleanshotx" 2>/dev/null || true
  echo "Copied  $dest"
}

if [[ $# -eq 0 ]]; then
  usage
  exit 2
fi

# First pass: pull out global options so they can appear anywhere.
args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --link) MODE="link"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) args+=("$1"); shift ;;
  esac
done
set -- "${args[@]+"${args[@]}"}"

if [[ $# -eq 0 ]]; then
  echo "No target specified." >&2
  usage >&2
  exit 2
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agents|--codex)
      install_to "$HOME/.agents/skills/$SKILL_NAME"
      shift
      ;;
    --claude)
      install_to "$HOME/.claude/skills/$SKILL_NAME"
      shift
      ;;
    --both)
      install_to "$HOME/.agents/skills/$SKILL_NAME"
      install_to "$HOME/.claude/skills/$SKILL_NAME"
      shift
      ;;
    --project)
      [[ $# -ge 2 ]] || { echo "Missing project path for --project" >&2; exit 2; }
      install_to "$2/.agents/skills/$SKILL_NAME"
      shift 2
      ;;
    --project-claude)
      [[ $# -ge 2 ]] || { echo "Missing project path for --project-claude" >&2; exit 2; }
      install_to "$2/.claude/skills/$SKILL_NAME"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done
