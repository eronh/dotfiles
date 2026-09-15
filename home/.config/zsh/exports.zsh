export VISUAL="nvim"
export EDITOR="$VISUAL"

# Wrap journal logs viewed in terminal rather than truncating; friendlier for reading
# and copying
export SYSTEMD_LESS=FRXMK

export DISABLE_TELEMETRY=1

if [[ -f /etc/os-release ]] && grep -q 'openSUSE' /etc/os-release; then
    export ZYPP_MEDIANETWORK=1
    export ZYPP_CURL2=1
fi

# --- PATH ---
# `typeset -U path` in .zshrc drops duplicates, so no guards are needed here.
# Entries before $path take precedence over Homebrew and the system.
export PNPM_HOME="$HOME/Library/pnpm"
path=(
    $path
    "$HOME/.local/bin" # also used by the Antigravity CLI installer
    "$PNPM_HOME/bin"
    "/opt/homebrew/opt/libpq/bin"
    "$HOME/.docker/bin"
)
