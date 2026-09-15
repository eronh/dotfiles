
typeset -U PATH path FPATH fpath MANPATH manpath
typeset -U precmd_functions preexec_functions chpwd_functions

# Enable Powerlevel11k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh

# --- load order ---
# Homebrew goes on PATH first: the files below check `is_installed` and
# resolve tools (nvim, git, docker, podman) while they load.
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Errors are not silenced, so a broken config file shows up at startup.
source_if_exists() {
    [[ -f "$1" ]] && source "$1"
}

source_if_exists "$ZDOTDIR/exports.zsh"
source_if_exists "$ZDOTDIR/options.zsh"
source_if_exists "$ZDOTDIR/functions.zsh"
source_if_exists "$ZDOTDIR/plugins.zsh"
source_if_exists "$ZDOTDIR/aliases.zsh"
source_if_exists "$ZDOTDIR/keybindings.zsh"

# --- tool hooks ---
is_installed fzf && source <(fzf --zsh)
is_installed direnv && eval "$(direnv hook zsh)"
is_installed starship && eval "$(starship init zsh)"
# is_installed codex && eval "$(codex completion zsh)"

# --- completion ---
# Every fpath change must come before compinit, or its completions are missed.
# Plugins and aliases.zsh call `compdef` before compinit exists; zinit queues
# those calls and `zinit cdreplay` applies them once compinit has run.
fpath=("$HOME/.docker/completions" $fpath)
# The dump goes to the cache: its default location, $ZDOTDIR, is the dotfiles repo.
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
autoload -Uz compinit && compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
zinit cdreplay -q

# After compinit: mise registers tool completions (e.g. `usage`) with
# `compdef` on activation, and runs its own compinit if compdef is missing.
is_installed mise && eval "$(mise activate zsh)"

# Match completion candidates regardless of letter casing.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select

# Installer-added PATH lines (pnpm, antigravity, unity, lm studio) live in
# exports.zsh now. Installers may append them here again; move them if so.

