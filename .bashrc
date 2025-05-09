PS1="\n \[\e[38;5;166m\]\u:\[\e[38;5;40m\]\w\[\e[38;5;51m\] > \[\e[0m\]"

[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

set -o vi

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

shopt -s checkwinsize

alias l="eza -l --icons=always"
alias ll="eza -la --icons=always"
alias ls='ls --color=auto'
alias ip='ip -color=auto'
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

burn() {
    if [ $# -ne 2 ]; then
        echo "Usage: burn <input_file> <output_device>"
        return 1
    fi
    sudo dd if="$1" of="$2" bs=4M status=progress oflag=sync
}

eval "$(fzf --bash)"
