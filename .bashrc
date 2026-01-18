# Define OS
if [[ "$(uname -a)" == *"Darwin"* ]]; then
    is_macos=true
fi

# Select cuda library version to use
cuda-env() {
  export PATH=/usr/local/cuda-$1/bin${PATH:+:${PATH}}
  export LD_LIBRARY_PATH=/usr/local/cuda-$1/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
  export CUDA_HOME=/usr/local/cuda-$1/
}
cuda-env 11.0

export WORKON_HOME=~/.virtualenvs
export POETRY_VIRTUALENVS_PATH=$WORKON_HOME
export PATH="$HOME/.bin:$PATH"

# Worktree directory
export WORKTREE_DIR=~/worktrees

# Add poetry to path. The poetry installation script adds this to
# your .profile file, I just moved it here.
export PATH="$HOME/.poetry/bin:$PATH"

# Add google cloud (gcloud) to path
export PATH="$HOME/.bin/google-cloud-sdk/bin:$PATH"
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/application_default_credentials.json"
export CLOUDSDK_PYTHON=$(which python3.11)

# Save history after each command (to share history between windows)
# Also update session name to iTerm after each command (because its `pwd`)
export PROMPT_COMMAND='history -a'

# Expand size of bash history and dont save duplicate commands
export HISTSIZE=80000
export HISTFILESIZE=80000
export HISTCONTROL=ignoredups:erasedups:ignorespace

# Git official autocomplete
# source $HOME/.bin/git-completion.bash
# Git official prompt
# source $HOME/.bin/git-prompt.sh

# Configure prompt
export GIT_PS1_SHOWDIRTYSTATE=1
if [ $is_macos ]; then
    export PS1='\[\033[01;34m\]\w\[\033[00m\]\[\033[01;36m\]\[\033[00m\]\[\033[01;31m\] > \[\033[00m\]'
    # export PS1='\[\033[01;34m\]\w\[\033[00m\]\[\033[01;36m\]$(__git_ps1 " %s")\[\033[00m\]\[\033[01;31m\] > \[\033[00m\]'
else
    export PS1='\[\033[01;31m\]\h \[\033[00m\]\[\033[01;34m\]\w\[\033[00m\]\[\033[01;36m\]\[\033[00m\]\[\033[01;31m\] > \[\033[00m\]'
    # export PS1='\[\033[01;31m\]\h \[\033[00m\]\[\033[01;34m\]\w\[\033[00m\]\[\033[01;36m\]$(__git_ps1 " %s")\[\033[00m\]\[\033[01;31m\] > \[\033[00m\]'
fi

# Vim as default editor
export EDITOR='nvim'

# Not sure what this is, maybe for man and such?
export VISUAL='nvim'

# Si no le agregaba la -t no me encontraba los .env que estuvieran
# a mas de dos directorios de distancia recursiva, what??!!
# Only in my computer cause it requires ag to be installed.
if [ $is_macos ]; then
    export FZF_DEFAULT_COMMAND='ag -U --ignore={"*.pyc",".git"} --hidden -g ""'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Tell the OS that your prefered language is english and your encoding utf-8.
# Specially helpfull to avoid problems I had with vim not showing UTF-8 chars.
# As explained here: https://unix.stackexchange.com/questions/23389/how-can-i-set-vims-default-encoding-to-utf-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Homebrew autoupdate is horribly slow
HOMEBREW_NO_AUTO_UPDATE=1

# Fix homebrew for macOS with M1 chip
if [ $is_macos ]; then
    export PATH=/opt/homebrew/bin:$PATH
fi

# Aliases
alias gsb="git status -sb"
alias gd="clear; git diff"
alias g="git"
alias l="ls -lhFG"
alias i="uvx ipython"
alias t="tmux a"
alias pipdefs="pip install ipdb bpython ipython flake8 pretty_errors"
alias process="ps -feww | grep"
alias mux=tmuxinator
alias v="nvim"
alias vim="nvim"
alias vc="cd ~/.dotfiles/.config/nvim/lua; nvim"
alias grep="grep --color"
alias dash="cd $HOME/dashboard-feyn/; wo dashboard; jupyter notebook main.ipynb"
alias c="claude --dangerously-skip-permissions"
alias p="uvx python"
alias u="uv run"

# ls with colors
if [ $is_macos ]; then
    alias ls="ls -G"
else
    alias ls='ls --color=auto'
fi

# Make python > 3.7 debugger use ipdb when calling `breakpoint()`
export PYTHONBREAKPOINT=ipdb.set_trace

# Add local bins to path
PATH=$PATH:~/code/bin  # Personal bins
PATH=$PATH:~/.local/bin  # Ubuntu bins

# Fixes the following problem with brew
# https://github.com/Homebrew/homebrew-php/issues/4527#issuecomment-346483994
PATH=$PATH:/usr/local/sbin

# Highlight folders on ls
LS_COLORS=$LS_COLORS:'di=0;35:' ; export LS_COLORS

