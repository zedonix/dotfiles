# If not running interactively, don't do anything
[[ $- != *i* ]] && return

parse_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
PS1='\n\033[1;36m[ \u@\h |\033[m \033[1;32m\w\033[m \033[1;36m]\033[m $(parse_git_branch)\n\[\e[38;5;51m\]>\[\e[0m\] '
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] &&
    . /usr/share/bash-completion/bash_completion

#set -o vi

shopt -s checkwinsize
shopt -s histappend

HISTCONTROL=ignoreboth

export PATH=$PATH:$HOME/.scripts/bin

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

export CARGO_HOME="$XDG_DATA_HOME"/cargo
export GOPATH="$XDG_DATA_HOME"/go
export HISTFILE="${XDG_STATE_HOME}"/bash/history

export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt6ct
export QT_STYLE_OVERRIDE=kvantum

export EDITOR=nvim
export VISUAL=nvim
export SYSTEMD_EDITOR=nvim
export MANPAGER="nvim +Man!"
export PAGER="nvim -R"

alias l="eza -l --icons=always --group-directories-first"
alias ll="eza -la --icons=always --group-directories-first"

alias ls='ls --color=auto'
alias ip='ip -color=auto'
alias grep='grep --color=auto'
alias fzf="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
alias df="df -h"

alias cp="cp -i"

alias vim="nvim"
alias vi="nvim +VimwikiIndex"
alias v="vifm"

alias ff="fastfetch"
alias nb="newsboat"
alias img="swayimg"

alias jrctl="journalctl -p 3 -xb"
alias grub-mkconfig="sudo grub-mkconfig -o /boot/grub/grub.cfg"

burn() {
    if [ $# -ne 2 ]; then
        echo "Usage: burn <input_file> <output_device>"
        return 1
    fi
    sudo dd if="$1" of="$2" bs=4M status=progress oflag=sync
}

ex() {
    if [ -f $1 ]; then
        case $1 in
        *.tar.bz2) tar xjf $1 ;;
        *.tar.gz) tar xzf $1 ;;
        *.tar.xz) tar xf $1 ;;
        *.bz2) bunzip2 $1 ;;
        *.rar) unrar x $1 ;;
        *.gz) gunzip $1 ;;
        *.tar) tar xf $1 ;;
        *.tbz2) tar xjf $1 ;;
        *.tgz) tar xzf $1 ;;
        *.zip) unzip $1 ;;
        *.Z) uncompress $1 ;;
        *.7z) 7z x $1 ;;
        *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# batdiff() {
#     git diff --name-only --relative --diff-filter=d | xargs bat --diff
# }

source /usr/share/wikiman/widgets/widget.bash
eval "$(fzf --bash)"
# eval "$(batman --export-env)"
