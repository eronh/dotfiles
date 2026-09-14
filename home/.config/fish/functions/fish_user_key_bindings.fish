function fish_user_key_bindings
    # Clear screen and scrollback
    bind \cl 'clear; printf "\e[3J"; commandline -f repaint'

    # Stop at - . : , / when deleting a word backwards, like zsh's WORDCHARS.
    # fish's default ctrl-w (backward-kill-path-component) treats - and . as
    # word characters; ctrl-backspace is already backward-kill-word.
    # bind ctrl-w backward-kill-path-component
    bind ctrl-w backward-kill-word

    # Swap fish's defaults: option+backspace deletes a word, option+shift+backspace
    # the whole argument. ctrl-alt-h is what some terminals send for alt-backspace.
    # bind alt-backspace backward-kill-token
    # bind ctrl-alt-h backward-kill-token
    bind alt-backspace backward-kill-word
    bind ctrl-alt-h backward-kill-word
    bind alt-shift-backspace backward-kill-token

    # `extract file.zip` -> `unzip file.zip` (see _extract_expand)
    # `ccompress src docs zip` -> `zip -r src.zip src docs` (see _compress_expand)
    bind space _extract_expand _compress_expand self-insert expand-abbr
    bind enter _extract_expand _compress_expand execute
end
