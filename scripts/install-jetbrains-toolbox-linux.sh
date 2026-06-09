#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/opt/jetbrains-toolbox"
DESKTOP_FILE="/usr/share/applications/jetbrains-toolbox.desktop"
ARCHIVE="jetbrains-toolbox.tar.gz"
DOWNLOAD_URL="https://data.services.jetbrains.com/products/download?platform=linux&code=TBA"

# Create a temporary working directory.
# mktemp -d creates a unique directory and prints its path.
TMP_DIR="$(mktemp -d)"

# Always remove the temporary directory when the script exits,
# whether it succeeds or fails.
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Downloading latest JetBrains Toolbox..."

# -f: fail on HTTP errors, such as 404 or 500.
# -L: follow redirects. JetBrains' download URL redirects to the real archive.
# -o: write output to the given file.
curl -fL "$DOWNLOAD_URL" -o "$TMP_DIR/$ARCHIVE"

echo "Removing old installation, if present..."
sudo rm -rf "$INSTALL_DIR"

echo "Installing JetBrains Toolbox to $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR"

# -x: extract files from the archive.
# -z: decompress gzip.
# -f: read from the archive file that follows.
# -C: extract into the given directory.
# --strip-components=1:
#   Remove the first path component from every file in the archive.
#   JetBrains archives usually contain a top-level directory like:
#     jetbrains-toolbox-3.5.0.84344/
#   This makes its contents land directly in:
#     /opt/jetbrains-toolbox/
#   instead of:
#     /opt/jetbrains-toolbox/jetbrains-toolbox-3.5.0.84344/
sudo tar -xzf "$TMP_DIR/$ARCHIVE" \
  -C "$INSTALL_DIR" \
  --strip-components=1

# Make installed files readable by all users and directories traversable.
#
# a+rX means:
#   a  = all users: owner, group, others
#   +  = add permission
#   r  = read permission
#   X  = execute/search permission only for directories
#        and files that already have any execute bit set
#
# This is safer than a+rx because it avoids making every regular file executable.
# Directories need execute/search permission so users can access files inside them.
sudo chmod -R a+rX "$INSTALL_DIR"

TOOLBOX_BIN="$INSTALL_DIR/bin/jetbrains-toolbox"

if [[ ! -x "$TOOLBOX_BIN" ]]; then
  echo "Installation failed: $TOOLBOX_BIN was not found or is not executable." >&2
  exit 1
fi

echo "Creating CLI symlink..."

# Create or replace a symlink in /usr/local/bin so users can run:
#   jetbrains-toolbox
# from the terminal without typing the full /opt path.
#
# -s: create a symbolic link instead of a hard link.
# -f: replace the destination if it already exists.
sudo ln -sf "$TOOLBOX_BIN" /usr/local/bin/jetbrains-toolbox

echo "Creating desktop entry..."

# Try to find an icon shipped inside the Toolbox installation.
# The escaped parentheses group the name checks for find.
# -iname is case-insensitive name matching.
# head -n 1 picks the first matching icon, because one icon is plenty.
ICON_PATH="$(
  find "$INSTALL_DIR" \
    -type f \
    \( -iname '*toolbox*.svg' -o -iname '*toolbox*.png' -o -iname '*jetbrains*.svg' -o -iname '*jetbrains*.png' \) \
    | head -n 1
)"

DESKTOP_TMP="$TMP_DIR/jetbrains-toolbox.desktop"

cat > "$DESKTOP_TMP" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=JetBrains Toolbox
Comment=Manage JetBrains IDEs and tools
Exec=$TOOLBOX_BIN
Terminal=false
Categories=Development;IDE;
StartupWMClass=jetbrains-toolbox
EOF

if [[ -n "$ICON_PATH" ]]; then
  echo "Icon=$ICON_PATH" >> "$DESKTOP_TMP"
fi

# Install the desktop entry as a system-wide application launcher.
#
# install is used instead of cp because it can create parent directories
# and set file permissions in one command.
#
# -D:
#   Create any missing parent directories for the destination path.
#
# -m 644:
#   Set file permissions to rw-r--r--.
#   Owner can read/write; everyone else can read.
#   Desktop files should not need to be executable.
sudo install -Dm644 "$DESKTOP_TMP" "$DESKTOP_FILE"

# Validate the .desktop file if desktop-file-validate is installed.
# This catches common mistakes in desktop entry syntax.
if command -v desktop-file-validate >/dev/null 2>&1; then
  desktop-file-validate "$DESKTOP_TMP"
fi

# Refresh the desktop application database if the command exists.
# Some desktop environments notice new launchers automatically;
# others appreciate the tiny ceremonial database poke.
#
# The command is allowed to fail because not every distro has or needs it.
if command -v update-desktop-database >/dev/null 2>&1; then
  sudo update-desktop-database /usr/share/applications || true
fi

echo "Installed JetBrains Toolbox."

echo "Binary:"
echo "  $TOOLBOX_BIN"
echo "CLI command:"
echo "  jetbrains-toolbox"
echo "Desktop entry:"
echo "  $DESKTOP_FILE"
