# Agent Workflows for CleanShot X

Use these recipes from Codex, Claude Code, or any agent that can run local shell commands on the user’s Mac.

## Before the first unattended capture

Use the smoke test when the URL scheme or clipboard handoff has not been verified in the current environment:

```bash
"$SKILL_DIR/scripts/cleanshotx" doctor --smoke-test
"$SKILL_DIR/scripts/cleanshotx" display-info
```

The smoke test uses a small fixed rectangle and is unattended. Do not use window capture as a connectivity test because it opens a selector and waits for a user click.

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
"$SKILL_DIR/scripts/cleanshotx" capture-window-interactive-to-file --output /tmp/cleanshot-agent/window.png --timeout 120
```

This is interactive. Tell the user that CleanShot is waiting for a window selection. If it times out, cancel the selector with Escape before issuing another capture command.

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

## 15. Capture a responsive browser viewport matrix

Use this sequence for desktop, wide-desktop, and mobile variants:

1. Query `display-info`, then run `plan-exact-capture` for every requested pixel canvas.
2. Derive responsive CSS/logical viewport dimensions separately from output pixels. A 1280-pixel phone width may be 640 CSS pixels at 2x DPR; using 1280 CSS pixels would select a desktop breakpoint.
3. If the plan recommends `cleanshot-fixed-area`, position a complete physical rectangle and use CleanShot. If it recommends `virtual-renderer`, do not try to force the canvas through CleanShot; use the browser's supported virtual renderer and record the actual capture mechanism.
4. Calibrate one image before the batch and enforce its exact pixel dimensions. High-level browser screenshot APIs can clip browser chrome or return a canvas smaller than the reported inner viewport; use a supported raw DevTools capture only when the browser's normal screenshot path fails calibration.
5. Wait for navigation, loading indicators, responsive layout, images, and video tiles to settle. Prefer a concrete ready signal; when none exists, use a short delay and inspect the result.
6. Move the browser-control pointer to a deliberate non-content location after the final click. Moving only the macOS pointer may leave a separate automation pointer visible. If the control surface always renders a pointer, leave the image unedited and note the limitation.
7. Capture all originals before generating contact sheets or derivatives.
8. Validate every batch with `verify-images`.
9. Generate contact sheets only with the atomic `contact-sheet` helper, placing its output outside the source-capture directories.
10. Inspect the saved images for blank/loading frames, permission dialogs, stale content, cursor placement, and unexpected browser banners.
11. Repeat for each viewport, then reset browser device metrics and restore the original page.

Physical-fit example:

```bash
"$SKILL_DIR/scripts/cleanshotx" plan-exact-capture \
  --pixel-width 1280 --pixel-height 2856 \
  --device-pixel-ratio 2 --display 1
```

If this reports `recommended_capture_path: virtual-renderer`, CleanShot can still be used to verify its own API and the physical display, but it cannot be described as the tool that produced the final off-screen image.

Example for a 390 × 844 point mobile viewport on a 2× Retina display:

```bash
"$SKILL_DIR/scripts/cleanshotx" capture-area-to-file \
  --x 0 --y 64 --width 390 --height 844 --display 1 \
  --wait-ms 1200 \
  --expect-pixel-width 780 --expect-pixel-height 1688 \
  --output /tmp/cleanshot-agent/mobile.png
```

The `y` offset is environment-specific. Derive it from the current logical display bounds and the actual viewport position; do not copy the example offset blindly.

After a batch:

```bash
"$SKILL_DIR/scripts/cleanshotx" verify-images \
  --expect-pixel-width 780 --expect-pixel-height 1688 \
  /tmp/cleanshot-agent/mobile/*.png

"$SKILL_DIR/scripts/cleanshotx" contact-sheet \
  --output /tmp/cleanshot-agent/mobile-contact.png \
  /tmp/cleanshot-agent/mobile/*.png
```

The contact-sheet helper requires ImageMagick and deliberately refuses source/output collisions. Never place a raw montage output argument before an input list or let a QA command write back into the original capture glob.

The URL API opens/restores UI state; it does not list or export history records as structured data.

## 16. Use raw URL mode for future CleanShot endpoints

If CleanShot adds new URL commands before this skill is updated, use raw mode:

```bash
scripts/cleanshotx url new-command key=value other=/path/to/file --print-url
```

This builds and opens:

```text
cleanshot://new-command?key=value&other=/path/to/file
```

## 17. Agent decision tree

1. Need a file to inspect? Use a `*-to-file` helper.
2. Need user markup? Use `capture-* --action annotate` or `open-annotate --file`.
3. Need text? Use `ocr-file` or `ocr-area`.
4. Need recording? Use `record-screen` to open/preselect mode, then explain that CleanShot’s documented API does not fully automate start/stop/save.
5. Need cloud sharing? Use `--action upload` only when the user explicitly requests an upload.
6. Need CleanShot settings? Use `open-settings --tab ...`.
7. Need an exact or responsive pixel matrix? Run `plan-exact-capture` first, calibrate one output, and validate batches with `verify-images`.
8. Need a contact sheet? Use `contact-sheet`; do not hand-roll an ImageMagick montage over source files.
