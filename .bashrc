# FZF
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Virtualenv wrapper doesnt do this when you install it for some reason
export WORKON_HOME=~/.virtualenvs

# Save history after each command (to share history between windows)
export PROMPT_COMMAND='history -a'

# Expand size of bash history and dont save duplicate commands
export HISTSIZE=20000
export HISTFILESIZE=20000
export HISTCONTROL=erasedups

# Git official autocomplete
source ~/Code/git-completion.bash

# Git official prompt
source ~/Code/git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
export PS1='\[\033[01;34m\]\w\[\033[00m\]\[\033[01;36m\]$(__git_ps1 " %s")\[\033[00m\]\[\033[01;35m\] > \[\033[00m\]'
#export PS1='\w$(__git_ps1 " (%s)")> '  #  with no colors

# Vim default editor
export EDITOR='vim'

# Si no le agregaba la -t no me encontraba los .env que estuvieran
# a mas de dos directorios de distancia recursiva, what??!!
# export FZF_DEFAULT_COMMAND='ag -U --ignore "*.pyc" --hidden --ignore-dir ".git" -g ""'
export FZF_DEFAULT_COMMAND='ag -U --ignore "*.pyc" --hidden -g ""'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# For cs231n course jupyter noteobook
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
#export BROWSER=open  # Appeared after osx update, should be temoporary

# For Tryolabs/Levelup, ensures we are running the correct version of phantomjs
export LEVELUP_DEVEL=True

# Levelup-Providers servers
export STAG=http://StagingLoadBalancer-1366108757.us-west-2.elb.amazonaws.com
export PROD=http://LambdaLoadBalancer-587995896.us-west-2.elb.amazonaws.com
export LOC='http://127.0.0.1'

# Aliases
alias v='vim'
alias mux="tmuxinator"
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
alias chrome-canary="/Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary"
alias gsb="git status -sb"
alias g="git"
alias l="ls -lhFG"
alias ls="ls --color"
alias python="python3.6"

# Add files in ~/bin to path
PATH=$PATH:~/bin/

# Add gcloud to path
# source ~/bin/google-cloud-sdk/path.bash.inc

workon() {
source ~/.virtualenvs/$1/bin/activate
}

mkvenv() {
cd ~/.virtualenvs
virtualenv "$@"
cd -
workon "$1"
}

httpj() {
http --pretty=format $1 | vim - -c 'set syntax=json' -c 'set foldmethod=syntax'
}

# Highlight folders on ls
LS_COLORS=$LS_COLORS:'di=0;35:' ; export LS_COLORS

# # Pyenv
# eval "$(pyenv init -)"
