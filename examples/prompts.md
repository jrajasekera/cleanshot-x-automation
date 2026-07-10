# Example Prompts

## Claude Code

```text
/cleanshot-x-automation Take a CleanShot screenshot of my current app, save it to /tmp/cleanshot-agent/app.png, inspect it, and tell me why the layout looks wrong.
```

```text
Use CleanShot X to OCR the error message currently visible on my screen. Prefer a selected region rather than the whole screen.
```

```text
Open CleanShot X recording mode for a 1280x720 region starting at x=100 y=120 on my main display.
```

## Codex

```text
Use the cleanshot-x-automation skill to capture my current screen to a file, inspect the image, and summarize the visible UI state. Do not upload anything.
```

```text
With CleanShot X, recapture the previous area to /tmp/cleanshot-agent/after.png and compare it with /tmp/cleanshot-agent/before.png.
```

```text
Use CleanShot X OCR on /tmp/cleanshot-agent/screen.png and save the text next to it.
```

```text
Use the CleanShot X skill to capture a responsive browser matrix at exact output sizes. Check whether each canvas fits the physical display first, use a virtual browser renderer when it does not, verify every image's dimensions, and create contact sheets without modifying any source screenshot.
```
