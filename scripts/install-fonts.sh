if [[ "$OSTYPE" == "darwin"* ]]; then
    FONT_DIR="$HOME/Library/Fonts"
else
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
fi

echo "Installing fonts to $FONT_DIR..."
for font in Iosevka IosevkaTerm IosevkaTermSlab JetBrainsMono; do
    echo "Downloading $font..."
    curl -fL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.tar.xz" | tar -xJ -C "$FONT_DIR"
done

echo "Installing p10k recommended fonts to $FONT_DIR"
for font in "MesloLGS NF Regular.ttf" "MesloLGS NF Bold.ttf" "MesloLGS NF Italic.ttf" "MesloLGS NF Bold Italic.ttf"; do
    echo "Downloading $font"

    URL="https://github.com/romkatv/powerlevel10k-media/raw/refs/heads/master/$font"
    ENCODED_FONT_NAME="${font// /%20}"

    curl -L "https://github.com/romkatv/powerlevel10k-media/raw/master/$ENCODED_FONT_NAME" --output "$FONT_DIR/$font"
done

if [[ "$OSTYPE" != "darwin"* ]]; then
    fc-cache -fv
fi

echo "Fonts installed successfully!"

