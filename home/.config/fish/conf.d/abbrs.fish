# conf.d runs for scripts too; abbreviations only matter at a prompt.
status is-interactive; or return

abbr -a .f 'exec fish'
abbr -a xcurl 'curl -o /dev/null -s -w %{time_total}'
abbr -a vimrc '$EDITOR $HOME/.vimrc'
abbr -a wezrc 'nvim $HOME/.config/wezterm/wezterm.lua'

abbr -a -- - 'cd -'
abbr -a --position anywhere ... ../..
abbr -a --position anywhere .... ../../..
abbr -a --position anywhere ..... ../../../..
abbr -a --position anywhere ...... ../../../../..

# tmux
abbr -a tks '~/.tmux/plugins/tmux-resurrect/scripts/save.sh && tmux kill-server'
abbr -a tkk 'tmux detach'

# docker
set -l docker_cmd docker
if command -q podman
    set docker_cmd podman
    abbr -a docker podman
end
abbr -a dco "$docker_cmd compose"
abbr -a dcb "$docker_cmd compose build"
abbr -a dce "$docker_cmd compose exec"
abbr -a dcps "$docker_cmd compose ps"
abbr -a dcrestart "$docker_cmd compose restart"
abbr -a dcrm "$docker_cmd compose rm"
abbr -a dcr "$docker_cmd compose run"
abbr -a dcstop "$docker_cmd compose stop"
abbr -a dcup "$docker_cmd compose up"
abbr -a dcupb "$docker_cmd compose up --build"
abbr -a dcupd "$docker_cmd compose up -d"
abbr -a dcupdb "$docker_cmd compose up -d --build"
abbr -a dcdn "$docker_cmd compose down"
abbr -a dcl "$docker_cmd compose logs"
abbr -a dclf "$docker_cmd compose logs -f"
abbr -a dclF "$docker_cmd compose logs -f --tail 0"
abbr -a dcpull "$docker_cmd compose pull"
abbr -a dcstart "$docker_cmd compose start"
abbr -a dck "$docker_cmd compose kill"

# Full package manager update.
if test (uname -s) = Darwin
    abbr -a // 'brew update && brew upgrade && brew cleanup'
else if command -q apt
    abbr -a // 'sudo apt update && sudo apt full-upgrade && sudo apt autoremove'
else if command -q dnf
    abbr -a // 'sudo dnf upgrade --refresh && sudo dnf autoremove'
else if command -q zypper
    abbr -a // 'sudo zypper refresh && sudo zypper update'
else if command -q pacman
    abbr -a // 'sudo pacman -Syu'
end

# Docker sandboxes, named after the current project (git toplevel, else cwd).
# Defined here rather than in functions/ so the abbrs never outlive their helpers.
function _sb_name
    set -l root (git rev-parse --show-toplevel 2>/dev/null; or pwd)
    string replace -ra '[^a-zA-Z0-9_-]' - (basename $root)
end
# Example: sbx run --name <dynamic project dir> claude
function _sb_abbr
    echo "sbx run --name "(_sb_name)" claude"
end
# Run a command in the existing sandbox, e.g. `sbe claude update`
# Example: sbx exec <dynamic project dir> claude update
function _sbe_abbr
    echo "sbx exec "(_sb_name)
end
abbr -a sb --function _sb_abbr
abbr -a sbe --function _sbe_abbr
# Update claude in every sandbox; `sbx exec` starts stopped ones first
abbr -a sbua 'for s in (sbx ls -q); echo "== $s"; sbx exec $s claude update; end'
