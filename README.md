# Personal configuration files

## Installation

### For remote nodes
```bash
cd
git clone git@github.com:joaqo/.dotfiles.git  --depth 1
sh .dotfiles/install.sh
```

`install.sh` also installs shared global skills from `~/.dotfiles/skills` into both Claude Code and Codex CLI via `skills.sh`, while preserving Codex's built-in `~/.codex/skills/.system` skills.

Logout from machine
```bash
scp ~/.bashrclocal machines_name:
```
Re-login.
