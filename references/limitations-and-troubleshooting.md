# Limitations and Troubleshooting

## CleanShot app does not respond to commands

Likely causes:

1. CleanShot X is not installed.
2. CleanShot API access is disabled.
3. The command is being run from a non-macOS environment or headless session.
4. macOS privacy permissions are missing.

First cancel any visible area/window selector with Escape. Then run a real unattended test:

```bash
scripts/cleanshotx status
scripts/cleanshotx doctor --smoke-test
scripts/cleanshotx open-settings --tab advanced
```

Then enable:

```text
CleanShot X Settings → Advanced → API → Allow Applications to control CleanShot
```

A `capture-window-to-file` timeout is not an API test: window capture is interactive and will wait until a window is selected. A clipboard timeout only means that no new image arrived; it does not identify the cause by itself.

## A later fixed capture does nothing after a timeout

An interactive selector from an earlier area or window capture may still be active. Press Escape to cancel it before retrying. Use `doctor --smoke-test` to confirm unattended capture separately.

## `capture-*-to-file` saves the wrong/stale image

The helper clears the clipboard before invoking CleanShot, which should prevent stale image capture. If this still happens:

- Increase `--timeout`.
- Make sure the user completed interactive selection after the command started.
- Check that CleanShot’s `action=copy` is not overridden by an app preset.
- Use fixed rectangle parameters for non-interactive captures.
- Wait for the target application to repaint after navigation or viewport changes.
- Inspect the final image; successful file and dimension checks cannot identify a blank or loading frame.

## The agent cannot see the screenshot file

Use absolute paths in a directory the agent can access, such as `/tmp/cleanshot-agent/screen.png` or a project-local `.tmp/cleanshot/screen.png`.

Some agent environments are sandboxed. The command must run on the Mac host, not inside a container without GUI/clipboard access.

## OCR times out

OCR through CleanShot returns text via clipboard behavior. If the result is empty, the helper waits and eventually times out.

Try:

- Use `--linebreaks true`.
- OCR a smaller, clearer region.
- First capture the region to a file, inspect the image, then run `ocr-file` on that file.
- Confirm CleanShot has permissions and that macOS OCR supports the text language.

## Screen recording is not fully automated

The documented URL endpoint is `/record-screen`. It opens Record Screen mode and accepts rectangle/display parameters. The docs do not list parameters for unattended start, stop, pause, or output path. Use CleanShot’s UI or shortcuts after opening recording mode.

Do not represent CleanShot recording as fully automatable unless the installed CleanShot version documents a newer API.

## `action=save` does not save where expected

The URL API’s `save` action follows CleanShot’s own settings. It does not document an output path parameter. For deterministic output, use:

```bash
scripts/cleanshotx capture-fullscreen-to-file --output /tmp/screen.png
```

This uses `action=copy` and saves from the clipboard.

## `action=upload` privacy risk

`upload` sends media to CleanShot Cloud. Use it only with explicit user consent and only for content safe to share.

## Coordinates are off

Run `scripts/cleanshotx display-info` instead of inferring display geometry from an app screenshot or asking Finder for desktop bounds. Finder automation can trigger an unrelated Apple Events permission prompt.

CleanShot coordinates are logical display points and use lower-left origin, not upper-left. Also confirm the display index:

- `display=1`: main display
- `display=2`: secondary display

If `display` is omitted, CleanShot uses the display where the cursor is located.

On Retina displays, output pixel dimensions are commonly the logical rectangle multiplied by the backing scale. For example, a 400 × 300 point capture produces an 800 × 600 PNG at 2× scale. Use `--expect-pixel-width` and `--expect-pixel-height` when exact output size matters.

## An exact virtual viewport is larger than the physical display

Run the fit planner before capture:

```bash
scripts/cleanshotx plan-exact-capture \
  --pixel-width 1280 --pixel-height 2856 \
  --device-pixel-ratio 2 --display 1
```

The command converts requested output pixels to required logical points using the intended device DPR. It permits fixed CleanShot capture only when the logical canvas fits and the target DPR matches the physical display backing scale. If it recommends `virtual-renderer`, a physical CleanShot capture would clip, scale, or render the wrong pixel density. Use the browser or app's supported virtual rendering path, calibrate a single output, verify every file, and document that CleanShot did not generate the final off-screen pixels.

Do not confuse output pixels with responsive CSS width. For example, a 1280-pixel phone image can represent a 640-CSS-pixel viewport at 2x DPR. Using 1280 CSS pixels may select a desktop layout.

## A cursor appears even after moving the macOS pointer

Browser-control and computer-use tools may render or track their own automation pointer independently of the macOS pointer. Move that pointer through the same browser/UI-control surface after the final interaction and before capture. Put it in a deliberate non-content area; moving to a virtual viewport edge can still leave it inside the screenshot. CleanShot cursor inclusion also follows the user's CleanShot screenshot settings.

Some browser surfaces always include the automation pointer. If it cannot be hidden, leave the capture unedited, place the pointer predictably, and disclose the limitation. Retouching the pointer can alter evidence and should not be the default.

## Responsive capture is blank or partially rendered

Responsive apps can briefly clear or rebuild their layout after a viewport change. Wait for a concrete ready signal where possible; otherwise add `--wait-ms 1200` or a similar short delay. Validate dimensions and visually inspect every final viewport image.

## Browser screenshot dimensions do not match the viewport

A browser may report the requested inner viewport but its high-level screenshot API can still exclude browser UI or clip the surface. Make one calibration capture before a batch and validate it with `verify-images`. If it is wrong, use the browser's documented lower-level capture path, such as DevTools `Page.captureScreenshot`, and validate again before continuing.

## Contact-sheet generation overwrote a source image

Do not invoke ImageMagick montage directly over capture globs. A misplaced output argument can make the last input file become the output. Use the guarded helper:

```bash
scripts/cleanshotx contact-sheet \
  --output /tmp/capture-contact.png \
  /path/to/original-captures/*.png
```

The helper requires ImageMagick, refuses input/output collisions, refuses an existing output unless `--force` is explicit, supplies the macOS system font when available, writes to a temporary file, validates the result, and moves it into place atomically. Follow contact-sheet creation with `verify-images` on the original batch so derivative QA cannot silently damage the source set.

## URL encoding

Use `--file` or `--filepath` rather than hand-building URLs. The helper URL-encodes spaces and special characters.

Raw mode is available but less safe:

```bash
scripts/cleanshotx url open-annotate filepath=/Users/me/Desktop/my\ screenshot.png
```

## App bundle ID lookup

The helper uses AppleScript:

```bash
osascript -e 'id of application "CleanShot X"'
```

This may fail if the app is not installed under the expected name. The URL scheme can still work if CleanShot registered `cleanshot://` correctly.

## Re-enable desktop icons after failure

When hiding icons for a clean capture, use cleanup logic:

```bash
set -e
scripts/cleanshotx hide-desktop-icons
trap 'scripts/cleanshotx show-desktop-icons >/dev/null 2>&1 || true' EXIT
scripts/cleanshotx capture-fullscreen-to-file --output /tmp/clean.png
```
