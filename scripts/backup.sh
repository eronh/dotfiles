#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/utils.sh" ]; then
    source "${SCRIPT_DIR}/utils.sh"
else
    echo "[ERROR] utils.sh not found"
    exit 1
fi

create_backup() {
    local backup_dir="$1"
    if [ -z "$backup_dir" ]; then
        log_error "No backup directory specified"
        return 1
    fi

    log_info "Creating backup of existing dotfiles..."

    local files_to_backup=(
        ".bashrc"
        ".bash_aliases"
        ".zshrc"
        ".zsh"
        ".zshenv"
        ".config/zsh"
        ".vimrc"
        ".ideavimrc"
        ".gitconfig"
        ".tmux.conf"
        ".config/alacritty"
        ".config/wezterm"
        ".config/nvim"
        ".config/mise"
    )

    local backup_created=false

    for file in "${files_to_backup[@]}"; do
        if [ -e "$HOME/$file" ]; then
            if [ "$backup_created" = false ]; then
                mkdir -p "$backup_dir"
                backup_created=true
            fi

            # Create parent directory in backup if needed
            local parent_dir=$(dirname "$backup_dir/$file")
            mkdir -p "$parent_dir"

            cp -r "$HOME/$file" "$backup_dir/$file" 2> /dev/null || true
            log_info "Backed up $file"
        fi
    done

    if [ "$backup_created" = true ]; then
        log_success "Backup created at $backup_dir"
    else
        log_info "No existing dotfiles found to backup"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    BACKUP_DIR="${1:-$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)}"
    create_backup "$BACKUP_DIR"
fi
