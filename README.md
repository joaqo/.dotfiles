# Personal configuration files

## Installation

### For remote nodes
```bash
cd
git clone git@github.com:joaqo/.dotfiles.git  --depth 1
sh .dotfiles/install.sh
```

`install.sh` also symlinks shared global agent files from `~/.dotfiles/.agents` into `~/.agents`, `~/.claude`, and `~/.codex`. Global custom skills live in `~/.agents/skills`, Claude mirrors them from `~/.claude/skills`, and Codex keeps its built-in `~/.codex/skills/.system` skills separate.

Logout from machine
```bash
scp ~/.bashrclocal machines_name:
```
Re-login.