# fshow - git commit browser with previews
alias glNoGraph='git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr% C(auto)%an" "$@"'
_gitLogLineToHash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
_viewGitLogLine="$_gitLogLineToHash | xargs -I % sh -c 'git show --color=always %'"
fcoc_preview() {
  local commit
  commit=$( glNoGraph |
    fzf --no-sort --reverse --tiebreak=index --no-multi \
        --ansi --preview="$_viewGitLogLine" ) &&
  git checkout $(echo "$commit" | sed "s/ .*//")
}
fshow() {
    glNoGraph |
        fzf --no-sort --reverse --tiebreak=index --no-multi \
            --ansi --preview="$_viewGitLogLine" \
                --header "enter to view, alt-y to copy hash" \
                --bind "enter:execute:$_viewGitLogLine   | less -R" \
                --bind "alt-y:execute:$_gitLogLineToHash | xclip"
}

# Optionally load custom non versioned per machine options.
if [ -f ~/.bashrclocal ]; then
  . ~/.bashrclocal
fi


# Load FZF (this line should be placed near the end of this file because we need to load up $PATH prior or it wont find `fzf`)
eval "$(fzf --bash)"

export PATH=~/.npm-global/bin:$PATH
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk && export PATH=$PATH:$ANDROID_HOME/emulator && export PATH=$PATH:$ANDROID_HOME/platform-tools

# Usage: lo mycommand echo "Hello World"
# This will create a log file at $TMPDIR/mycommand.log
# Usage: lo mycommand echo "Hello World"
# This will create a log file at $TMPDIR/mycommand.log
lo() {
  local name="$1"
  shift
  
  # Detect worktree: if basename differs from "mellow", append it as suffix
  local repo_name
  repo_name=$(git rev-parse --show-toplevel 2>/dev/null | xargs basename)
  if [[ -n "$repo_name" && "$repo_name" != "mellow" ]]; then
    name="${name}-${repo_name}"
  fi
  
  # Determine process tag (worktree name or "main")
  local tag="lo:main"
  if [[ -n "$repo_name" && "$repo_name" != "mellow" ]]; then
    tag="lo:$repo_name"
  fi
  
  local logfile="${TMPDIR%/}/${name}.log"
  rm -f "$logfile"
  if [[ -n "$repo_name" && "$repo_name" != "mellow" ]]; then
    echo -e "Workspace: \033[0;35m$repo_name\033[0m"
  fi
  echo -e "Started: \033[0;33m$(date '+%a %b %d %H:%M:%S')\033[0m"
  echo -e "Logging to: \033[0;32m$logfile\033[0m"
  unbuffer -p bash -c 'exec -a "$1" "${@:2}"' _ "$tag" "$@" 2>&1 | tee >(sed -u -e 's/\x1b\[[0-9;]*[a-zA-Z]//g' -e 's/\r/\n/g' > "$logfile")
}

# Run a command and show a notification when it finishes
notify() {
  local cmd_name="$1"
  local cmd_args="${*:2}"
  local start_time=$(date +%s.%N)
  "$@"
  local exit_code=$?
  local end_time=$(date +%s.%N)
  local duration=$(printf "%.1f" $(echo "$end_time - $start_time" | bc))

  if [ $exit_code -eq 0 ]; then
    local title="$cmd_name"
    local status="Completed in ${duration}s"
  else
    local title="$cmd_name Failed!"
    local status="Failed (exit $exit_code) after ${duration}s"
  fi

  if [ -n "$cmd_args" ]; then
    terminal-notifier -title "$title" -subtitle "$cmd_args" -message "$status"
  else
    terminal-notifier -title "$title" -message "$status"
  fi
  return $exit_code
}

# Git worktree management
worktree-add() {
  read -p "Enter worktree name: " name
  git worktree add $WORKTREE_DIR/$name && zed $WORKTREE_DIR/$name
}

