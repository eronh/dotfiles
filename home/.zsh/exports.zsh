export VISUAL=$(which nvim)
export EDITOR="$VISUAL"

if grep -q 'openSUSE' /etc/os-release; then
    export ZYPP_MEDIANETWORK=1
    export ZYPP_CURL2=1
fi

path+=(
	"$HOME/.local/bin"
	"$HOME/.docker/bin"
	"/opt/homebrew/opt/libpq/bin"
	"/opt/homebrew/opt/gawk/libexec/gnubin"
)
