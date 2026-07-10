---
name: cleanshot-x-automation
description: Control CleanShot X on a local macOS desktop via its URL scheme. Use for taking fullscreen/area/window screenshots, saving captures to files through a clipboard helper, opening screen recording mode, running OCR, annotating/pinning images, adding Quick Access Overlay items, opening history/settings, and toggling desktop icons when the user wants an agent to capture or inspect the Mac screen with CleanShot X.
compatibility: Requires macOS with a graphical login session and CleanShot X installed, with its URL scheme API enabled (Settings → Advanced → API → Allow Applications to control CleanShot). Uses /usr/bin open, osascript, pbpaste, sips, and awk; display-info additionally uses Swift. Does not work headless, over SSH without a GUI, or in cloud sandboxes.
license: MIT
metadata:
  version: "1.1.0"
  source: https://github.com/jrajasekera/cleanshot-x-automation
---

# CleanShot X Automation

Use this skill only when running on the user's local macOS graphical session where CleanShot X is installed. It will not work in a headless Linux container, remote cloud sandbox, or SSH session without GUI access.

## Start with the bundled helper

Run the helper from the skill directory:

```bash
${CLAUDE_SKILL_DIR:-.}/scripts/cleanshotx status
${CLAUDE_SKILL_DIR:-.}/scripts/cleanshotx display-info
# Only when the URL/clipboard path is uncertain:
${CLAUDE_SKILL_DIR:-.}/scripts/cleanshotx doctor --smoke-test
${CLAUDE_SKILL_DIR:-.}/scripts/cleanshotx capture-fullscreen-to-file --output /tmp/cleanshot-fullscreen.png --timeout 30
${CLAUDE_SKILL_DIR:-.}/scripts/cleanshotx capture-area-to-file --x 100 --y 120 --width 800 --height 600 --display 1 --output /tmp/cleanshot-area.png --timeout 30
${CLAUDE_SKILL_DIR:-.}/scripts/cleanshotx ocr-file --file /tmp/cleanshot-area.png --output /tmp/cleanshot-area.txt --timeout 30
```

For Codex, replace `${CLAUDE_SKILL_DIR:-.}` with the installed skill path, usually `~/.agents/skills/cleanshot-x-automation` or the repository path `.agents/skills/cleanshot-x-automation`.

`status` checks the static environment. `doctor --smoke-test` performs a small unattended fixed-area capture and verifies the URL-scheme-to-clipboard-to-file path without retaining the temporary image. A clipboard timeout alone does not prove that the API setting is disabled.

If the smoke test fails after any visible selector has been cancelled, open CleanShot settings and confirm **Settings → Advanced → API → Allow Applications to control CleanShot**:

```bash
scripts/cleanshotx open-settings --tab advanced
```

## Choose unattended or interactive capture deliberately

- `capture-fullscreen-to-file`, `capture-previous-area-to-file`, and `capture-area-to-file` with all of `x`, `y`, `width`, and `height` are unattended.
- `capture-window-to-file` always opens a selector and requires the user or a UI-driving tool to click a window.
- `capture-area-to-file` without a complete rectangle also requires a visible selection.
- Prefer fixed rectangles for unattended agent workflows. If an interactive capture times out, press Escape to cancel its selector before issuing another capture.

## Core workflow for screenshots the agent must inspect

1. Run `doctor --smoke-test` once when the URL/clipboard path is uncertain.
2. Run `display-info` before calculating screen coordinates.
3. Prefer a complete fixed rectangle for unattended captures.
4. If the page or app was resized, navigated, or switched into a responsive viewport, wait for it to repaint before invoking CleanShot. `--wait-ms 1200` is a useful fallback when no readiness signal exists.
5. Move both the macOS pointer and any browser-automation pointer outside the target region when clean screenshots matter.
6. Inspect every final image. Correct dimensions do not detect blank, loading, permission-prompt, or stale frames.

The wrappers call CleanShot with `action=copy`, clear the clipboard first, wait for a new image, verify that the saved file is readable, and optionally enforce pixel dimensions:

```bash
scripts/cleanshotx capture-area-to-file \
  --x 0 --y 0 --width 390 --height 844 --display 1 \
  --wait-ms 1200 \
  --expect-pixel-width 780 --expect-pixel-height 1688 \
  --output /tmp/cleanshot-agent/mobile.png
```

Use absolute output paths when possible. After saving, inspect the image with the available image-reading tool. Use CleanShot OCR only when text extraction is needed or image vision is unavailable.

Examples:

```bash
mkdir -p /tmp/cleanshot-agent
scripts/cleanshotx capture-fullscreen-to-file --output /tmp/cleanshot-agent/screen.png
scripts/cleanshotx capture-area-to-file --x 0 --y 0 --width 1440 --height 900 --display 1 --output /tmp/cleanshot-agent/area.png
scripts/cleanshotx capture-window-interactive-to-file --output /tmp/cleanshot-agent/window.png --timeout 120
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

CleanShot’s area coordinates are logical display points with `(0,0)` at the lower-left corner. `display=1` is the main display, `display=2` the secondary display, and so on. When omitted, CleanShot uses the display containing the cursor.

Retina output is commonly larger than the requested rectangle: a 390 × 844 point region at 2× backing scale produces a 780 × 1688 PNG. Use `display-info` to get logical bounds and capture pixel scale; do not infer geometry from a resized app screenshot or ask Finder for desktop bounds, which can trigger an Apple Events permission prompt.

## When to load more detail

- For a full command/parameter table, read `references/cleanshot-url-api.md`.
- For Codex and Claude Code installation notes, read `README.md`.
- For task recipes and examples, read `references/agent-workflows.md`.
- For constraints and edge cases, read `references/limitations-and-troubleshooting.md`.
