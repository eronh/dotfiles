
# Enable Powerlevel11k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

typeset -U path  # Make sure PATH entries are unique

# To customize prompt, run `p10k configure` or edit ~/Workbench/dotfiles/home/.p10k.zsh.
[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh

source $HOME/.zsh/options.zsh
source $HOME/.zsh/functions.zsh
source $HOME/.zsh/plugins.zsh
source $HOME/.zsh/aliases.zsh
source $HOME/.zsh/keybindings.zsh
source $HOME/.zsh/exports.zsh

command -v fzf >/dev/null && source <(fzf --zsh)

is_installed mise && eval "$($HOME/.local/bin/mise activate zsh)"
is_installed direnv && eval "$(direnv hook zsh)"
is_installed yarn && path+=$(yarn global bin)

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

export PATH="/opt/homebrew/sbin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"

# Only run this if we are inside a tmux session
if [[ -n "$TMUX" ]]; then
  autoload -U add-zsh-hook

  set_tmux_window_name() {
    local dir="${PWD:t}"

    # Strip everything up to the last hyphen
    dir="${dir##*-}"

    # Capitalize the first letter natively
    dir="${(C)dir}"

    [[ -z "$dir" ]] && dir="/"
    tmux rename-window "$dir"
  }
add-zsh-hook chpwd set_tmux_window_name
set_tmux_window_name
fi
