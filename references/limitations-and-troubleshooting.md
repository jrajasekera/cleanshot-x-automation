# Limitations and Troubleshooting

## CleanShot app does not respond to commands

Likely causes:

1. CleanShot X is not installed.
2. CleanShot API access is disabled.
3. The command is being run from a non-macOS environment or headless session.
4. macOS privacy permissions are missing.

Run:

```bash
scripts/cleanshotx status
scripts/cleanshotx open-settings --tab advanced
```

Then enable:

```text
CleanShot X Settings → Advanced → API → Allow Applications to control CleanShot
```

## `capture-*-to-file` saves the wrong/stale image

The helper clears the clipboard before invoking CleanShot, which should prevent stale image capture. If this still happens:

- Increase `--timeout`.
- Make sure the user completed interactive selection after the command started.
- Check that CleanShot’s `action=copy` is not overridden by an app preset.
- Use fixed rectangle parameters for non-interactive captures.

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

CleanShot coordinates use lower-left origin, not upper-left. Also confirm the display index:

- `display=1`: main display
- `display=2`: secondary display

If `display` is omitted, CleanShot uses the display where the cursor is located.

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
