# Rewrite `ccompress <files...> <format>` on the command line into the real
# command; the archive is named after the first file. Named `ccompress` because
# a line left unexpanded as `compress` would run /usr/bin/compress. Bound to
# space/enter in fish_user_key_bindings, alongside _extract_expand.
function _compress_expand
    set -l m (string match -rg '^\s*ccompress\s+(.+?)\s+(\S+)\s*$' -- (commandline -b)); or return
    set -l files $m[1]
    set -l tokens (commandline -x)
    set -l archive (string escape -- (path basename (string trim -r -c / -- $tokens[2]))).$m[2]
    set -l cmd
    switch $m[2]
        case tar.gz tgz
            set cmd "tar -czvf $archive $files"
        case tar.bz2 tbz2
            set cmd "tar -cjvf $archive $files"
        case tar.xz txz
            set cmd "tar -cJvf $archive $files"
        case tar.zst tzst
            set cmd "tar --zstd -cvf $archive $files"
        case tar
            set cmd "tar -cvf $archive $files"
        case zip
            set cmd "zip -r $archive $files"
        case 7z
            set cmd "7z a $archive $files"
        case rar
            set cmd "rar a $archive $files"
        case '*'
            return
    end
    # Checked when the command runs (not at expansion) so re-running it from
    # history is guarded too. tar would overwrite; zip/7z/rar would add to it.
    commandline -r "if test -e $archive; echo \"$archive already exists\" >&2; false; else; $cmd; end"
end
