My name is Joaquín Alori, I am a developer from Uruguay, working on several projects.

The biggest project I'm working on now is Mellow, and this is the one I'll usually be refering to if I don't specify.

I also have a ~/.dotfiles project, where I version most of the config files in my machine, including this AGENTS.md file.
Stuff in ~ like .bashrc, .claude/, .codex/, .config, etc.
Most of these configs are just symlinks to their version on ~/.dotfiles, so whenever I ask you to modify some config
like this on my OS, first check if its in my dotfiles.

I also have a project ~/agents which is a wrapper around codex and claude code. All my tools call this cli tool when they need
an agent. No direct calls to claude code or codex are permitted as I want to be able to quickly switch between them and  not
develop a dependency on either of them.

In all interactions be extremely concise and sacrifice grammar for the sake of concision.
You can think however long you want, but when talking to me be concise as I do not have the time to read long descriptions of things.

## My workflow
- Editor: nvim
- Terminal: cmux
- Shell: bash
- Python: uv
- Git: commit message titles below 72 chars.

## Dev servers
Dev servers like vite, expo, next, etc should always start in a new cmux tab (not workspace).
Create with `cmux new-surface --type terminal --pane <current-pane>`, rename with `cmux rename-tab --surface <ref> "name"`,
send command with `cmux send --surface <ref> "command\n"`. Use descriptive names like `vite-dev`, `expo-dev`.

## Browser Automation
All browser automation uses **cmux browser** - never Chrome MCP, Chrome DevTools, or `open` commands. Use the `cmux-browser` skill
and `cmux browser` CLI for everything: opening pages, clicking, typing, screenshots, JS eval, waiting.

Never use `select-workspace` for browser commands as `cmux browser <surface> screenshot/eval/snapshot/get` all work on unfocused workspaces.
Never call `cmux select-workspace` before browser commands. It's a global UI operation that steals the user's focus and disrupts parallel agents.

When testing mobile web UI, resize the cmux browser pane to ~390px width. Do this automatically when the task involves mobile web layout/UI.
Also `cmux resize-pane` only supports relative `--amount` (no absolute sizing). Always check current width first and calculate the delta to avoid
overshrinking to 0px (which permanently breaks the surface).

```bash
# 1. Open browser - note source_pane_ref (terminal) from JSON output
cmux --json browser open <url>

# 2. Check current width and calculate delta
current=$(cmux browser <surface> eval "window.innerWidth")
delta=$((current - 390))

# 3. Expand the TERMINAL pane rightward to shrink the browser pane
cmux resize-pane --pane <terminal-pane-ref> -R --amount $delta

# 4. Verify
cmux browser <surface> eval "window.innerWidth"
# Should be ~390. Adjust if needed.
```

For desktop layout testing, don't resize - the default split is already desktop-width.


## Skills Sync
Global authored skills live in `~/.dotfiles/skills`.
Do not add authored skills under `.claude/skills`, `.codex/skills`, or `.agents/skills`. Those are generated install targets.
When creating or deleting a global skill, run:
```bash
npx --yes skills add ~/.dotfiles/skills -g -a claude-code -a codex -y
```
Editing an existing skill file does not require a resync. Creating, deleting, renaming, or adding/removing files inside a skill directory does.
