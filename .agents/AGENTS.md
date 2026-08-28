My name is Joaquín Alori, I am a developer from Uruguay, working on several projects. My phone number is +59898231030, and my github username is joaqo.

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
- "main branch" / "main" means my **local** main, not `origin/main`, unless I say otherwise.

## Debugging
When debugging a library/runtime bug, first search GitHub issues for the exact package(s) implicated by the stack trace or error.
Then search the issue tracker of the most likely upstream dependency. Do this before broad web searching.

## Browser
Keep browser tabs used for active work open across turns and interruptions. Close them only when the task is fully complete or I ask you to close them.

## Skills
Global authored agent files live in `~/.dotfiles/.agents`.
Global authored skills live in `~/.dotfiles/.agents/skills`.

When creating a new global skill, create its directory and `SKILL.md`, then sync:
```bash
mkdir -p ~/.dotfiles/.agents/skills/<name>
nvim ~/.dotfiles/.agents/skills/<name>/SKILL.md
skill sync
```

When deleting an authored global skill, delete its source directory and run `skill sync`.
Use `skill add <repo-or-path>`, `skill update`, and `skill remove <name>` for external skills.

The `skill` command links canonical skill directories directly into both `~/.codex/skills` and `~/.claude/skills`. Authored skills stay in dotfiles; external git skills are live clones under `~/.local/share/agent-skills/repos` and are pinned in `.agents/skills.lock`.

For a skill only the user may invoke, set `disable-model-invocation: true` in `SKILL.md` and `policy.allow_implicit_invocation: false` in `agents/openai.yaml`. The first controls Claude Code; the second controls Codex.

## Style
In all interactions be extremely concise. This is a hard requirement, not a preference.
Default to the shortest useful answer. Prefer 1-3 sentences unless more is strictly necessary.
Sacrifice grammar, transitions, pleasantries, and elaboration for brevity.
Do not write long preambles, long summaries, or long explanations unless I explicitly ask for depth.
You can think however long you want, but when talking to me keep it brief. I do not have time for long-winded answers or questions.

## Code comments
Only comment to capture a non-obvious *why* or a gotcha. Never narrate what the code does or restate what a name already says. Match the file's comment density; prefer zero comments over a redundant one.

A comment must stand alone for someone reading the final file with no knowledge of the task it came from: never reference the previous code, the bug being fixed, or how the change differs from before. If a comment only makes sense alongside the diff, it's a message to me — say it in chat and leave it out of the file. After any edit that adds a comment, re-read the comment as if the old code never existed or you had no context of our conversation; if it doesn't stand alone, rewrite or delete it.
