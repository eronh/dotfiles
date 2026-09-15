function addcmd
    set -l file $HOME/.config/zsh/useful_commands.zsh

    if test (count $argv) -lt 2
        echo "Usage: addcmd <command> <description>"
        return 1
    end

    if grep -qF -- $argv[1] $file
        echo "Command already exists in $file"
        return 0
    end

    printf '# %s\n%s\n\n\n' $argv[2] $argv[1] >>$file
    echo "Command added to $file"
end
