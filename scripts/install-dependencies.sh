#!/bin/bash

#region package definitions
PACKAGES_COMMON=(
    "alacritty"
    "bat"
    "fzf"
    "ripgrep"
    "tree"
    "unzip"
    "htop"
    "ncdu"
    "jq"
    "curl"
    "wget"
    "git"
    "tmux"
    "vim"
    "neovim"
    "ffmpeg"
    "yt-dlp"
    "trash-cli"
    "direnv"
    "gawk"
    "zsh"
    "vlc"
    "lazygit"
)

PACKAGES_DNF=(
    "wezterm"
    "fd-find"
    "diff-so-fancy"
    "gh"
    "gcc"
    "gcc-c++"
    "make"
    "java-latest-openjdk"
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
    "konsole"
    "libyaml"
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
    "lazygit"
    "stylua"
    "shfmt"
    "wireguard-tools"
)
#endregion package definitions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.sh"

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
    local pkgs=()
    local install_cmd=""

    case "$distro" in
        ubuntu | debian | kali | neon | pop | pureos | raspbian)
            pkgs=("${PACKAGES_COMMON[@]}" "${PACKAGES_APT[@]}")
            run apt update
            install_cmd="apt install -y"
            ;;
        fedora | centos)
            local mgr="dnf"
            if ! command_exists dnf; then mgr="yum"; fi
            pkgs=("${PACKAGES_COMMON[@]}" "${PACKAGES_DNF[@]}")
            install_cmd="$mgr install -y --skip-unavailable"
            ;;
        arch | manjaro)
            pkgs=("${PACKAGES_COMMON[@]}" "${PACKAGES_PACMAN[@]}")
            install_cmd="pacman -Sy --noconfirm --needed"
            ;;
        opensuse*)
            pkgs=("${PACKAGES_COMMON[@]}" "${PACKAGES_ZYPPER[@]}")
            install_cmd="zypper --ignore-unknown install -y"
            ;;
        alpine)
            pkgs=("${PACKAGES_COMMON[@]}" "python3" "build-base")
            install_cmd="apk add --no-cache"
            ;;
        *)
            # For other distros, try to detect package manager and at least install common packages
            if command_exists apt; then
                pkgs=("${PACKAGES_COMMON[@]}")
                run apt update
                install_cmd="apt install -y"
            elif command_exists dnf; then
                pkgs=("${PACKAGES_COMMON[@]}")
                install_cmd="dnf install -y --skip-unavailable"
            elif command_exists pacman; then
                pkgs=("${PACKAGES_COMMON[@]}")
                install_cmd="pacman -S --noconfirm --needed"
            elif command_exists zypper; then
                pkgs=("${PACKAGES_COMMON[@]}")
                install_cmd="zypper --ignore-unknown install -y"
            elif command_exists apk; then
                pkgs=("${PACKAGES_COMMON[@]}")
                install_cmd="apk add --no-cache"
            fi
            ;;
    esac

    if [ ${#pkgs[@]} -gt 0 ]; then
        if ask_confirm "Would you like to install recommended packages for $distro?"; then
            log_info "Installing dependencies..."
            run $install_cmd "${pkgs[@]}"
        else
            log_info "Skipping package installation."
        fi
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_dependencies
fi
