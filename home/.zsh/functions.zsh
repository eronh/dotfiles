function is_installed {
    if [[ -n $ZSH_VERSION ]]; then
        builtin whence -p "$1" &>/dev/null
    else
        builtin type -P "$1" &>/dev/null
    fi
}

function is_not_alias {
    # local command_type="$(builtin whence -w docker)"
    # if [[ "$command_type" == "alias"]] then
    # 	echo  "is alias"
    # 	# return 1
    # fi

    if [[ $(builtin whence -w $1) == "$1: alias" ]]; then
        return 1
    fi

    return 0
}

copy() {
    local -a clipboard_cmd
    if [[ "$(uname -s)" == "Darwin" ]]; then
        clipboard_cmd=(pbcopy)
    elif [[ "${XDG_SESSION_TYPE}" == "wayland" ]]; then
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
    mkdir "$1"
    cd "$1"
}

function clear_scrollback_buffer {
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

zle -N clear_scrollback_buffer
bindkey '^L' clear_scrollback_buffer

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

compress() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: compress <archive-name> <files...>"
        return 1
    fi

    local archive="$1"
    shift

    case "${archive##*.}" in
        tar) tar cf "$archive" "$@" ;;
        tar.gz | tgz) tar czf "$archive" "$@" ;;
        tar.bz2 | tbz2) tar cjf "$archive" "$@" ;;
        tar.xz | txz) tar cJf "$archive" "$@" ;;
        zip) zip -r "$archive" "$@" ;;
        7z) 7z a "$archive" "$@" ;;
        rar) rar a "$archive" "$@" ;;
        *) echo "Unsupported format: ${archive##*.}" ;;
    esac
}

urlencode() {
    python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read().strip() if sys.stdin.isatty() == False else sys.argv[1]))" "$@"
}

urldecode() {
    python3 -c "import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read().strip() if sys.stdin.isatty() == False else sys.argv[1]))" "$@"
}

addcmd() {
    local command="$1"
    local description="$2"
    local file="$HOME/.zsh/useful_commands.zsh"

    if [[ -z "$command" || -z "$description" ]]; then
        echo "Usage: addcmd <command> <description>"
        return 1
    fi

    if grep -q "$command" "$file"; then
        echo "Command already exists in $file"
        return 0
    fi

    echo "# $description" >>"$file"
    echo "$command" >>"$file"
    echo "\n\n" >>"$file"
    echo "Command added to $file"

    return 0
}

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
        # Match panes by the default shell's name (zsh, fish, ...), not a hardcoded one
        tmux list-panes -a -F "#{pane_id} #{pane_current_command}" | awk -v sh="${SHELL:t}" '$2==sh {print $1}' | while read -r pane; do
            # Send the exec command instead of source
            tmux send-keys -t "$pane" "exec $SHELL" C-m
        done
        echo "Done! Restarted ${SHELL:t} in all active panes."
    else
        exec "$SHELL"
    fi
}

gwc() {
    if [[ $# -lt 1 ]]; then
        echo "Usage: gwt <worktree-name> [branch]"
        return 1
    fi

    local wt_name="$1"
    local branch=""
    if [[ $# -ge 2 ]]; then
        branch="$2"
    else
        branch="$wt_name"
    fi

    local repo_root
    repo_root=$(git rev-parse --show-toplevel) || return 1
    local project_name
    project_name=$(basename "$repo_root")

    local wt_dir="${repo_root}/${project_name}-${wt_name}"

    if [[ -d "$wt_dir" ]]; then
        echo "Worktree already exists: $wt_dir"
        return 1
    fi

    git worktree add -b "$branch" "$wt_dir"

    echo "Created worktree: ${project_name}-${wt_name}"
    echo "Remove with: git worktree remove ${project_name}-${wt_name}"
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
