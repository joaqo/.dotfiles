# Personal configuration files

## Installation

### For remote nodes
```bash
cd
git clone git@github.com:joaqo/.dotfiles.git  --depth 1
sh .dotfiles/install.sh
```

`install.sh` also symlinks shared global agent files from `~/.dotfiles/.agents` into `~/.claude` and `~/.codex`. Global custom skills live in `~/.codex/skills`, and Claude mirrors them from `~/.claude/skills`.

Logout from machine
```bash
scp ~/.bashrclocal machines_name:
```
Re-login.
