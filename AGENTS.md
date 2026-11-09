# AGENTS.md

This repository was created to version control my dotfiles. It also helps in installing my dotfiles when I migrate to a new computer.

It just symlinks the dotfiles in this repository to their appropiate locations on my OS on install. It also installs a few programs.

When you finish making a change and you're sure you've been successful, show git diff and propose a commit message to me and wait for my approval to commit it.

If there's other irrelevant changes in the commit diff be aware of that and propose different commits for the different changes, with git diffs for each.

## Setup

```bash
# run from home directory
sh .dotfiles/install.sh
```

Symlinks dotfiles to ~, installs fzf, language servers (pnpm), ripgrep, compiles Swift/AppleScript apps.

## Structure

- `.bashrc` - shell config, aliases, custom functions (worktree mgmt, fzf integration, logging, notifications)
- `.tmux.conf` - tmux config (prefix: Ctrl+Space, vim-tmux nav, lazygit popup)
- `.gitconfig` - git user config & aliases
- `.config/nvim/` - neovim config (lazy.nvim), plugins in `lua/plugins/`, core in `lua/config/`
- `.config/zed/` - zed editor settings (claude integration, vim mode)
- `.config/lazygit/` - lazygit custom commands (symlinked to ~/Library/Application Support/lazygit/, not ~/.config/)
- `.config/tmuxinator/` - tmuxinator project configs (mellow)
- `.config/ghostty/` - ghostty terminal config (gruvbox dark)
- `.config/herdr-app/` - Herdr app keys, gruvbox-black theme, `flat` layout (clone of `main`: no gaps, square panes, hover headers, `flat-tabs` bar that collapses to 1px with a single tab) and `close-pane` mod (cmd-w: closes pane, or the whole space without asking if it's the last pane), each symlinked into `~/.config/herdr-app/` (rest of that dir is app state). Herdr watches the link, not the target: after editing, `touch -h` the link in `~/.config/herdr-app/` to live-reload
- `.agents/AGENTS.md` - shared global instructions for Claude Code and Codex CLI; symlinked to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`. Projects use AGENTS.md only; a project CLAUDE.md would stop Claude reading its AGENTS.md
- `.agents/skills/` - shared global authored skills
- `.agents/skills.lock` - external skill sources, selected directories, and pinned git commits
- `.claude/` - Claude Code settings, hooks, and commands (symlinked)
- `.codex/config.toml` - Codex settings, symlinked to `~/.codex/config.toml`; Codex saves settings back into this file
- `bin/` - custom scripts, including `skill` for linking authored skills and managing live external skill clones
- `.config/terminal/default` - the app chosen by the Ghostty launcher, `~/terminal/agent-control/terminal` (`terminal use agents|ghostty`)
- `scripts/NvimInITerm.applescript` - makes macOS default to nvim+iTerm for code and text files. Compiled to ~/Applications/NvimInITerm.app, registered as default handler for 50+ file types via duti.

## Style

Be extremely concise. Sacrifice grammar for brevity in commits and interactions.
