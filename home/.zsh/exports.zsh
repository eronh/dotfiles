export VISUAL=$(which nvim)
export EDITOR="$VISUAL"

# Wrap journal logs viewed in terminal rather than truncating; friendlier for reading
# and copying
export SYSTEMD_LESS=FRXMK

if [[ -f /etc/os-release ]] && grep -q 'openSUSE' /etc/os-release; then
    export ZYPP_MEDIANETWORK=1
    export ZYPP_CURL2=1
fi

path+=(
	"$HOME/.local/bin"
	"$HOME/.docker/bin"
	"/opt/homebrew/opt/libpq/bin"
	"/opt/homebrew/opt/gawk/libexec/gnubin"
)
