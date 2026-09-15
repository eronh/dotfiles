# Homebrew first. Its shellenv runs `fish_add_path --move`, which pulls
# /opt/homebrew/bin to the front of PATH, so running it after the lines below
# silently put Homebrew ahead of them.
if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv fish | source
end

set -gx PNPM_HOME $HOME/Library/pnpm

# User dirs go after Homebrew and the system, matching the zsh PATH order.
# fish_add_path skips dirs that don't exist; --path avoids writing universal vars
fish_add_path --path --append $HOME/.local/bin $PNPM_HOME/bin $HOME/.docker/bin

set -gx VISUAL nvim
set -gx EDITOR nvim

# can't remember for which tool this was needed
set -gx DISABLE_TELEMETRY 1

# wrap journal logs viewed in terminal rather than truncating
set -gx SYSTEMD_LESS FRXMK

if test -f /etc/os-release; and grep -q openSUSE /etc/os-release
    set -gx ZYPP_MEDIANETWORK 1
    set -gx ZYPP_CURL2 1
end
