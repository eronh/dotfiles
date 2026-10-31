#!/bin/bash

#region package definitions
# Same name in apt, dnf, pacman, zypper and apk
PACKAGES_COMMON=(
    "alacritty"
    "bat"
    "curl"
    "direnv"
    "eza"
    "ffmpeg"
    "fish"
    "fzf"
    "gawk"
    "git"
    "htop"
    "jq"
    "lazygit"
    "ncdu"
    "neovim"
    "ripgrep"
    "starship"
    "tmux"
    "trash-cli"
    "tree"
    "unzip"
    "vim"
    "vlc"
    "wget"
    "yt-dlp"
    "zoxide"
    "zsh"
)

PACKAGES_DNF=(
    "fd-find"
    "diff-so-fancy"
    "gh"
    "gcc"
    "gcc-c++"
    "make"
    "java-latest-openjdk"
    "openssh-clients"
    "python3"
    "python3-pip"
    "libyaml-devel"
    "tree-sitter-cli"
    "k9s"
    "kubectl"
    "kubectx"
    "minikube"
    "stern"
    "libpq-devel"
    "bpytop"
    "asciinema"
    "coreutils"
    "fswatch"
    "gnupg2"
)

PACKAGES_APT=(
    "fd-find"
    "gnupg"
    "build-essential"
    "libyaml-dev"
    "openjdk-11-jdk"
    "openssh-client"
    "bpytop"
    "python3"
    "python3-pip"
)

PACKAGES_PACMAN=(
    "base-devel"
    "bitwarden"
    "bpytop"
    "diff-so-fancy"
    "dolphin"
    "fd"
    "firefox"
    "firewalld"
    "gnupg"
    "inetutils"
    "intel-ucode"
    "jdk11-openjdk"
    "kdeconnect"
    "konsole"
    "libyaml"
    "openssh"
    "pacman-contrib"
    "python"
    "python-pip"
    "sddm"
    "solaar"
    "tree-sitter"
    "tree-sitter-cli"
    "wezterm"
    "wl-clipboard"
)

PACKAGES_ZYPPER=(
    "fd"
    "diff-so-fancy"
    "gh"
    "gcc"
    "gcc-c++"
    "make"
    "java-21-openjdk"
    "openssh"
    "python3"
    "python3-pip"
    "libyaml-devel"
    "tree-sitter"
    "k9s"
    "kubernetes-client"
    "kubectx"
    "minikube"
    "stern"
    "libpq5"
    "bpytop"
    "asciinema"
    "coreutils"
    "fswatch"
    "gpg2"
    "stylua"
    "shfmt"
    "wireguard-tools"
)
#endregion package definitions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.sh"

available_only() {
    local check="$1" pkg
    shift
    for pkg in "$@"; do
        if $check "$pkg" > /dev/null 2>&1; then
            echo "$pkg"
        else
            log_warning "Not available on this release, skipping: $pkg" >&2
        fi
    done
}

install_dependencies() {
    local os=$(uname -s)

    if [ "$os" = "Darwin" ]; then
        log_info "Checking macOS dependencies..."

        if ! xcode-select -p > /dev/null 2>&1; then
            xcode-select --install
            log_warning "Xcode Command Line Tools installation started. Please complete it and run this script again."
            exit 1
        fi

        if ! command_exists brew; then
            if ask_confirm "Homebrew is not installed. Would you like to install it and the recommended packages?"; then
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi

                log_info "Installing Homebrew packages from Brewfile..."
                brew bundle --file home/Brewfile
            else
                log_warning "Skipping Homebrew and package installation."
            fi
        else
            if ask_confirm "Would you like to install/update recommended packages via Homebrew?"; then
                log_info "Installing/updating Homebrew packages..."
                brew bundle --file home/Brewfile
            else
                log_info "Skipping Homebrew package update."
            fi
        fi

        log_success "macOS dependencies installed."
        return 0
    fi

    local distro=$(detect_os)
    local pkgs=("${PACKAGES_COMMON[@]}")
    local install_cmd=""
    local check_cmd=""

    if command_exists apt-get; then
        pkgs+=("${PACKAGES_APT[@]}")
        run apt-get update
        check_cmd="apt-get install -s"
        install_cmd="apt-get install -y"
    elif command_exists dnf; then
        pkgs+=("${PACKAGES_DNF[@]}")
        install_cmd="dnf install -y --skip-unavailable"
    elif command_exists pacman; then
        pkgs+=("${PACKAGES_PACMAN[@]}")
        run pacman -Sy
        check_cmd="pacman -Sp"
        # -Su after the -Sy above: installing on top of a partial upgrade is unsupported on Arch
        install_cmd="pacman -Su --noconfirm --needed"
    elif command_exists zypper; then
        pkgs+=("${PACKAGES_ZYPPER[@]}")
        install_cmd="zypper --ignore-unknown install -y"
    elif command_exists apk; then
        pkgs+=("openssh" "python3" "build-base")
        run apk update
        check_cmd="apk add -s"
        install_cmd="apk add --no-cache"
    else
        log_warning "No supported package manager found on $distro, skipping package installation."
        return 0
    fi

    if ask_confirm "Would you like to install recommended packages for $distro?"; then
        if [ -n "$check_cmd" ]; then
            mapfile -t pkgs < <(available_only "$check_cmd" "${pkgs[@]}")
        fi
        log_info "Installing dependencies..."
        run $install_cmd "${pkgs[@]}"
    else
        log_info "Skipping package installation."
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_dependencies
fi
