# FZF
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Virtualenv wrapper doesnt do this when you install it for some reason
export WORKON_HOME=~/.virtualenvs

# Save history after each command (to share history between windows)
export PROMPT_COMMAND='history -a'

# Expand size of bash history and dont save duplicate commands
export HISTSIZE=20000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups

# Configure prompt
export GIT_PS1_SHOWDIRTYSTATE=1
hname="$(hostname)"
if [[ ${hname} == *"macbook-joaquin"* ]]
then
    # Git official autocomplete
    source ~/Code/git-completion.bash
    # Git official prompt
    source ~/Code/git-prompt.sh
    export PS1='\[\033[01;34m\]\w\[\033[00m\]\[\033[01;36m\]$(__git_ps1 " %s")\[\033[00m\]\[\033[01;31m\] > \[\033[00m\]'
else
    export PS1='\[\033[01;31m\]\h \[\033[00m\]\[\033[01;34m\]\w\[\033[00m\]\[\033[01;36m\]$(__git_ps1 " %s")\[\033[00m\]\[\033[01;31m\] > \[\033[00m\]'
fi

# Vim default editor
export EDITOR='vim'

# Not sure what this is, maybe for man an the such?
export VISUAL='vim'

# Si no le agregaba la -t no me encontraba los .env que estuvieran
# a mas de dos directorios de distancia recursiva, what??!!
# Only in my computer cause it requires ag to be installed.
if [[ ${hname} == *"macbook-joaquin"* ]]
then
    export FZF_DEFAULT_COMMAND='ag -U --ignore={"*.pyc",".git"} --hidden -g ""'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# For cs231n course jupyter noteobook
# Delete ?
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Aliases
alias mux="tmuxinator"
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
alias chrome-canary="/Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary"
alias gsb="git status -sb"
alias g="git"
alias l="ls -lhFG"
alias callcito="/Applications/Call\ of\ Duty\ 2\ Multiplayer.app/Contents/MacOS/Call\ of\ Duty\ 2\ Multiplayer"
alias p="pipenv run"
alias t="tmux a -t 0"
alias "pipdefs"="pip install ipdb ipython flake8 python-language-server"

# ls with colors
if [[ ${hname} == *"macbook-joaquin"* ]]
then
    alias ls="ls -G"
else
    alias ls='ls --color=auto'
fi

# Add files in ~/bin to path
PATH=$PATH:~/bin

# Fixes the following problem with brew
# https://github.com/Homebrew/homebrew-php/issues/4527#issuecomment-346483994
PATH=$PATH:/usr/local/sbin

# Add pyenv to path
PATH=~/.pyenv/shims:$PATH
PATH=~/.pyenv/bin:$PATH

# pipenv looks for this to integrate with pyenv
export PYENV_ROOT=~/.pyenv/

# Activate current folder's pipenv virtualenv
# or accept an explicit virtualenv name
workon() {
if [ $# -eq 0 ]
then
    source $(pipenv --venv)/bin/activate
else
    source ~/.virtualenvs/$1/bin/activate
fi
}

# Making virtualenv alias
mkvenv() {
cd ~/.virtualenvs
virtualenv "$@"
cd -
workon "$1"
}

# Automatic virtualenv sourcing
function auto_pipenv_shell {
    if [ ! -n "$VIRTUAL_ENV" ]; then
        if [ -f "Pipfile" ] ; then
            workon
        fi
    fi
}
function cd {
    builtin cd "$@"
    auto_pipenv_shell
}
auto_pipenv_shell

# Get json from api
httpj() {
http --pretty=format $1 | vim - -c 'set syntax=json' -c 'set foldmethod=syntax'
}

# Add title to current iterm window
title() {
    echo -n -e "\033]0;"$*"\007"
}

# Highlight folders on ls
LS_COLORS=$LS_COLORS:'di=0;35:' ; export LS_COLORS

# Load custom, per machine, options. Such as adding cuda libraries to path
if [ -f ~/.bashrc_extra ]; then
  . ~/.bashrc_extra
fi
