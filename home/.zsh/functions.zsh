# --- helpers used by the other config files ---
# True if $1 is a command on PATH. $commands is zsh's command hash table.
is_installed() {
    (( $+commands[$1] ))
}

# --- clipboard and files ---
# Copy stdin, or the output of the given command, to the system clipboard.
copy() {
    local -a clipboard_cmd
    if [[ "$(uname -s)" == "Darwin" ]]; then
        clipboard_cmd=(pbcopy)
    elif [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        clipboard_cmd=(wl-copy -n)
    else
        clipboard_cmd=(xclip -selection clipboard)
    fi

    if [[ $# -eq 0 ]]; then
        "${clipboard_cmd[@]}"
    else
        "$@" | "${clipboard_cmd[@]}"
    fi
}

mkcd() {
    mkdir -p "$1" && cd "$1"
}

compress() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: compress <archive-name> <files...>"
        return 1
    fi

    local archive="$1"
    shift

    # Match on the full name: `${archive##*.}` would turn `x.tar.gz` into `gz`.
    case "$archive" in
        *.tar) tar cf "$archive" "$@" ;;
        *.tar.gz | *.tgz) tar czf "$archive" "$@" ;;
        *.tar.bz2 | *.tbz2) tar cjf "$archive" "$@" ;;
        *.tar.xz | *.txz) tar cJf "$archive" "$@" ;;
        *.zip) zip -r "$archive" "$@" ;;
        *.7z) 7z a "$archive" "$@" ;;
        *.rar) rar a "$archive" "$@" ;;
        *)
            echo "Unsupported format: $archive"
            return 1
            ;;
    esac
}

# URL-encode or decode stdin when piped, otherwise the first argument.
urlencode() {
    python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read().strip() if sys.stdin.isatty() == False else sys.argv[1]))" "$@"
}

urldecode() {
    python3 -c "import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read().strip() if sys.stdin.isatty() == False else sys.argv[1]))" "$@"
}

# Append a command and its description to the cheat sheet (shared with fish).
addcmd() {
    local file="$HOME/.zsh/useful_commands.zsh"

    if [[ -z "$1" || -z "$2" ]]; then
        echo "Usage: addcmd <command> <description>"
        return 1
    fi

    # -F: the command is literal text, not a regex.
    if grep -qF -- "$1" "$file"; then
        echo "Command already exists in $file"
        return 0
    fi

    printf '# %s\n%s\n\n\n' "$2" "$1" >>"$file"
    echo "Command added to $file"
}

# --- zle widgets ---
clear_scrollback_buffer() {
    # Behavior of clear:
    # 1. clear scrollback if E3 cap is supported (terminal, platform specific)
    # 2. then clear visible screen
    # For some terminal 'e[3J' need to be sent explicitly to clear scrollback
    clear && printf '\e[3J'

    # .reset-prompt: bypass the zsh-syntax-highlighting wrapper
    # https://github.com/sorin-ionescu/prezto/issues/1026
    # https://github.com/zsh-users/zsh-autosuggestions/issues/107#issuecomment-183824034
    # -R: redisplay the prompt to avoid old prompts being eaten up
    # https://github.com/Powerlevel9k/powerlevel9k/pull/1176#discussion_r299303453
    zle && zle .reset-prompt && zle -R
}
zle -N clear_scrollback_buffer # bound to Ctrl+L in keybindings.zsh

# nvim() {
# 	# Resolve the absolute path of the first argument (if provided)
# 	local target_dir="$1"
#
# 	if [ -d "$target_dir" ]; then
# 		# If a directory is passed, use it as the working directory
# 		command nvim --cmd "cd $(realpath "$target_dir")" "$@"
# 	else
# 		# If it's a file or no argument, just open normally
# 		command nvim "$@"
# 	fi
# }

# --- tmux ---
# Disabled: sourcing .zshrc repeatedly is slow and stacks state; reload-tmux
# below restarts the shell instead.
# reload-tmux-with-source() {
#     if [[ -n "$TMUX" ]]; then
#         # List all panes globally, check if the active command is zsh, and extract the pane ID
#         tmux list-panes -a -F "#{pane_id} #{pane_current_command}" | awk '$2=="zsh" {print $1}' | while read -r pane; do
#             # Send the source command and press Enter (C-m)
#             tmux send-keys -t "$pane" "source ~/.zshrc" C-m
#         done
#         echo "Done! Reloaded .zshrc in all active zsh panes."
#     else
#         # Fallback if you run it outside of tmux
#         source ~/.zshrc
#         echo "Reloaded .zshrc locally."
#     fi
# }

# Restart the default shell in every tmux pane that runs it.
reload-tmux() {
    if [[ -n "$TMUX" ]]; then
        # Match panes by the default shell's name (zsh, fish, ...), not a hardcoded one
        tmux list-panes -a -F "#{pane_id} #{pane_current_command}" | awk -v sh="${SHELL:t}" '$2==sh {print $1}' | while read -r pane; do
            tmux send-keys -t "$pane" "exec $SHELL" C-m
        done
        echo "Done! Restarted ${SHELL:t} in all active panes."
    else
        exec "$SHELL"
    fi
}

# --- git ---
# Create worktree <repo>/<project>-<name> on a new branch (default: <name>).
gwc() {
    if [[ $# -lt 1 ]]; then
        echo "Usage: gwc <worktree-name> [branch]"
        return 1
    fi

    local wt_name="$1"
    local branch="${2:-$wt_name}"

    local repo_root
    repo_root=$(git rev-parse --show-toplevel) || return 1
    local project_name="${repo_root:t}"
    local wt_dir="$repo_root/$project_name-$wt_name"

    if [[ -d "$wt_dir" ]]; then
        echo "Worktree already exists: $wt_dir"
        return 1
    fi

    git worktree add -b "$branch" "$wt_dir" || return 1

    echo "Created worktree: $project_name-$wt_name"
    echo "Remove with: git worktree remove $project_name-$wt_name"
}

# `sb` is re-aliased on every cd to the sbx command for the current project
# (git toplevel, else cwd), so globalias expands it in place on <space>.
_sb_alias() {
    local root=${$(git rev-parse --show-toplevel 2>/dev/null):-$PWD}
    alias sb="sbx run --name ${(q-)${${root:t}//[^a-zA-Z0-9_-]/-}} claude"
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _sb_alias
_sb_alias
