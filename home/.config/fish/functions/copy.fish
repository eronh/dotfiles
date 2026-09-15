function copy
    if test (uname -s) = Darwin
        set cmd pbcopy
    else if test "$XDG_SESSION_TYPE" = wayland
        set cmd wl-copy -n
    else
        set cmd xclip -selection clipboard
    end

    if set -q argv[1]
        $argv | $cmd
    else
        $cmd
    end
end
