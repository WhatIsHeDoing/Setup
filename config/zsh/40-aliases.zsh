# A bare eza `--icons` takes an optional value and swallows the next argument,
# so spell it `--icons=auto`.

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cat='bat --pager=never'
alias cd='z'
alias ll='eza -lah --icons=auto --git'
alias ls='eza --icons=auto'
alias lt='eza --tree --icons=auto -L 2'