worktree-rebase() {
  # Colors
  local RED='\033[0;31m'
  local GREEN='\033[0;32m'
  local YELLOW='\033[0;33m'
  local NC='\033[0m' # No Color

  if [ $# -eq 0 ]; then
    local branches=($(git worktree list | grep -o '\[.*\]' | tr -d '[]' | grep -v '^main$'))

    # Use fzf if available, otherwise use select menu
    if command -v fzf &> /dev/null; then
      name=$(printf '%s\n' "${branches[@]}" | fzf --height=40% --reverse --no-info --prompt="Select worktree to rebase: ")
      [ -z "$name" ] && return 0  # User cancelled
    else
      echo -e "${YELLOW}Select worktree to rebase:${NC}"
      select name in "${branches[@]}"; do
        [ -n "$name" ] && break
      done
    fi
  else
    name=$1
  fi

  # Path to the primary (original) worktree
  root=$(git worktree list --porcelain | awk '/^worktree / {print $2; exit}')

  # Path to the worktree that has branch "$name" checked out
  wt=$(git worktree list --porcelain | awk -v b="refs/heads/$name" '
    /^worktree / { w=$2 }
    /^branch / && $2==b { print w; exit }
  ')

  if [ -z "$wt" ]; then
    echo -e "${RED}✗ No worktree found for branch '$name'${NC}"
    return 1
  fi

  # Check for uncommitted changes
  if ! git -C "$wt" diff-index --quiet HEAD --; then
    echo -e "${RED}✗ Worktree has uncommitted changes${NC}"
    echo -e "${YELLOW}Commit or stash changes before rebasing${NC}"
    return 1
  fi

  # Rebase the worktree's branch onto main
  echo -e "${YELLOW}Rebasing $name onto main...${NC}"
  if ! git -C "$wt" rebase main; then
    echo -e "${RED}✗ Rebase failed${NC}"
    echo -e "${YELLOW}To resolve:${NC}"
    echo -e "  cd $wt"
    echo -e "  # Fix conflicts, then:"
    echo -e "  git rebase --continue"
    echo -e "  # Or abort:"
    echo -e "  git rebase --abort"
    return 1
  fi
  echo -e "${GREEN}✓ Rebased onto main${NC}"

  # Fast-forward main in the primary worktree
  echo -e "${YELLOW}Switching to main...${NC}"
  if ! git -C "$root" switch main; then
    echo -e "${RED}✗ Failed to switch to main${NC}"
    echo -e "${YELLOW}Check if main branch exists or has uncommitted changes${NC}"
    return 1
  fi

  echo -e "${YELLOW}Merging $name into main...${NC}"
  if ! git -C "$root" merge --ff-only "$name"; then
    echo -e "${RED}✗ Fast-forward merge failed${NC}"
    echo -e "${YELLOW}This usually means main has diverged. The rebase succeeded but merge failed.${NC}"
    echo -e "${YELLOW}You may need to manually merge or rebase differently.${NC}"
    return 1
  fi
  echo -e "${GREEN}✓ Merged into main${NC}"

  # Remove worktree + branch
  echo -e "${YELLOW}Removing worktree...${NC}"
  if ! git worktree remove "$wt"; then
    echo -e "${RED}✗ Failed to remove worktree${NC}"
    echo -e "${YELLOW}You may need to remove it manually:${NC}"
    echo -e "  git worktree remove $wt --force"
    return 1
  fi

  if ! git -C "$root" branch -d "$name"; then
    echo -e "${YELLOW}⚠ Branch '$name' could not be deleted (may have unmerged changes)${NC}"
    echo -e "${YELLOW}Use 'git branch -D $name' to force delete${NC}"
  fi

  echo -e "${GREEN}✓ Cleaned up${NC}"
}

worktree-remove() {
  # Colors
  local RED='\033[0;31m'
  local YELLOW='\033[0;33m'
  local GREEN='\033[0;32m'
  local BOLD_BLACK='\033[1;30m'
  local NC='\033[0m' # No Color

  if [ $# -eq 0 ]; then
    local branches=($(
      git worktree list --porcelain \
      | awk '
          /^worktree / {
            wt++
            next
          }
          wt > 1 && /^branch / {
            sub("refs/heads/", "", $2)
            print $2
          }
        '
    ))

    # Use fzf if available, otherwise use select menu
    if command -v fzf &> /dev/null; then
      name=$(printf '%s\n' "${branches[@]}" | fzf --height=40% --reverse --no-info --prompt="Select worktree to remove: ")
      [ -z "$name" ] && return 0  # User cancelled
    else
      echo "Select worktree to remove:"
      select name in "${branches[@]}"; do
        [ -n "$name" ] && break
      done
    fi
  else
    name=$1
  fi

  # Confirm before removing
  echo -e "${RED}⚠  Will delete worktree and branch ${BOLD_BLACK}$name${NC}"
  read -p "Delete? [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    return 0
  fi

  local wt_path
  wt_path=$(git worktree list --porcelain | awk -v b="refs/heads/$name" '
    /^worktree / { w=$2 }
    /^branch / && $2==b { print w; exit }
  ')
  if [ -z "$wt_path" ]; then
    echo -e "${RED}✗ No worktree found for branch '$name'${NC}"
    return 1
  fi
  git worktree remove "$wt_path" --force && git branch -d $name --force
}

worktree-open() {
  if [ $# -eq 0 ]; then
    local branches=($(git worktree list | grep -o '\[.*\]' | tr -d '[]' | grep -v '^main$'))

    # Use fzf if available, otherwise use select menu
    if command -v fzf &> /dev/null; then
      name=$(printf '%s\n' "${branches[@]}" | fzf --height=40% --reverse --no-info --prompt="Select worktree to open: ")
      [ -z "$name" ] && return 0  # User cancelled
    else
      echo "Select worktree to open:"
      select name in "${branches[@]}"; do
        [ -n "$name" ] && break
      done
    fi
  else
    name=$1
  fi
  zed $WORKTREE_DIR/$name
}

export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Added by pnpm installation
export PNPM_HOME="/Users/joaqo/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
