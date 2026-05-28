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
had an agent running on them. I usually launch new tasks using this tool, which is in charge of creating a new worktree and launching an
AI agent with an initial prompt so it starts working on the task I set out for it.

## My workflow
- Editor: nvim
- Shell: bash
- Python: uv
- Git: commit message titles below 72 chars.

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
