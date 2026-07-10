# CleanShot X URL Scheme API Reference

Researched: 2026-07-10
Primary source: https://cleanshot.com/docs-api

CleanShot X exposes a URL scheme API. Construct URLs as:

```text
cleanshot://command-name?parameter1=value1&parameter2=value2
```

Open with macOS `open`:

```bash
open "cleanshot://capture-fullscreen"
```

The bundled helper wraps this:

```bash
scripts/cleanshotx capture-fullscreen --action save
scripts/cleanshotx url capture-fullscreen action=save
```

## Important setup

Enable CleanShot’s API setting first:

```text
CleanShot X Settings → Advanced → API → Allow Applications to control CleanShot
```

The helper can open that settings pane:

```bash
scripts/cleanshotx open-settings --tab advanced
```

## Command table

### All-In-One

Command: `/all-in-one`

Purpose: Launch All-In-One mode. Optional rectangle parameters open the tool at a specific location.

Parameters:

- `x` optional
- `y` optional
- `width` optional
- `height` optional
- `display` optional, where `1` is main display, `2` is secondary, etc.

Examples:

```bash
scripts/cleanshotx all-in-one
scripts/cleanshotx all-in-one --x 100 --y 120 --width 800 --height 600 --display 1
```

Version notes from CleanShot docs: command requires CleanShot 4.2 or later; rectangle/display parameters require 4.7 or later.

### Capture Area

Command: `/capture-area`

Purpose: Open Capture Area mode, or capture an instant rectangle when all rectangle parameters are supplied.

Parameters:

- `x` optional
- `y` optional
- `width` optional
- `height` optional
- `display` optional
- `action` optional: `copy`, `save`, `annotate`, `upload`, or `pin`

Examples:

```bash
scripts/cleanshotx capture-area
scripts/cleanshotx capture-area --action annotate
scripts/cleanshotx capture-area --x 100 --y 120 --width 800 --height 600 --display 1 --action copy
scripts/cleanshotx capture-area-to-file --x 100 --y 120 --width 800 --height 600 --display 1 --output /tmp/area.png
```

Version notes: command requires 3.5.1 or later; `action` requires 4.7 or later.

### Capture Previous Area

Command: `/capture-previous-area`

Purpose: Repeat the last screenshot area.

Parameters:

- `action` optional: `copy`, `save`, `annotate`, `upload`, or `pin`

Examples:

```bash
scripts/cleanshotx capture-previous-area --action copy
scripts/cleanshotx capture-previous-area-to-file --output /tmp/previous-area.png
```

Version notes: command requires 3.5.1 or later; `action` requires 4.7 or later.

### Capture Fullscreen

Command: `/capture-fullscreen`

Purpose: Take a fullscreen screenshot.

Parameters:

- `action` optional: `copy`, `save`, `annotate`, `upload`, or `pin`

Examples:

```bash
scripts/cleanshotx capture-fullscreen --action save
scripts/cleanshotx capture-fullscreen-to-file --output /tmp/fullscreen.png
```

Version notes: command requires 3.5.1 or later; `action` requires 4.7 or later.

### Capture Window

Command: `/capture-window`

Purpose: Open Capture Window mode.

Parameters:

- `action` optional: `copy`, `save`, `annotate`, `upload`, or `pin`

Examples:

```bash
scripts/cleanshotx capture-window --action annotate
scripts/cleanshotx capture-window-to-file --output /tmp/window.png
```

Version notes: command requires 3.5.1 or later; `action` requires 4.7 or later.

### Self Timer

Command: `/self-timer`

Purpose: Open Capture Area mode with self-timer.

Parameters:

- `action` optional: `copy`, `save`, `annotate`, `upload`, or `pin`

Example:

```bash
scripts/cleanshotx self-timer --action save
```

Version notes: command requires 3.5.1 or later; `action` requires 4.7 or later.

### Scrolling Capture

Command: `/scrolling-capture`

Purpose: Open Scrolling Capture mode; optionally preselect an area and start/autoscroll.

Parameters:

- `x` optional
- `y` optional
- `width` optional
- `height` optional
- `display` optional
- `start` optional: `true` or `false`
- `autoscroll` optional: `true` or `false`

Examples:

```bash
scripts/cleanshotx scrolling-capture
scripts/cleanshotx scrolling-capture --x 100 --y 120 --width 800 --height 600 --display 1 --start true --autoscroll true
```

Version notes: command requires 3.5.1 or later; `start` and `autoscroll` require 4.7 or later. CleanShot changelog notes a 2025 fix for scrolling capture starting via URL scheme API, so keep CleanShot updated if this command is flaky.

### Pin

Command: `/pin`

Purpose: Open a PNG/JPEG image as a pinned floating screenshot. If no path is passed, CleanShot asks the user to choose a file.

Parameters:

- `filepath` optional: image path

Examples:

