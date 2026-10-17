# Homebrew first. Its shellenv runs `fish_add_path --move`, which pulls
# the brew prefix to the front of PATH, so running it after the lines below
# would silently put Homebrew ahead of them.
for brew in /opt/homebrew/bin/brew /usr/local/bin/brew
    if test -x $brew
        $brew shellenv fish | source
        break
    end
end

if test (uname -s) = Darwin
    set -gx PNPM_HOME $HOME/Library/pnpm
else
    set -l data $XDG_DATA_HOME
    test -n "$data"; or set data $HOME/.local/share
    set -gx PNPM_HOME $data/pnpm
end

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
