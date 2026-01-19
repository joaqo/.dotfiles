- In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

## Workflow

- Editor: nvim
- Terminal: tmux
- Shell: bash
- Secondary editor: Zed (vim mode, Claude + Firebase MCP)

## Dotfiles

Dotfiles versioned in `~/.dotfiles/` project and symlinked to home. When I ask you to modify something about my workflow or, how something on my workflow works, go to the directories listed below, so you can see exactly what my os (macOS) is seeing. 

- `~/.bashrc` - shell config
- `~/.config/nvim/` - nvim
- `~/.tmux.conf` - tmux
- `~/.gitconfig` - git
- `~/.config/zed/` - zed
- `~/Library/Application Support/lazygit/` - lazygit

**After any config change:** cd `~/.dotfiles`, show diff, suggest commit. Commit if approved.
