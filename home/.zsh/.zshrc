
typeset -U PATH path FPATH fpath MANPATH manpath
typeset -U precmd_functions preexec_functions chpwd_functions

# Enable Powerlevel11k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

autoload -Uz compinit
compinit
autoload -U colors && colors

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true

fpath=($HOME/.docker/completions $fpath)

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

# sourcing the .zshrc file many times can cause performance issues
# so there's another reload-tmux function that uses `exec zsh` instead
reload-tmux-with-source() {
  if [ -n "$TMUX" ]; then
    # List all panes globally, check if the active command is zsh, and extract the pane ID
    tmux list-panes -a -F "#{pane_id} #{pane_current_command}" | awk '$2=="zsh" {print $1}' | while read -r pane; do
      # Send the source command and press Enter (C-m)
      tmux send-keys -t "$pane" "source ~/.zshrc" C-m
    done
    echo "Done! Reloaded .zshrc in all active zsh panes."
  else
    # Fallback if you run it outside of tmux
    source ~/.zshrc
    echo "Reloaded .zshrc locally."
  fi
}

reload-tmux() {
  if [ -n "$TMUX" ]; then
    tmux list-panes -a -F "#{pane_id} #{pane_current_command}" | awk '$2=="zsh" {print $1}' | while read -r pane; do
      # Send the exec command instead of source
      tmux send-keys -t "$pane" "exec zsh" C-m
    done
    echo "Done! Restarted zsh in all active panes."
  else
    exec zsh
  fi
}
