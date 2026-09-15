# zsh reads ~/.zshenv (a link to this file) before anything else. ZDOTDIR
# points it at ~/.config/zsh for .zshrc and the rest of the config.
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# `pkill -USR1 zsh` restarts every interactive zsh, which reloads its config.
# Runs `zsh`, not $SHELL: the login shell is fish.
TRAPUSR1() {
    if [[ -o INTERACTIVE ]]; then
        { echo; echo "Reloading Zsh config"; } 1>&2
        exec zsh
    fi
}
