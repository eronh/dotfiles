# --- directories ---
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS
setopt CDABLE_VARS

# Simple autojump implementation
# https://duganchen.ca/the-simplest-autojump-implementation-for-zsh/
# autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
# add-zsh-hook chpwd chpwd_recent_dirs
# zstyle ':chpwd:*' recent-dirs-default yes
# zstyle ':completion:*' recent-dirs-insert always
# alias j=cdr

# --- history ---
HISTFILE="$HOME/.histfile"
HISTSIZE=10000
SAVEHIST=10000
HISTORY_IGNORE="(c|l|ls|la|ll)"

setopt SHARE_HISTORY        # implies incremental append; do not add INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS # a repeated command removes its older entry
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_NO_STORE

# --- completion ---
setopt COMPLETE_IN_WORD

# --- input ---
setopt GLOB_DOTS
setopt INTERACTIVE_COMMENTS
setopt PROMPT_SUBST
setopt CORRECT
