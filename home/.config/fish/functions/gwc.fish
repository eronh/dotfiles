function gwc
    if not set -q argv[1]
        echo "Usage: gwc <worktree-name> [branch]"
        return 1
    end

    set -l wt_name $argv[1]
    set -l branch $wt_name
    set -q argv[2]; and set branch $argv[2]

    set -l repo_root (git rev-parse --show-toplevel); or return 1
    set -l project_name (basename $repo_root)
    set -l wt_dir $repo_root/$project_name-$wt_name

    if test -d $wt_dir
        echo "Worktree already exists: $wt_dir"
        return 1
    end

    git worktree add -b $branch $wt_dir; or return 1

    echo "Created worktree: $project_name-$wt_name"
    echo "Remove with: git worktree remove $project_name-$wt_name"
end
