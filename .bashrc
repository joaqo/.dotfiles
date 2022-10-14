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

# Add poetry to path. The poetry installation script adds this to
# your .profile file, I just moved it here.
export PATH="$HOME/.poetry/bin:$PATH"

# Save history after each command (to share history between windows)
export PROMPT_COMMAND='history -a'

# Expand size of bash history and dont save duplicate commands
export HISTSIZE=80000
export HISTFILESIZE=80000
export HISTCONTROL=ignoredups:erasedups:ignorespace

# Git official autocomplete
source $HOME/.bin/git-completion.bash
# Git official prompt
source $HOME/.bin/git-prompt.sh

# Configure prompt
export GIT_PS1_SHOWDIRTYSTATE=1
if [ $is_macos ]; then
    export PS1='\[\033[01;34m\]\w\[\033[00m\]\[\033[01;36m\]$(__git_ps1 " %s")\[\033[00m\]\[\033[01;31m\] > \[\033[00m\]'
else
    export PS1='\[\033[01;31m\]\h \[\033[00m\]\[\033[01;34m\]\w\[\033[00m\]\[\033[01;36m\]$(__git_ps1 " %s")\[\033[00m\]\[\033[01;31m\] > \[\033[00m\]'
fi

# Vim as default editor
export EDITOR='vim'

# Not sure what this is, maybe for man and such?
export VISUAL='vim'

# Load FZF
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

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
alias i="ipython"
alias b="bpython"
alias t="tmux a"
alias pipdefs="pip install ipdb bpython ipython flake8 pretty_errors"
alias process="ps -feww | grep"
alias mux=tmuxinator
alias v="vim"
alias grep="grep --color"

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

# Add pyenv to path
PATH=~/.pyenv/shims:$PATH
PATH=~/.pyenv/bin:$PATH

# Pipenv looks for this to integrate with pyenv
export PYENV_ROOT=~/.pyenv/
export PIPENV_SKIP_LOCK=True

# Activate current folder's pipenv virtualenv or activate an explicit virtualenv name,
# Supports autocomplete, renamed from workon to wo as I type this a lot
wo() {
  if [ $# -eq 0 ]; then
      source ${WORKON_HOME}${PWD##*/}/bin/activate 
  else
      source ${WORKON_HOME}/$1/bin/activate
  fi
}
_workon() {
  local lis cur
  lis=$(ls $WORKON_HOME)
  cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $(compgen -W "$lis" -- "$cur") )
}
complete -F _workon wo

# Making a new virtualenv
mkvenv() {
  if [ $# -eq 0 ]; then  # The $# variable stores the number of input arguments the script was passed
    echo "No arguments supplied"
  else
    python3 -m venv ${WORKON_HOME}/"$1"
    wo "$1"
    pip install --upgrade pip
  fi
}

# Get json from api
httpj() {
http --pretty=format $1 | vim - -c 'set syntax=json' -c 'set foldmethod=syntax'
}

# Highlight folders on ls
LS_COLORS=$LS_COLORS:'di=0;35:' ; export LS_COLORS

# Note taking function and command completion
_n() {
  local lis cur
  lis=$(find "${NOTE_DIR}" -name "*.md" | \
    sed -e "s|${NOTE_DIR}/||" | \
    sed -e 's/\.md$//')
  cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $(compgen -W "$lis" -- "$cur") )
}
n() {
  : "${NOTE_DIR:?'NOTE_DIR ENV Var not set'}"
  if [ $# -eq 0 ]; then
    local file
    file=$(find "${NOTE_DIR}" -name "*.md" | \
      sed -e "s|${NOTE_DIR}/||" | \
      sed -e 's/\.md$//' | \
      fzf \
        --multi \
        --select-1 \
        --exit-0 \
        --preview="cat ${NOTE_DIR}/{}.md" \
        --preview-window=right:70%:wrap)
    [[ -n $file ]] && \
      ${EDITOR:-vim} "${NOTE_DIR}/${file}.md"
  else
    case "$1" in
      "-d")
        rm "${NOTE_DIR}"/"$2".md
        ;;
      *)
        ${EDITOR:-vim} "${NOTE_DIR}"/"$*".md
        ;;
    esac
  fi
}
complete -F _n n

# fcheckout - checkout git commit with previews
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

# fshow - git commit browser with previews
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
