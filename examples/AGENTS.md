# CleanShot X Agent Instructions for Codex

When a task requires observing or documenting the user’s Mac screen with CleanShot X, use the `cleanshot-x-automation` skill.

Preferred command pattern:

```bash
SKILL_DIR="$HOME/.agents/skills/cleanshot-x-automation"
mkdir -p /tmp/cleanshot-agent
"$SKILL_DIR/scripts/cleanshotx" capture-fullscreen-to-file --output /tmp/cleanshot-agent/screen.png --timeout 30
```

Then inspect the image file using available agent tooling.

Rules:

- Do not use `action=upload` unless the user explicitly asks for a CleanShot Cloud upload.
- Prefer region/window captures over fullscreen when the task does not need the whole screen.
- Use `ocr-file` or `ocr-area` for text extraction.
- Treat screen recording as semi-automated. CleanShot’s documented URL API opens recording mode but does not provide start/stop/save controls.
- If commands do nothing, ask the user to enable CleanShot X Settings → Advanced → API → Allow Applications to control CleanShot.
