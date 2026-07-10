# CleanShot X Automation Agent Skill

This is an Agent Skills-compatible package for controlling **CleanShot X** from Codex, Claude Code, and other filesystem-based agent runtimes on a local Mac.

It provides:

- `SKILL.md` instructions for agent routing and safe use.
- `scripts/cleanshotx`, a small macOS helper CLI that opens CleanShot URL-scheme commands.
- AppleScript helpers for saving CleanShot clipboard captures to deterministic file paths.
- Reference docs covering the CleanShot URL API, agent workflows, limitations, and troubleshooting.

## Requirements

- macOS with a logged-in graphical desktop session.
- CleanShot X installed.
- CleanShot X API enabled: **CleanShot X Settings → Advanced → API → Allow Applications to control CleanShot**.
- macOS permissions for CleanShot X: Screen Recording, and any microphone/camera/system audio permissions needed for recording.
- For the helper scripts: `/usr/bin/open`, `/usr/bin/osascript`, `/usr/bin/pbpaste`, and `/usr/bin/sips` are used. These are standard macOS tools.

This does not work in a headless or cloud-only agent environment. The agent must be able to run shell commands on the user’s Mac.

## Install for Claude Code

From the unzipped package root:

```bash
./install.sh --claude
```

Manual equivalent:

```bash
mkdir -p ~/.claude/skills
cp -R cleanshot-x-automation ~/.claude/skills/cleanshot-x-automation
chmod +x ~/.claude/skills/cleanshot-x-automation/scripts/cleanshotx
```

Claude Code can then invoke the skill automatically when a task matches the description, or directly with `/cleanshot-x-automation`.

## Install for Codex

From the unzipped package root:

```bash
./install.sh --codex
```

Manual equivalent:

```bash
mkdir -p ~/.agents/skills
cp -R cleanshot-x-automation ~/.agents/skills/cleanshot-x-automation
chmod +x ~/.agents/skills/cleanshot-x-automation/scripts/cleanshotx
```

For a repository-scoped install, copy the folder into:

```text
<repo>/.agents/skills/cleanshot-x-automation/
```

## Install for both

```bash
./install.sh --both
```

## Smoke test

```bash
~/.claude/skills/cleanshot-x-automation/scripts/cleanshotx status
# or
~/.agents/skills/cleanshot-x-automation/scripts/cleanshotx status
```

Open CleanShot’s Advanced settings if the API still needs to be enabled:

```bash
scripts/cleanshotx open-settings --tab advanced
```

Take a deterministic screenshot file:

```bash
mkdir -p /tmp/cleanshot-agent
scripts/cleanshotx capture-fullscreen-to-file --output /tmp/cleanshot-agent/fullscreen.png --timeout 30
```

OCR an image:

```bash
scripts/cleanshotx ocr-file --file /tmp/cleanshot-agent/fullscreen.png --output /tmp/cleanshot-agent/fullscreen.txt
```

Open recording mode for a fixed region:

```bash
scripts/cleanshotx record-screen --x 100 --y 120 --width 1280 --height 720 --display 1
```

## Important limitations

CleanShot X exposes a URL scheme API rather than a conventional command-line binary. The helper CLI is a wrapper around that API. URL calls launch GUI workflows and usually return immediately; they do not return structured JSON status from CleanShot.

The URL API documents how to open Record Screen mode, including a preselected region, but it does not document a URL parameter to start, stop, pause, or save a recording to an exact path. Screenshot-to-file is implemented by using `action=copy` and saving the resulting clipboard image.

Avoid `action=upload` unless the user explicitly wants to upload to CleanShot Cloud.

## Package layout

```text
cleanshot-x-automation/
├── SKILL.md
├── README.md
├── install.sh
├── scripts/
│   ├── cleanshotx
│   └── clipboard-image-to-file.applescript
├── references/
│   ├── cleanshot-url-api.md
│   ├── agent-workflows.md
│   └── limitations-and-troubleshooting.md
├── examples/
│   ├── AGENTS.md
│   ├── CLAUDE.md
│   └── prompts.md
└── agents/
    └── openai.yaml
```

## Research sources

The CleanShot X URL scheme API is documented by CleanShot at `https://cleanshot.com/docs-api`. Claude Code and Codex both support Agent Skills-style folders with a `SKILL.md` entrypoint. See the references directory for summarized command coverage and operational caveats.
