PS1="\n \[\e[38;5;166m\]\u:\[\e[38;5;40m\]\w\[\e[38;5;51m\] > \[\e[0m\]"

set -o vi
HISTCONTROL=ignoreboth

export XDG_CURRENT_DESKTOP=sway
export EDITOR=nvim
export VISUAL=nvim

shopt -s checkwinsize

alias l="eza -l --icons=always"
alias ll="eza -la --icons=always"
alias ls='ls --color=auto'
alias ip='ip -color=auto'
alias ncdu='disk'
alias vi="nvim ~/vimwiki/index.md"
alias ff="fastfetch"
alias vim="nvim"
alias nb="newsboat"
alias img="swayimg"
alias record="asciinema rec"
alias play="asciinema play"
alias yt="yt-dlp"
alias fzf="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
alias grub-mkconfig="grub-mkconfig -o /boot/grub/grub.cfg"

eval "$(fzf --bash)"
