bindkey -e

# --- history search ---
# Up/Down search history for lines that start with the text already typed.
# The -end variants also move the cursor to the end of the line.
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end # Up
bindkey "^[[B" history-beginning-search-forward-end  # Down
bindkey "^[OA" history-beginning-search-backward-end # Up
bindkey "^[OB" history-beginning-search-forward-end  # Down

# Page Up/Down run the same kind of search.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[5~" up-line-or-beginning-search   # Page Up
bindkey "^[[6~" down-line-or-beginning-search # Page Down
# Disabled: these were overridden by the two bindings above.
# bindkey "^[[5~" beginning-of-buffer-or-history # Page Up
# bindkey "^[[6~" end-of-buffer-or-history       # Page Down

# --- editing and movement ---
bindkey "^[[H" beginning-of-line  # Home
bindkey "^[OH" beginning-of-line  # Home
bindkey "^[[1~" beginning-of-line # Home
bindkey "^[[F" end-of-line        # End
bindkey "^[OF" end-of-line        # End
bindkey "^[[4~" end-of-line       # End
bindkey "^[[3~" delete-char       # Delete
bindkey "^[[2~" overwrite-mode    # Insert
bindkey "^[[1;3C" forward-word    # Alt+Right
bindkey "^[[1;3D" backward-word   # Alt+Left
bindkey "^[[1;5C" forward-word    # Ctrl+Right
bindkey "^[[1;5D" backward-word   # Ctrl+Left
bindkey "^H" backward-kill-word   # Ctrl+Backspace
bindkey "^[[3;5~" kill-word       # Ctrl+Delete
bindkey "^L" clear_scrollback_buffer # Ctrl+L, widget defined in functions.zsh

# --- word style ---
# Word motions and kills stop at characters missing from WORDCHARS. The zsh
# default includes `/ - . = & ;`; dropping them makes path segments and flags
# separate words.
WORDCHARS='*?_[]~!#$%^(){}<>'
autoload -Uz select-word-style
select-word-style normal
zstyle ':zle:*' word-style unspecified
