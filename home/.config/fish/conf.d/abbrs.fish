abbr -a .f 'exec fish'
abbr -a // 'brew update && brew upgrade && brew cleanup'
abbr -a xcurl 'curl -o /dev/null -s -w %{time_total}'
abbr -a vimrc '$EDITOR $HOME/.vimrc'
abbr -a wezrc 'nvim $HOME/.config/wezterm/wezterm.lua'
abbr -a histclean 'nl ~/.bash_history | sort -k 2 -k 1,1nr | uniq -f 1 | sort -n | cut -f 2 > unduped_history && cp unduped_history ~/.bash_history'

abbr -a -- - 'cd -'
abbr -a --position anywhere ... ../..
abbr -a --position anywhere .... ../../..
abbr -a --position anywhere ..... ../../../..
abbr -a --position anywhere ...... ../../../../..

# tmux
abbr -a tks '~/.tmux/plugins/tmux-resurrect/scripts/save.sh && tmux kill-server'
abbr -a tkk 'tmux detach'
abbr -a /q 'tmux detach'

# git: the full git plugin set lives in git.fish
abbr -a g- 'git switch -'
abbr -a gs 'git sync'
abbr -a glr 'git pull --rebase'
abbr -a grbo 'git rebase --onto <new> <old> <current-branch>'
abbr -a gw 'git worktree'
abbr -a gwa 'git worktree add'
abbr -a gwls 'git worktree list'
abbr -a gwrm 'git worktree remove'

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

# Create and run docker sandboxesfor for the current project (git toplevel, else cwd).
# Defined here rather than in functions/ so the abbr never outlives its helper.
# Example: sbx run --name <dynamic project dir> claude
function _sb_abbr
    set -l root (git rev-parse --show-toplevel 2>/dev/null; or pwd)
    echo "sbx run --name "(string replace -ra '[^a-zA-Z0-9_-]' '-' (basename $root))" claude"
end
abbr -a sb --function _sb_abbr
