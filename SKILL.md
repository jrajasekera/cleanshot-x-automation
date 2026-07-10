---
name: cleanshot-x-automation
description: Control CleanShot X on a local macOS desktop via its URL scheme. Use for taking fullscreen/area/window screenshots, saving captures to files through a clipboard helper, opening screen recording mode, running OCR, annotating/pinning images, adding Quick Access Overlay items, opening history/settings, and toggling desktop icons when the user wants an agent to capture or inspect the Mac screen with CleanShot X.
compatibility: Requires macOS with a graphical login session and CleanShot X installed, with its URL scheme API enabled (Settings → Advanced → API → Allow Applications to control CleanShot). Uses /usr/bin open, osascript, pbpaste, and sips. Does not work headless, over SSH without a GUI, or in cloud sandboxes.
metadata:
  version: "1.0.0"
  source: https://github.com/jrajasekera/cleanshot-x-automation
---

# CleanShot X Automation

Use this skill only when running on the user's local macOS graphical session where CleanShot X is installed. It will not work in a headless Linux container, remote cloud sandbox, or SSH session without GUI access.

## First choice: bundled helper CLI

Run the helper from the skill directory:

```bash
${CLAUDE_SKILL_DIR:-.}/scripts/cleanshotx status
${CLAUDE_SKILL_DIR:-.}/scripts/cleanshotx capture-fullscreen-to-file --output /tmp/cleanshot-fullscreen.png --timeout 30
${CLAUDE_SKILL_DIR:-.}/scripts/cleanshotx capture-area-to-file --x 100 --y 120 --width 800 --height 600 --display 1 --output /tmp/cleanshot-area.png --timeout 30
${CLAUDE_SKILL_DIR:-.}/scripts/cleanshotx ocr-file --file /tmp/cleanshot-area.png --output /tmp/cleanshot-area.txt --timeout 30
```

For Codex, replace `${CLAUDE_SKILL_DIR:-.}` with the installed skill path, usually `~/.agents/skills/cleanshot-x-automation` or the repository path `.agents/skills/cleanshot-x-automation`.

If the helper fails with “API disabled” symptoms, open CleanShot settings and instruct the user to enable **Settings → Advanced → API → Allow Applications to control CleanShot**:

```bash
scripts/cleanshotx open-settings --tab advanced
```

## Core workflow for screenshots the agent must inspect

1. Prefer `capture-fullscreen-to-file`, `capture-area-to-file`, `capture-window-to-file`, or `capture-previous-area-to-file`.
2. These wrappers call CleanShot with `action=copy`, clear the clipboard first, wait for the new image, then save it to the requested output file using AppleScript.
3. After a file is created, inspect that image using the agent’s available image-reading tool. Use CleanShot OCR only when text extraction is needed or image vision is unavailable.
4. Use absolute output paths when possible. Good default: `/tmp/cleanshot-agent/<purpose>.png`.

Examples:

```bash
mkdir -p /tmp/cleanshot-agent
scripts/cleanshotx capture-fullscreen-to-file --output /tmp/cleanshot-agent/screen.png
scripts/cleanshotx capture-window-to-file --output /tmp/cleanshot-agent/window.png
scripts/cleanshotx capture-area-to-file --x 0 --y 0 --width 1440 --height 900 --display 1 --output /tmp/cleanshot-agent/area.png
```

## Direct CleanShot URL commands

The helper exposes CleanShot’s URL API directly:

```bash
scripts/cleanshotx capture-fullscreen --action save
scripts/cleanshotx capture-area --x 100 --y 120 --width 800 --height 600 --display 1 --action annotate
scripts/cleanshotx scrolling-capture --x 100 --y 120 --width 800 --height 600 --display 1 --start true --autoscroll true
scripts/cleanshotx record-screen --x 100 --y 120 --width 800 --height 600 --display 1
scripts/cleanshotx capture-text --file /tmp/cleanshot-agent/screen.png --linebreaks true
scripts/cleanshotx open-annotate --file /tmp/cleanshot-agent/screen.png
scripts/cleanshotx pin --file /tmp/cleanshot-agent/screen.png
scripts/cleanshotx add-quick-access-overlay --file /tmp/demo.mp4
scripts/cleanshotx hide-desktop-icons
scripts/cleanshotx show-desktop-icons
scripts/cleanshotx open-history
```

Use `scripts/cleanshotx --help` for the full command list.

## Screen recording guidance

CleanShot’s URL API opens Record Screen mode and can preselect a region, but it does not document a URL parameter to start, stop, pause, or save a recording to an exact path. Treat recording as semi-automated:

```bash
scripts/cleanshotx record-screen --x 100 --y 120 --width 1280 --height 720 --display 1
```

Then the user or a UI-driving workflow must start/stop the recording. Do not claim that this skill can fully unattended-record video through CleanShot unless a later CleanShot API version documents start/stop/output controls.

## Actions and privacy policy

CleanShot screenshot actions are `copy`, `save`, `annotate`, `upload`, and `pin` where supported. Do not use `upload` unless the user explicitly asks for CleanShot Cloud sharing. Captures and OCR may include secrets, personal data, credentials, customer data, or private messages. Before taking broad fullscreen screenshots or starting recording, prefer the narrowest region that satisfies the task.

The `*-to-file` helpers clear the clipboard before capture so they can detect the new image reliably. Mention this if clipboard preservation matters.

## Coordinates

CleanShot’s area coordinates use point `(0,0)` at the lower-left corner of the screen. `display=1` is the main display, `display=2` the secondary display, etc. When no display is specified, CleanShot uses the display containing the cursor.

## When to load more detail

- For a full command/parameter table, read `references/cleanshot-url-api.md`.
- For Codex and Claude Code installation notes, read `README.md`.
- For task recipes and examples, read `references/agent-workflows.md`.
- For constraints and edge cases, read `references/limitations-and-troubleshooting.md`.
