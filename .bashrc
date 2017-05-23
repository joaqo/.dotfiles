# FZF
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Virtualenv wrapper doesnt do this when you install it for some reason
export WORKON_HOME=~/.virtualenvs

# Save history after each command (to share history between windows)
export PROMPT_COMMAND='history -a'

# Git official autocomplete
source ~/Code/git-completion.bash

# Git official prompt
source ~/Code/git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
export PS1='\[\033[01;34m\]\w\[\033[00m\]\[\033[01;36m\]$(__git_ps1 " (%s)")\[\033[00m\]\[\033[01;31m\] > \[\033[00m\]'
#export PS1='\w$(__git_ps1 " (%s)")> '  #  with no colors

# Vim default editor
export EDITOR='vim'

# Si no le agregaba la -t no me encontraba los .env que estuvieran
# a mas de dos directorios de distancia recursiva, what??!!
export FZF_DEFAULT_COMMAND='ag -U --ignore "*.pyc" --hidden -g ""'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# For cs231n course jupyter noteobook
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Aliases
alias mux="tmuxinator"

workon() {
source ~/.virtualenvs/$1/bin/activate
}
