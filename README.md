# Dotfiles

Personal dotfiles configuration with support for Linux and macOS.

## Quick Installation

```shell
curl -fsSL https://raw.githubusercontent.com/heronsilva/dotfiles/master/bootstrap | bash
```

This will:

- Automatically detect your operating system (macOS or Linux)
- Install prerequisites (Homebrew on macOS, package managers on Linux)
- Clone the repository
- Create backups of existing dotfiles
- Install and link dotfiles configuration

### Manual Installation

If you prefer to clone the repository first:

```shell
git clone https://github.com/heronsilva/dotfiles.git ~/Workbench/dotfiles
cd ~/Workbench/dotfiles
./install
```

## Platform Support

### macOS

- Prompts to install Xcode Command Line Tools if needed
- Prompts to install Homebrew if not present
- Installs packages and casks from `Brewfile`
- Configures macOS defaults

### Linux

Supports major Linux distributions:

- **Ubuntu/Debian**
- **Fedora/CentOS**
- **Arch/Manjaro**
- **openSUSE**
- **Alpine**

## What's Included

- **Shell Configuration**: Zsh with custom configuration and aliases
- **Terminal Emulators**: Alacritty and WezTerm configurations
- **Editors**: Vim, Neovim, and IdeaVim configurations
- **Development Tools**: Git configuration, tmux, mise (tool version manager)
- **CLI Tools**: bat, fzf, ripgrep, fd, htop, and many more
- **Fonts**: Nerd Fonts for better terminal experience (macOS)

## Testing with Docker

Test the dotfiles installation on different Linux distributions:

```shell
# Test on all distributions
docker compose up --build --menu=false # defaults to archlinux

# Test on specific distribution
docker compose up --build --menu=false ubuntu
docker compose up --build --menu=false fedora
docker compose up --build --menu=false opensuse

# Test _bootstrap script
docker compose up --build --menu=false bootstrap-test
```

### Interactive Testing

```shell
# Run interactive container for manual testing
docker compose run ubuntu /bin/bash
docker compose run fedora /bin/bash
docker compose run opensuse /bin/zsh
docker compose run archlinux /bin/zsh
```

## Backup and Recovery

The installation process automatically creates backups of existing dotfiles in:

```
~/.dotfiles_backup_YYYYMMDD_HHMMSS/
```

To restore from backup:

```shell
cp -r ~/.dotfiles_backup_YYYYMMDD_HHMMSS/* ~/
```

## Customization

- Edit `install.conf.yaml` to modify dotbot configuration
- Customize shell configuration in `home/.config/zsh/`
- Modify application configs in `home/.config/`

## Troubleshooting

### Prerequisites Issues

The bootstrap script handles most prerequisites automatically. If you encounter issues:

**macOS:**

- Ensure Xcode Command Line Tools are installed: `xcode-select --install`
- Manually install Homebrew if needed: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

**Linux:**

- Ensure your system is up to date
- Install git manually if the bootstrap fails: `sudo apt install git` (Ubuntu) or equivalent

### Permission Issues

If you encounter permission issues, ensure your user has sudo privileges or run the installation as a user with appropriate permissions.
****
