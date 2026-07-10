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
- CleanShot X URL scheme API enabled (recommended): **CleanShot X Settings → Advanced → API → Allow Applications to control CleanShot**. Some CleanShot versions accept `cleanshot://` commands even with this off, but enabling it is the supported configuration.
- macOS permissions for CleanShot X: Screen Recording, and any microphone/camera/system audio permissions needed for recording.
- For the helper scripts: `/usr/bin/open`, `/usr/bin/osascript`, `/usr/bin/pbpaste`, and `/usr/bin/sips` are used. These are standard macOS tools.

This does not work in a headless or cloud-only agent environment. The agent must be able to run shell commands on the user’s Mac.

## Installing the skill

A skill is just a directory — there is no special installer format in the Agent
Skills spec. To install it, place this folder where your agent scans for skills.
The directory **must** be named `cleanshot-x-automation` so it matches the `name`
field in `SKILL.md`.

### Standard install (any agent)

Clone (or copy) this repo directly into a skills directory:

| Agent | User-level location |
|-------|---------------------|
| Codex, VS Code Copilot, and other Agent Skills clients | `~/.agents/skills/cleanshot-x-automation` |
| Claude Code | `~/.claude/skills/cleanshot-x-automation` |

```bash
# Cross-client (Codex, VS Code, ...)
git clone https://github.com/jrajasekera/cleanshot-x-automation.git \
  ~/.agents/skills/cleanshot-x-automation

# Claude Code
git clone https://github.com/jrajasekera/cleanshot-x-automation.git \
  ~/.claude/skills/cleanshot-x-automation
```

For a **project-scoped** install (shared through a repo), place the folder under
the repo root in `.agents/skills/cleanshot-x-automation/` (cross-client) or
`.claude/skills/cleanshot-x-automation/` (Claude Code) instead of your home
directory.

Once installed, agents load the skill automatically when a task matches its
description. Claude Code also lets you invoke it explicitly with
`/cleanshot-x-automation`.

### Optional: the `install.sh` helper

If you already have the repo checked out, `install.sh` is a convenience wrapper
that copies or symlinks it into the right place and guarantees the directory
name. It is not required — the clone commands above do the same thing.

```bash
./install.sh --both          # copy into ~/.agents/skills and ~/.claude/skills
./install.sh --link --both   # symlink instead; git pull then propagates updates
./install.sh --agents        # cross-client only (~/.agents/skills)
./install.sh --claude        # Claude Code only (~/.claude/skills)
./install.sh --project .     # into ./.agents/skills for the current repo
```

`--link` is handy for development: the installed skill points back at your
checkout, so `git pull` updates it in place.

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
├── SKILL.md          # required: frontmatter metadata + agent instructions
├── README.md
├── install.sh        # optional convenience installer
├── scripts/
│   ├── cleanshotx
│   └── clipboard-image-to-file.applescript
├── references/
│   ├── cleanshot-url-api.md
│   ├── agent-workflows.md
│   └── limitations-and-troubleshooting.md
└── examples/
    ├── AGENTS.md
    ├── CLAUDE.md
    └── prompts.md
```

## Research sources

The CleanShot X URL scheme API is documented by CleanShot at `https://cleanshot.com/docs-api`. Claude Code and Codex both support Agent Skills-style folders with a `SKILL.md` entrypoint. See the references directory for summarized command coverage and operational caveats.
