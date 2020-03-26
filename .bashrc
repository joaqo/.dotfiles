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
os_type="$(uname -a)"
if [[ ${os_type} == *"Darwin"* ]]
then
    # Git official autocomplete
    source /usr/local/etc/bash_completion.d/git-completion.bash
    # Git official prompt
    source /usr/local/etc/bash_completion.d/git-prompt.sh
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
if [[ ${os_type} == *"Darwin"* ]]
then
    export FZF_DEFAULT_COMMAND='ag -U --ignore={"*.pyc",".git"} --hidden -g ""'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Tell the OS that your prefered language is english and your encoding utf-8.
# Specially helpfull to avoid problems I had with vim not showing UTF-8 chars.
# As explained here: https://unix.stackexchange.com/questions/23389/how-can-i-set-vims-default-encoding-to-utf-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Aliases
alias mux="tmuxinator"
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
alias chrome-canary="/Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary"
alias gsb="git status -sb"
alias gd="clear; git diff"
alias g="git"
alias l="ls -lhFG"
alias callcito="/Applications/Call\ of\ Duty\ 2\ Multiplayer.app/Contents/MacOS/Call\ of\ Duty\ 2\ Multiplayer"
alias p="pipenv run"
alias i="ipython"
alias t="tmux a -t 0"
alias "pipdefs"="pip install ipdb ipython jedi flake8"

# ls with colors
if [[ ${os_type} == *"Darwin"* ]]
then
    alias ls="ls -G"
else
    alias ls='ls --color=auto'
fi

# Make python > 3.7 debugger use ipdb when calling `breakpoint()`
PYTHONBREAKPOINT=ipdb.set_trace

# Add files in ~/bin to path
PATH=$PATH:~/code/bin

# Fixes the following problem with brew
# https://github.com/Homebrew/homebrew-php/issues/4527#issuecomment-346483994
PATH=$PATH:/usr/local/sbin

# Add pyenv to path
PATH=~/.pyenv/shims:$PATH
PATH=~/.pyenv/bin:$PATH

# pipenv looks for this to integrate with pyenv
export PYENV_ROOT=~/.pyenv/
export PIPENV_SKIP_LOCK=True

# Activate current folder's pipenv virtualenv or activate an explicit virtualenv name,
# Hardcoded to ~/.virtualenvs. Supports autocomplete 
# renamed from workon to wo as I type this a lot
wo() {
if [ $# -eq 0 ]
then
    # source $(pipenv --venv)/bin/activate
    # . "$(dirname $(poetry run which python))/activate"
    source ~/.virtualenvs/${PWD##*/}/bin/activate 
else
    source ~/.virtualenvs/$1/bin/activate
fi
}
_workon() {
  local lis cur
  lis=$(ls ~/.virtualenvs)
  cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $(compgen -W "$lis" -- "$cur") )
}
complete -F _workon wo

# Making virtualenv alias
mkvenv() {
python3 -m venv ~/.virtualenvs/"$1"
wo "$1"
}

# # Automatic virtualenv sourcing
# function auto_pipenv_shell {
#     if [ ! -n "$VIRTUAL_ENV" ]; then
#         if [ -f "Pipfile" ] ; then
#             workon
#         fi
#     fi
# }
# function cd {
#     builtin cd "$@"
#     auto_pipenv_shell
# }
# auto_pipenv_shell

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

########################### Git + FZF Integrations ####################################

# fstash - easier way to deal with stashes
# type fstash to get a list of your stashes
# enter shows you the contents of the stash
# ctrl-d shows a diff of the stash against your current HEAD
# ctrl-b checks the stash out as a branch, for easier merging
fstash() {
  local out q k sha
  while out=$(
    git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
    fzf --ansi --no-sort --query="$q" --print-query \
        --expect=ctrl-d,ctrl-b);
  do
    mapfile -t out <<< "$out"
    q="${out[0]}"
    k="${out[1]}"
    sha="${out[-1]}"
    sha="${sha%% *}"
    [[ -z "$sha" ]] && continue
    if [[ "$k" == 'ctrl-d' ]]; then
      git diff $sha
    elif [[ "$k" == 'ctrl-b' ]]; then
      git stash branch "stash-$sha" $sha
      break;
    else
      git stash show -p $sha
    fi
  done
}

alias glNoGraph='git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr% C(auto)%an" "$@"'
_gitLogLineToHash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
_viewGitLogLine="$_gitLogLineToHash | xargs -I % sh -c 'git show --color=always %'"

# fcheckout - checkout git commit with previews
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
###################################### O ###############################################

# Load custom, per machine, options. Such as adding cuda libraries to path
if [ -f ~/.bashrc_extra ]; then
  . ~/.bashrc_extra
fi
