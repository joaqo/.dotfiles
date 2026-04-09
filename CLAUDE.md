# CLAUDE.md

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
- `.agents/AGENTS.md` - shared global instructions for Claude Code and Codex CLI; symlinked to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`
- `.agents/skills/` - shared global authored skills. Symlinked into `~/.codex/skills/` and `~/.claude/skills/`.
  - Do not create `agents/openai.yaml` inside authored global skills. You always get confused by this because one of our skills does that, but that is only needed for that one skill.
- `.claude/` - Claude Code settings, hooks, and commands (symlinked)
- `bin/` - custom scripts: `autocommit` (claude haiku commit msgs), `kp` (fzf process killer), `focus-iterm-session`
- `scripts/oneShot/main.swift` - tiny Swift GUI for sending prompts + images to `agent exec`, with logs and notifications. Rebuild after edits: `cd ~/.dotfiles/scripts/oneShot && swiftc -parse-as-library -o oneShot -framework AppKit -framework SwiftUI main.swift`
- `scripts/NvimInITerm.applescript` - makes macOS default to nvim+iTerm for code and text files. Compiled to ~/Applications/NvimInITerm.app, registered as default handler for 50+ file types via duti.

## Style

Be extremely concise. Sacrifice grammar for brevity in commits and interactions.
