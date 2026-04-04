autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

bindkey -e

bindkey "^[[3~" delete-char                     # Key Del
bindkey "^[[5~" beginning-of-buffer-or-history  # Key Page Up
bindkey "^[[6~" end-of-buffer-or-history        # Key Page Down
bindkey "^[[H" beginning-of-line                # Key Home
bindkey "^[[F" end-of-line                      # Key End
bindkey "^[[1;3C" forward-word                  # Key Alt + Right
bindkey "^[[1;3D" backward-word                 # Key Alt + Left

WORDCHARS='*?_[]~!#$%^(){}<>'
autoload -Uz select-word-style
select-word-style normal
zstyle ':zle:*' word-style unspecified

# From KDE

# Set keybinds to emacs mode.

# Ensure Home, End, Delete and Insert keys work as users expect.
# Home key:
bindkey '\e[1~' beginning-of-line
bindkey '\e[H'  beginning-of-line
bindkey '\eOH'  beginning-of-line
# End key:
bindkey '\e[4~' end-of-line
bindkey '\e[F'  end-of-line
bindkey '\eOF'  end-of-line
# Delete key (forward delete):
bindkey '\e[3~' delete-char
# Insert key (toggle overwrite mode):
bindkey '\e[2~' overwrite-mode
# Word navigation
bindkey '^[[1;5D' backward-word     # Ctrl+Left
bindkey '^[[1;5C' forward-word      # Ctrl+Right
bindkey '^H' backward-kill-word     # Ctrl+Backspace
bindkey '^[[3;5~' kill-word         # Ctrl+Delete
# Scroll through commands in history that start with current command line:
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '\e[5~' up-line-or-beginning-search     # Page up
bindkey '\e[6~' down-line-or-beginning-search   # Page down

