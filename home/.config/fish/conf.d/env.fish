set -gx PNPM_HOME $HOME/Library/pnpm

# fish_add_path skips dirs that don't exist; --path avoids writing universal vars
fish_add_path --path $HOME/.docker/bin
fish_add_path --path /opt/homebrew/opt/libpq/bin $HOME/.cargo/bin $PNPM_HOME/bin $HOME/.local/bin
fish_add_path --path --append $HOME/.docker/bin $HOME/.lmstudio/bin

set -gx VISUAL vim
set -gx EDITOR vim

# can't remember for which tool this was needed
set -gx DISABLE_TELEMETRY 1

# wrap journal logs viewed in terminal rather than truncating
set -gx SYSTEMD_LESS FRXMK

if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv fish | source
end

if test -f /etc/os-release; and grep -q openSUSE /etc/os-release
    set -gx ZYPP_MEDIANETWORK 1
    set -gx ZYPP_CURL2 1
end
