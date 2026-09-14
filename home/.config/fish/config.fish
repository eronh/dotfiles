if not status is-interactive
    return
end

# `pkill -USR1 fish` reloads every interactive fish
function __reload_on_usr1 --on-signal SIGUSR1
    exec fish
end

set -g fish_greeting

command -q fzf; and fzf --fish | source
command -q mise; and mise activate fish | source
command -q direnv; and direnv hook fish | source
command -q starship; and starship init fish | source
command -q zoxide; and zoxide init --cmd j fish | source
