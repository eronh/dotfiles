# --- zinit ---
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
# Clone zinit on first run.
if [[ ! -d "$ZINIT_HOME/.git" ]]; then
    mkdir -p "${ZINIT_HOME:h}"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# zinit ice depth=1; zinit light romkatv/powerlevel10k

# --- interactive plugins ---
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8" # dim suggestion text
# ZSH_HIGHLIGHT_HIGHLIGHTERS=(builtin) # zsh-syntax-highlighting only; fast-syntax-highlighting ignores it
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-completions

# Disabled: compinit runs once in .zshrc, followed by `zinit cdreplay`.
# The annex itself is unused.
# zinit ice wait lucid atinit"zpcompinit; zpcdreplay"
# zinit light zdharma-continuum/zinit-annex-bin-gem-node

# --- oh-my-zsh snippets ---
zinit snippet OMZ::lib/compfix.zsh
zinit snippet OMZ::lib/git.zsh # helpers required by the git plugin
is_installed git && zinit snippet OMZ::plugins/git/git.plugin.zsh
is_installed docker && zinit snippet OMZ::plugins/docker/docker.plugin.zsh
is_installed podman && zinit snippet OMZ::plugins/podman/podman.plugin.zsh

zinit snippet OMZ::plugins/extract/extract.plugin.zsh
zinit snippet OMZ::plugins/kubectl/kubectl.plugin.zsh
# zinit snippet OMZ::plugins/globalias/globalias.plugin.zsh # expands glob expressions, subcommands and aliases
# my patched versions of globalias, to prevent expanding ~, l, ll, etc
zinit light-mode for "$HOME/.zsh/plugins/globalias"

# --- directory jumping (zsh-z) ---
# Settings must exist before the plugin loads. The `j` alias is in aliases.zsh.
ZSHZ_TILDE=1
ZSHZ_TRAILING_SLASH=1
ZSHZ_KEEP_DIRS=("$HOME/Desktop/" "$HOME/Documents/" "$HOME/Downloads/" "$HOME/Workbench/")
# ZSHZ_CMD='j' # the `j` alias covers it
zinit load agkozak/zsh-z
