if [[ "$OSTYPE" == "darwin"* ]]; then
    FONT_DIR="$HOME/Library/Fonts"
else
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
fi

echo "Installing fonts to $FONT_DIR..."
for font in Iosevka IosevkaTerm IosevkaTermSlab JetBrainsMono; do
    if compgen -G "$FONT_DIR/${font}NerdFont*" > /dev/null; then
        echo "$font already installed, skipping"
        continue
    fi
    echo "Downloading $font..."
    curl -fL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.tar.xz" | tar -xJ -C "$FONT_DIR"
done

if [[ "$OSTYPE" != "darwin"* ]]; then
    fc-cache -fv
fi

echo "Fonts installed successfully!"
