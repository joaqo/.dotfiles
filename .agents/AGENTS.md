My name is Joaquín Alori, I am a developer from Uruguay, working on several projects.

## Projects
### Mellow (~/mellow)
An ecommerce and loyalty app/web for restaurants located in ~/mellow. The project I'll be refering to if I don't specify.

### Dotfiles (~/.dotfiles)
Where I version most of the config files, agent prompts and little scripts I use. Stuff in ~ like .bashrc, .claude/, .config, etc.
Most of my configs in ~ are just symlinks to their version on ~/.dotfiles, so whenever I ask you to modify some config like this
on my OS, first check if its in ~/.dotfiles and modify it there.

### Agent (~/agent)
A wrapper around codex and claude code. All my tools call this cli tool when they need an agent. No direct calls to claude code
or codex are permitted as I want to be able to quickly switch between them and  not develop a dependency on either of them.
This command is available globally, so the way to invoke an agent is just calling `agent` the terminal.

### (~/task-manager)
A swift macOS app that allows me to create new tasks and manage existing tasks. Tasks are worktrees (in ~/worktrees) that have or have
had an agent running on them. I usually launch new tasks using this tool, which is in charge of creating a new worktree, opening it in
my IDE (currently creates a cmux workspace on the worktree) and launches an AI agent with an initial prompt so it starts working on the
task I set out for it.

## My workflow
- Editor: nvim
- Terminal: cmux
- Shell: bash
- Python: uv
- Git: commit message titles below 72 chars.

## Dev servers
Dev servers like vite, expo, next, etc should always start in a new cmux tab (not workspace).
Always create them in the current pane, rename them, move them to the end of that pane's tab list, then send the command.
Use `cmux identify --json` to get the current pane, create with `cmux new-surface --type terminal --pane <current-pane>`,
rename with `cmux rename-tab --surface <ref> "name"`, inspect order with `cmux list-pane-surfaces --pane <current-pane> --json`,
move to the end with `cmux reorder-surface --surface <ref> --after <current-last-surface>`, then send command with
`cmux send --surface <ref> "command\n"`. Use descriptive names like `vite-dev`, `expo-dev`.

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

## Debugging
When debugging a library/runtime bug, first search GitHub issues for the exact package(s) implicated by the stack trace or error.
Then search the issue tracker of the most likely upstream dependency. Do this before broad web searching.

## Skills
Global authored agent files live in `~/.dotfiles/.agents`.
Global authored skills live in `~/.dotfiles/.agents/skills`.

When creating a new global skill:
```bash
mkdir -p ~/.codex/skills ~/.claude/skills
ln -s ~/.dotfiles/.agents/skills/<name> ~/.codex/skills/<name>
ln -s ~/.codex/skills/<name> ~/.claude/skills/<name>
```

When deleting a global skill, remove the matching symlinks from:
- `~/.codex/skills/<name>`
- `~/.claude/skills/<name>`

Codex reads global skills from `~/.codex/skills` directly, claude needs them to be in `~/.claude/skills`.

## Style
In all interactions be extremely concise. This is a hard requirement, not a preference.
Default to the shortest useful answer. Prefer 1-3 sentences unless more is strictly necessary.
Sacrifice grammar, transitions, pleasantries, and elaboration for brevity.
Do not write long preambles, long summaries, or long explanations unless I explicitly ask for depth.
You can think however long you want, but when talking to me keep it brief. I do not have time for long-winded answers or questions.
