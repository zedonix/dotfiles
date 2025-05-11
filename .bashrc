# If not running interactively, don't do anything
[[ $- != *i* ]] && return

parse_git_branch() {
             git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
PS1='\n\033[1;36m[ \u |\033[m \033[1;32m\w\033[m \033[1;36m]\033[m $(parse_git_branch)\n\[\e[38;5;51m\]>\[\e[0m\] '
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

set -o vi

shopt -s checkwinsize
shopt -s histappend

HISTCONTROL=ignoreboth
export HISTFILE="${XDG_STATE_HOME}"/bash/history

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway
export QT_QPA_PLATFORM=wayland

export EDITOR=nvim
export VISUAL=nvim

export GOPATH="$XDG_DATA_HOME"/go

alias l="eza -l --icons=always --group-directories-first"
alias ll="eza -la --icons=always --group-directories-first"
alias l.="eza -al --icons=always | grep '\.'"

alias x="exit"
alias c="clear"

alias ls='ls --color=auto'
alias ip='ip -color=auto'
alias grep='grep --color=auto'
alias fzf="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"

alias cp="cp -i"

alias vi="nvim ~/vimwiki/index.md"
alias vim="nvim"

alias ff="fastfetch"
alias nb="newsboat"
alias img="loupe"
alias record="asciinema rec"
alias play="asciinema play"
alias ipaddr="curl ipinfo.io"

alias jrctl="journalctl -p 3 -xb"
alias grub-mkconfig="sudo grub-mkconfig -o /boot/grub/grub.cfg"

burn() {
    if [ $# -ne 2 ]; then
        echo "Usage: burn <input_file> <output_device>"
        return 1
    fi
    sudo dd if="$1" of="$2" bs=4M status=progress oflag=sync
}

eval "$(fzf --bash)"
