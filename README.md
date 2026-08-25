# Personal configuration files

## Installation

### For remote nodes
```bash
cd
git clone git@github.com:joaqo/.dotfiles.git  --depth 1
sh .dotfiles/install.sh
```

`install.sh` also symlinks shared global agent files from `~/.dotfiles/.agents` into `~/.claude` and `~/.codex`.

## Skills

Authored skills live in `~/.dotfiles/.agents/skills`. External repositories are cloned into `~/.local/share/agent-skills/repos`; selected skills and commits are versioned in `.agents/skills.lock`. Both agents link directly to those canonical directories.

```bash
skill add mattpocock/skills
skill add ~/projects/my-skills
skill update [repo]
skill remove <name>
skill list
skill sync
skill retro  # open the canonical SKILL.md
```

Logout from machine
```bash
scp ~/.bashrclocal machines_name:
```
Re-login.
