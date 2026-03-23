alias c="clear && printf '\e[3J'"
alias vim=$(which nvim)
alias xablau="npm run dev:debug"
alias xcurl="curl -o /dev/null -s -w %{time_total}"
alias jw='cd $HOME/Workbench/'

alias gs="git sync"
alias g-="git switch -"
alias glr="git pull --rebase"
alias grbo="git rebase --onto <new> <old> <current-branch>"

if [[ -f /etc/os-release ]]  && grep -q 'openSUSE' /etc/os-release; then
    alias zref="sudo zypper refresh"
    alias zdup="sudo zypper -v dist-upgrade --download-in-advance"
    alias zin="sudo zypper -v install"
    alias zse="zypper search"
fi

# .oh-my-zsh/lib/directories.zsh
# Changing/making/removing directory
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

alias -- -='cd -'
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

# List directory contents
alias l='ls -lAh'
alias ll='ls -lh'
alias la='ls -lah'

# File management
unset alias cp
unset alias mv
unset alias rm

# Docker Compose
docker_cmd="docker"

# Podman
if is_installed podman; then
	docker_cmd="podman"
	alias docker=podman
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

alias //="brew update && brew upgrade && brew cleanup"
alias vimrc="vim $HOME/.vimrc"
alias wezrc="nvim $HOME/.config/wezterm/wezterm.lua"

# clear scrollback. see: https://apple.stackexchange.com/a/113168
alias c="clear && printf '\e[3J'"

# deduplicate history
alias histclean='nl ~/.bash_history | sort -k 2  -k 1,1nr| uniq -f 1 | sort -n | cut -f 2 > unduped_history && cp unduped_history ~/.bash_history'

