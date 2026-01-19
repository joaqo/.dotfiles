# CLAUDE.md

This repository was created to version control my dotfiles. It also helps in installing my dotfiles when I migrate to a new computer.

It just symlinks the dotfiles in this repository to their appropiate locations on my OS on install. It also installs a few programs.

When you finish making a change and you're sure you've been successful, propose a commit message to me and wait for my approval to commit it.

## Setup

```bash
# run from home directory
sh .dotfiles/install.sh
```

Symlinks dotfiles to ~, installs vim-plug, fzf, language servers (pnpm), and configures nvim/zed/lazygit.

## Structure

- `.bashrc` - shell config, custom functions (worktree mgmt, fzf integration, logging)
- `.config/nvim/` - neovim config (lazy.nvim), plugins in `lua/plugins/`, core in `lua/config/`
- `.config/zed/` - zed editor settings (claude integration, vim mode)
- `.config/lazygit/` - lazygit custom commands
- `bin/` - custom scripts (autocommit uses claude haiku for commit msgs)

## Style

Be extremely concise. Sacrifice grammar for brevity in commits and interactions.
