# CleanShot X Agent Instructions for Claude Code

Use `/cleanshot-x-automation` or allow Claude Code to load the skill automatically when the user asks for CleanShot X screenshots, OCR, annotations, pins, history, settings, desktop icon toggles, or recording setup.

Typical screenshot workflow:

```bash
SKILL_DIR="${CLAUDE_SKILL_DIR:-$HOME/.claude/skills/cleanshot-x-automation}"
mkdir -p /tmp/cleanshot-agent
"$SKILL_DIR/scripts/cleanshotx" capture-fullscreen-to-file --output /tmp/cleanshot-agent/screen.png --timeout 30
```

Then view/read `/tmp/cleanshot-agent/screen.png` using available multimodal tools.

Keep captures private. Avoid Cloud upload unless requested.

For exact responsive matrices, run `plan-exact-capture` before capture, keep CSS/logical viewport dimensions separate from DPR-scaled output pixels, calibrate one image per capture mechanism, validate batches with `verify-images`, and use the guarded `contact-sheet` helper for derivatives. If a requested canvas does not fit the physical display, use a supported virtual renderer and report that CleanShot did not produce the final pixels.
