# Rewrite `extract <archive>` on the command line into the real command,
# based on oh-my-zsh's extract plugin. Bound to space/enter in
# fish_user_key_bindings (abbr functions can't replace the whole line).
# Every command refuses to overwrite existing files: tar -k, unzip -n,
# 7z -aos, unrar -o-; gunzip/bunzip2/unxz prompt on a tty, so those get a
# `test -e` guard on the output file instead.
function _extract_expand
    set -l file (string match -rg '^\s*extract\s+(.+?)\s*$' -- (commandline -b)); or return
    set -l cmd
    set -l out
    switch $file
        case '*.tar.gz' '*.tgz'
            set cmd "tar -xzkvf $file"
        case '*.tar.bz2' '*.tbz' '*.tbz2'
            set cmd "tar -xjkvf $file"
        case '*.tar.xz' '*.txz'
            set cmd "tar -xJkvf $file"
        case '*.tar.zst' '*.tzst'
            set cmd "tar --zstd -xkvf $file"
        case '*.tar'
            set cmd "tar -xkvf $file"
        case '*.gz'
            set cmd "gunzip -k $file"
            set out (string replace -r '\.gz$' '' -- $file)
        case '*.bz2'
            set cmd "bunzip2 -k $file"
            set out (string replace -r '\.bz2$' '' -- $file)
        case '*.xz'
            set cmd "unxz -k $file"
            set out (string replace -r '\.xz$' '' -- $file)
        case '*.zip' '*.jar'
            set cmd "unzip -n $file"
        case '*.7z'
            set cmd "7z x -aos $file"
        case '*.rar'
            set cmd "unrar x -o- $file"
        case '*'
            return
    end
    if set -q out[1]
        set cmd "if test -e $out; echo \"$out already exists\" >&2; false; else; $cmd; end"
    end
    commandline -r $cmd
end