```bash
scripts/cleanshotx pin --file /tmp/screen.png
scripts/cleanshotx pin
```

Version notes: command requires 3.5.1 or later.

### Record Screen

Command: `/record-screen`

Purpose: Open Record Screen mode; optional rectangle parameters can preselect an area.

Parameters:

- `x` optional
- `y` optional
- `width` optional
- `height` optional
- `display` optional

Examples:

```bash
scripts/cleanshotx record-screen
scripts/cleanshotx record-screen --x 100 --y 120 --width 1280 --height 720 --display 1
```

Version notes: command requires 3.5.1 or later; rectangle/display parameters require 4.7 or later.

Automation limitation: the CleanShot URL documentation does not list start, stop, pause, or output-path parameters for recording. Treat recording as a GUI-assisted workflow unless newer docs add those controls.

### Capture Text / OCR

Command: `/capture-text`

Purpose: Open the OCR tool, extract text from an image file, or OCR a specified area on screen.

Parameters:

- `filepath` optional: PNG/JPEG image path containing text
- `x` optional
- `y` optional
- `width` optional
- `height` optional
- `display` optional
- `linebreaks` optional: `true` to keep line breaks, `false` to remove them

Examples:

```bash
scripts/cleanshotx capture-text
scripts/cleanshotx capture-text --file /tmp/screen.png --linebreaks true
scripts/cleanshotx ocr-file --file /tmp/screen.png --output /tmp/screen.txt --linebreaks true
scripts/cleanshotx ocr-area --x 100 --y 120 --width 800 --height 600 --display 1 --output /tmp/ocr.txt
```

Version notes: command requires CleanShot 3.8.1 and macOS 10.15 or later.

### Open Annotate

Command: `/open-annotate`

Purpose: Open a specified image in CleanShot Annotate. If no path is passed, CleanShot asks the user to select a file.

Parameters:

- `filepath` optional: PNG/JPEG image path

Examples:

```bash
scripts/cleanshotx open-annotate --file /tmp/screen.png
scripts/cleanshotx annotate --file /tmp/screen.png
```

Version notes: command requires 3.8.1 or later.

### Open From Clipboard

Command: `/open-from-clipboard`

Purpose: Open the image currently on the clipboard in CleanShot Annotate.

Example:

```bash
scripts/cleanshotx open-from-clipboard
```

Version notes: command requires 3.5.1 or later.

### Desktop Icons

Commands:

- `/toggle-desktop-icons`
- `/hide-desktop-icons`
- `/show-desktop-icons`

Purpose: Toggle, hide, or show desktop icons.

Examples:

```bash
scripts/cleanshotx hide-desktop-icons
scripts/cleanshotx show-desktop-icons
scripts/cleanshotx desktop-icons hide
scripts/cleanshotx desktop-icons toggle
```

Version notes: toggle requires 3.5.1 or later; hide/show require 3.8.1 or later.

### Quick Access Overlay

Command: `/add-quick-access-overlay`

Purpose: Add an image or video to CleanShot’s Quick Access Overlay.

Parameters:

- `filepath` required: PNG, JPEG, or MP4 path

Examples:

```bash
scripts/cleanshotx add-quick-access-overlay --file /tmp/screen.png
scripts/cleanshotx quick-access --file /tmp/demo.mp4
```

Version notes: command requires 3.8.1 or later.

### History Management

Commands:

- `/open-history`
- `/restore-recently-closed`

Purpose: Open capture history, or restore the most recently closed file from history.

Examples:

```bash
scripts/cleanshotx open-history
scripts/cleanshotx restore-recently-closed
```

Version notes: open-history requires 4.4 or later; restore-recently-closed requires 3.5.1 or later.

### Settings

Command: `/open-settings`

Purpose: Open CleanShot settings, optionally to a specific tab.

Parameters:

- `tab` optional: `general`, `wallpaper`, `shortcuts`, `quickaccess`, `recording`, `screenshots`, `annotate`, `cloud`, `advanced`, or `about`

Examples:

```bash
scripts/cleanshotx open-settings
scripts/cleanshotx open-settings --tab advanced
scripts/cleanshotx settings --tab recording
```

Version notes: command requires 4.7 or later.

## Coordinate rules

CleanShot’s URL docs state that `(0,0)` is in the lower-left corner of the screen. This differs from many web/browser coordinate systems, which often place `(0,0)` at the upper-left.

Use `display=1` for the main display, `display=2` for the secondary display, etc. If omitted, CleanShot uses the display where the cursor is located.

## Action rules

Where the `action` parameter is supported, valid values are:

- `copy`: copy capture to clipboard
- `save`: save according to CleanShot’s configured save behavior
- `annotate`: open in Annotate
- `upload`: upload to CleanShot Cloud
- `pin`: pin on screen

For deterministic agent file output, use the helper’s `*-to-file` commands rather than `action=save`, because the URL API does not document an output path parameter for screenshots.
