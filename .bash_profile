#-------------------------------------------------------------
# Environment Variables
#-------------------------------------------------------------

# Set bash prompt
export PS1="\[\033[0;34m\]\u@\h$\[\033[0m\] "

# Color terminal
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Homebrew
export PATH=/usr/local/bin:/usr/local/sbin:$PATH

# Increase history size
HISTSIZE=10000

# Include timestamps in history format
HISTTIMEFORMAT="%m/%d/%y %T "

#-------------------------------------------------------------
# Startup
#-------------------------------------------------------------

fortune

# Bash Completion
if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi

#-------------------------------------------------------------
# Navigation
#-------------------------------------------------------------

alias ..='cd ..; pwd'
alias ...='cd ../..; pwd'
alias ....='cd ../../..; pwd'
alias .....='cd ../../../..; pwd'
alias desktop='cd ~/Desktop/; pwd'
alias ~='cd ~; pwd'

#-------------------------------------------------------------
# The 'ls' Family
#-------------------------------------------------------------

alias ll='ls -l'            # list long form
alias ls='ls -hF'           # add colors for filetype recognition
alias la='ls -la'           # show hidden files
alias lk='ls -lSr'          # sort by size, biggest last
alias lc='ls -ltcr'         # sort by and show change time, most recent last
alias lu='ls -ltur'         # sort by and show access time, most recent last
alias lt='ls -ltr'          # sort by date, most recent last
alias lm='ls -al | less'    # pipe through 'less'
alias lr='ls -lR'           # recursive ls

#-------------------------------------------------------------
# Git
#-------------------------------------------------------------

alias gs='git status'
alias gb='git branch'
alias gl='git lg | head; printf "\r"'
alias gd="git diff"
alias gdc='git diff --cached'
alias gdn='git diff --name-only'
alias gdi='git diff --ignore-space-change'
alias gsl='git stash list'
alias gitk='gitk --all 2>/dev/null'
alias sgs=‘subl `git status --porcelain | sed -ne "s/^UU //p"`’

#-------------------------------------------------------------
# Development Servers
#-------------------------------------------------------------

alias fs='foreman start'
alias fsd='foreman start -f Procfile.dev'
alias fsde='foreman start -f Procfile.dev -e env.dev'
alias frd='foreman run -f Procfile.dev'
alias frde='foreman run -f Procfile.dev -e env.dev'
alias pmpy='python manage.py'
alias ds='pmpy shell_plus'
alias serve='chrome "http://localhost:8080"; http-server > /dev/null 2>&1&'

#-------------------------------------------------------------
# VirtualEnvWrapper
#-------------------------------------------------------------

export WORKON_HOME=/var/local/venv
export WH=$WORKON_HOME
export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python
export VIRTUALENVWRAPPER_HOOK_DIR=$WORKON_HOME
export VIRTUALENVWRAPPER_LOG_DIR=$WORKON_HOME
source /usr/local/bin/virtualenvwrapper.sh

#-------------------------------------------------------------
# RVM
#-------------------------------------------------------------

# Add RVM to PATH for scripting
export PATH="$PATH:$HOME/.rvm/bin"

# Load RVM into a shell session as a function
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

#-------------------------------------------------------------
# Miscellaneous
#-------------------------------------------------------------

alias ebrc='subl ~/.bashrc'
alias ebp='subl ~/.bash_profile'
alias reload!='source ~/.bash_profile'

alias ehosts='sudo subl /private/etc/hosts'
alias flush_cache='dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

alias essh='subl ~/.ssh/config'

alias pshop='open -a /Applications/Adobe\ Photoshop\ CS6/Adobe\ Photoshop\ CS6.app/'
alias ill='open -a /Applications/Adobe\ Illustrator\ CS6/Adobe\ Illustrator.app/'
alias preview='open -a /Applications/Preview.app/'
alias recent='history | grep'

alias random_password='openssl rand -base64 8 | pbcopy; pbpaste'
alias cpd='pwd | pbcopy; pbpaste'
alias pg_datetime_now='date -u +"%Y-%m-%d %H:%M:%S.000000" | pbcopy; pbpaste'
alias whatsmyip='curl ifconfig.co'
alias pycclean='find . -type f -name *.pyc -exec rm -rf {} \; && find . -type d -name __pycache__ -exec rm -rf {} \;'

alias sed='gsed' # Fixes SSH autocomplete issue with hostnames starting with the letter 't'

alias lorem='echo -n "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." | pbcopy'
alias lor='echo -n "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua." | pbcopy'

#-------------------------------------------------------------
# Functions
#-------------------------------------------------------------

trash() { mv $@ ~/.Trash/ ; }

google () {
    query=''
    for arg in $@; do
        query="$query%20$arg"
    done;
    open "http://www.google.com/search?q=$query"
}

safari () {
    url=$1
    if [ ! -e "$url" ] && [[ ! "$url" =~ http://.* ]]
    then
        url="http://$url"
    fi
    open -a "Safari" $url ;
}

firefox () {
    url=$1
    if [ ! -e "$url" ] && [[ ! "$url" =~ http://.* ]]
    then
        url="http://$url"
    fi
    open -a "Firefox" $url ;
}

chrome () {
    url=$1
    if [ ! -e "$url" ] && [[ ! "$url" =~ http://.* ]]
    then
        url="http://$url"
    fi
    open -a "Google Chrome" $url ;
}

