# ==================================================
# ~/.bashrc
# ==================================================

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Standard Arch Linux PS1 in blue
export PS1='\[\e[1;34m\][\u@\h \W]\$\[\e[0m\] '
export PS2='> '

# Set vim as primary editor
export EDITOR='vim'
export VISUAL='vim'

# Explicitly set pager to less
export PAGER='less'

# ==================================================
# Aliases
# ==================================================

alias ls='ls --color=auto'
alias l='ls -CF'
alias ll='ls -l'
alias la='ls -la'
alias grep='grep --color=auto'
alias todo='todo.sh'
alias t='todo.sh'
alias gtd='cd ~/drive/gtd'
alias finances='cd ~/drive/reference/finances'
# Also evaluate aliases preceded by 'sudo'
alias sudo='sudo '
