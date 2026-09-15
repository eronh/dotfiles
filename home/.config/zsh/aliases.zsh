# --- general ---
alias c="clear && printf '\e[3J'"
alias vi="vim"
alias vim="nvim"
alias xcurl="curl -o /dev/null -s -w %{time_total}"
alias jw="cd $HOME/Workbench/"
alias //="brew update && brew upgrade && brew cleanup"

# --- tmux ---
alias tks="$HOME/.tmux/plugins/tmux-resurrect/scripts/save.sh && tmux kill-server"
alias tkk="tmux detach"
alias tt="tmux new-session -A -s H"

# --- git ---
alias gs="git sync"
alias g-="git switch -"
alias glr="git pull --rebase"
# alias grbo="git rebase --onto <new> <old> <current-branch>"
alias gw="git worktree"
alias gwa="git worktree add"
alias gwls="git worktree list"
alias gwrm="git worktree remove"

# --- directories ---
# From .oh-my-zsh/lib/directories.zsh; the related options are in options.zsh.
alias -- -="cd -"
alias -g ...="../.."
alias -g ....="../../.."
alias -g .....="../../../.."
alias -g ......="../../../../.."

alias j="zshz 2>&1"

is_installed eza && alias ls="eza --color=always --long --git --icons=always --header"
alias l="ls -lAh"
alias ll="ls -lh"
alias la="ls -lah"

# --- containers ---
docker_cmd="docker"
if is_installed podman; then
    docker_cmd="podman"
    alias docker="podman"
    # compinit has not run yet; zinit queues this and `zinit cdreplay` applies it.
    compdef _podman docker
fi
alias dco="$docker_cmd compose"
alias dcb="$docker_cmd compose build"
alias dce="$docker_cmd compose exec"
alias dcps="$docker_cmd compose ps"
alias dcrestart="$docker_cmd compose restart"
alias dcrm="$docker_cmd compose rm"
alias dcr="$docker_cmd compose run"
alias dcstop="$docker_cmd compose stop"
alias dcup="$docker_cmd compose up"
alias dcupb="$docker_cmd compose up --build"
alias dcupd="$docker_cmd compose up -d"
alias dcupdb="$docker_cmd compose up -d --build"
alias dcdn="$docker_cmd compose down"
alias dcl="$docker_cmd compose logs"
alias dclf="$docker_cmd compose logs -f"
alias dclF="$docker_cmd compose logs -f --tail 0"
alias dcpull="$docker_cmd compose pull"
alias dcstart="$docker_cmd compose start"
alias dck="$docker_cmd compose kill"
unset docker_cmd
