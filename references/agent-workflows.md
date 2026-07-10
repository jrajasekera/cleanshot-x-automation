# Agent Workflows for CleanShot X

Use these recipes from Codex, Claude Code, or any agent that can run local shell commands on the user’s Mac.

## 1. Inspect the current screen

```bash
SKILL_DIR="${CLAUDE_SKILL_DIR:-$HOME/.agents/skills/cleanshot-x-automation}"
mkdir -p /tmp/cleanshot-agent
"$SKILL_DIR/scripts/cleanshotx" capture-fullscreen-to-file --output /tmp/cleanshot-agent/current-screen.png --timeout 30
```

Then inspect `/tmp/cleanshot-agent/current-screen.png` with the agent’s available image/view tool.

Use when the user asks:

- “What do you see on my screen?”
- “Take a screenshot and debug this UI.”
- “Capture the current app state.”

Privacy note: fullscreen captures can include sensitive information. Prefer region/window captures when feasible.

## 2. Inspect a known rectangle

```bash
SKILL_DIR="${CLAUDE_SKILL_DIR:-$HOME/.agents/skills/cleanshot-x-automation}"
mkdir -p /tmp/cleanshot-agent
"$SKILL_DIR/scripts/cleanshotx" capture-area-to-file \
  --x 100 --y 120 --width 900 --height 650 --display 1 \
  --output /tmp/cleanshot-agent/region.png \
  --timeout 30
```

Remember: CleanShot coordinates use lower-left origin.

## 3. Ask the user to select a region, then save it

```bash
SKILL_DIR="${CLAUDE_SKILL_DIR:-$HOME/.agents/skills/cleanshot-x-automation}"
mkdir -p /tmp/cleanshot-agent
"$SKILL_DIR/scripts/cleanshotx" capture-area-to-file --output /tmp/cleanshot-agent/user-region.png --timeout 120
```

This opens CleanShot’s area selector. The helper waits until the user completes a selection and CleanShot copies the image.

## 4. Ask the user to select a window, then save it

```bash
SKILL_DIR="${CLAUDE_SKILL_DIR:-$HOME/.agents/skills/cleanshot-x-automation}"
mkdir -p /tmp/cleanshot-agent
"$SKILL_DIR/scripts/cleanshotx" capture-window-to-file --output /tmp/cleanshot-agent/window.png --timeout 120
```

## 5. Re-capture the last CleanShot area

```bash
SKILL_DIR="${CLAUDE_SKILL_DIR:-$HOME/.agents/skills/cleanshot-x-automation}"
mkdir -p /tmp/cleanshot-agent
"$SKILL_DIR/scripts/cleanshotx" capture-previous-area-to-file --output /tmp/cleanshot-agent/previous.png --timeout 30
```

Good for iterative UI changes where the same screen region needs to be compared repeatedly.

## 6. OCR an existing image

```bash
SKILL_DIR="${CLAUDE_SKILL_DIR:-$HOME/.agents/skills/cleanshot-x-automation}"
"$SKILL_DIR/scripts/cleanshotx" ocr-file \
  --file /tmp/cleanshot-agent/current-screen.png \
  --linebreaks true \
  --output /tmp/cleanshot-agent/current-screen.txt \
  --timeout 30
cat /tmp/cleanshot-agent/current-screen.txt
```

Use OCR for text-heavy screenshots, error messages, code in an image, or when the agent has no image-vision tool.

## 7. OCR a screen region directly

```bash
SKILL_DIR="${CLAUDE_SKILL_DIR:-$HOME/.agents/skills/cleanshot-x-automation}"
"$SKILL_DIR/scripts/cleanshotx" ocr-area \
  --x 100 --y 120 --width 900 --height 650 --display 1 \
  --linebreaks true \
  --output /tmp/cleanshot-agent/region.txt \
  --timeout 60
cat /tmp/cleanshot-agent/region.txt
```

## 8. Capture and open in Annotate

```bash
SKILL_DIR="${CLAUDE_SKILL_DIR:-$HOME/.agents/skills/cleanshot-x-automation}"
"$SKILL_DIR/scripts/cleanshotx" capture-area --action annotate
```

This is interactive and user-facing. Use when the user wants to mark up a capture manually.

## 9. Open an existing file in Annotate

```bash
SKILL_DIR="${CLAUDE_SKILL_DIR:-$HOME/.agents/skills/cleanshot-x-automation}"
"$SKILL_DIR/scripts/cleanshotx" open-annotate --file /tmp/cleanshot-agent/current-screen.png
```

## 10. Pin an image as a floating reference

```bash
SKILL_DIR="${CLAUDE_SKILL_DIR:-$HOME/.agents/skills/cleanshot-x-automation}"
"$SKILL_DIR/scripts/cleanshotx" pin --file /tmp/cleanshot-agent/current-screen.png
```

## 11. Add an image or video to Quick Access Overlay

```bash
SKILL_DIR="${CLAUDE_SKILL_DIR:-$HOME/.agents/skills/cleanshot-x-automation}"
"$SKILL_DIR/scripts/cleanshotx" add-quick-access-overlay --file /tmp/cleanshot-agent/current-screen.png
"$SKILL_DIR/scripts/cleanshotx" add-quick-access-overlay --file /tmp/demo.mp4
```

CleanShot accepts PNG/JPEG/MP4 for this endpoint.

## 12. Prepare screen recording

```bash
SKILL_DIR="${CLAUDE_SKILL_DIR:-$HOME/.agents/skills/cleanshot-x-automation}"
"$SKILL_DIR/scripts/cleanshotx" record-screen --x 100 --y 120 --width 1280 --height 720 --display 1
```

CleanShot’s URL API opens recording mode and can preselect an area. It does not document unattended start/stop/save controls. After this command, the user normally starts/stops recording through CleanShot’s UI or configured shortcuts.

## 13. Hide desktop icons before a clean capture

```bash
SKILL_DIR="${CLAUDE_SKILL_DIR:-$HOME/.agents/skills/cleanshot-x-automation}"
"$SKILL_DIR/scripts/cleanshotx" hide-desktop-icons
"$SKILL_DIR/scripts/cleanshotx" capture-fullscreen-to-file --output /tmp/cleanshot-agent/clean-desktop.png
"$SKILL_DIR/scripts/cleanshotx" show-desktop-icons
```

Wrap this in cleanup logic when scripting so icons are restored even if capture fails.

## 14. Open history or restore recently closed item

```bash
SKILL_DIR="${CLAUDE_SKILL_DIR:-$HOME/.agents/skills/cleanshot-x-automation}"
"$SKILL_DIR/scripts/cleanshotx" open-history
"$SKILL_DIR/scripts/cleanshotx" restore-recently-closed
```

The URL API opens/restores UI state; it does not list or export history records as structured data.

## 15. Use raw URL mode for future CleanShot endpoints

If CleanShot adds new URL commands before this skill is updated, use raw mode:

```bash
scripts/cleanshotx url new-command key=value other=/path/to/file --print-url
```

This builds and opens:

```text
cleanshot://new-command?key=value&other=/path/to/file
```

## 16. Agent decision tree

1. Need a file to inspect? Use a `*-to-file` helper.
2. Need user markup? Use `capture-* --action annotate` or `open-annotate --file`.
3. Need text? Use `ocr-file` or `ocr-area`.
4. Need recording? Use `record-screen` to open/preselect mode, then explain that CleanShot’s documented API does not fully automate start/stop/save.
5. Need cloud sharing? Use `--action upload` only when the user explicitly requests an upload.
6. Need CleanShot settings? Use `open-settings --tab ...`.
