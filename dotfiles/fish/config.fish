set -U fish_greeting

set -Ux QT_QPA_PLATFORMTHEME qt6ct

set -x STARSHIP_CONFIG ~/.config/starship/starship.toml
starship init fish | source

alias config="/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME"
alias ls="exa -la"

abbr --add cdc "~/.config/"
abbr --add ff "fastfetch"

if status is-interactive
    # Commands to run in interactive sessions can go here
end

fish_add_path ~/.local/bin
