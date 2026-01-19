# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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
