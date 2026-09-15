# Git abbreviations and functions ported from the OMZ git plugin:
# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh
# Where the plugin picks an alias by git version, the modern form is used.

# conf.d runs for scripts too; these abbreviations and helpers only matter at a prompt.
status is-interactive; or return

#
# Functions
# Kept here in one file rather than one-per-file in ../functions/, so they are
# defined at startup instead of autoloaded.
#

# From OMZ lib/git.zsh: branch name, or short hash on a detached HEAD
function git_current_branch
    set -l ref (command git symbolic-ref --quiet HEAD 2>/dev/null)
    set -l ret $status
    if test $ret -ne 0
        test $ret -eq 128; and return # no git repo
        set ref (command git rev-parse --short HEAD 2>/dev/null); or return
    end
    string replace -r '^refs/heads/' '' -- $ref
    return 0
end

# From OMZ git plugin: default branch from common names, else remote HEAD
function git_main_branch
    command git rev-parse --git-dir &>/dev/null; or return
    # Explicit loops, not zsh's refs/{heads,remotes/{origin,upstream}}/{main,...}:
    # fish expands nested braces in a different order, which would let
    # origin/trunk win over a local master.
    for prefix in refs/heads refs/remotes/origin refs/remotes/upstream
        for name in main trunk mainline default stable master
            if command git show-ref -q --verify $prefix/$name
                echo $name
                return 0
            end
        end
    end
    for remote in origin upstream
        set -l ref (command git rev-parse --abbrev-ref $remote/HEAD 2>/dev/null)
        if string match -q -- "$remote/*" "$ref"
            string replace -- "$remote/" '' $ref
            return 0
        end
    end
    # If no main branch was found, fall back to master but return error
    echo master
    return 1
end

# From OMZ git plugin: check for develop and similarly named branches
function git_develop_branch
    command git rev-parse --git-dir &>/dev/null; or return
    for branch in dev devel develop development
        if command git show-ref -q --verify refs/heads/$branch
            echo $branch
            return 0
        end
    end
    echo develop
    return 1
end

# From OMZ git plugin: git log with a named --pretty format (used by glp)
function _git_log_prettily -w 'git log'
    if test -n "$argv[1]"
        git log --pretty=$argv[1]
    end
end

# From OMZ git plugin: delete branches merged into HEAD, except main/develop
function gbda
    set -l main (git_main_branch)
    set -l dev (git_develop_branch)
    git branch --no-color --merged | command grep -vE "^([+*]|\s*($main|$dev)\s*\$)" | command xargs git branch --delete 2>/dev/null
end

# From OMZ git plugin: delete branches squash-merged into the default branch
function gbds
    set -l default_branch (git_main_branch); or set default_branch (git_develop_branch)
    for branch in (git for-each-ref refs/heads/ "--format=%(refname:short)")
        set -l merge_base (git merge-base $default_branch $branch)
        set -l cherry (git cherry $default_branch (git commit-tree (git rev-parse "$branch^{tree}") -p $merge_base -m _))
        if string match -q -- '-*' "$cherry[1]"
            git branch -D $branch
        end
    end
end

# From OMZ git plugin: clone with submodules, then cd into the new repo
function gccd -w 'git clone'
    command git clone --recurse-submodules $argv; or return
    # if the last arg is a directory, that's where the repo was cloned;
    # otherwise use the last part of the repo URI
    if test -d "$argv[-1]"
        cd $argv[-1]
    else
        set -l repo (string match -r -- '^(ssh://|git://|ftps?://|https?://|[^/]*@).*' $argv)[1]
        test -n "$repo"; or set repo $argv[1]
        cd (string replace -r '(\.git)?/*$' '' -- $repo | string replace -r '.*[/:]' '')
    end
end

# From OMZ git plugin: diff without lockfiles
function gdnolock -w 'git diff'
    git diff $argv ":(exclude)package-lock.json" ":(exclude)*.lock"
end

# From OMZ git plugin: whitespace-insensitive diff in a read-only vim
function gdv -w 'git diff'
    git diff -w $argv | view -
end

# From OMZ git plugin: git push --force origin, current branch unless exactly one is given
function ggf -w 'git push'
    set -l b
    test (count $argv) -ne 1; and set b (git_current_branch)
    test -n "$b"; or set b $argv[1]
    git push --force origin "$b"
end

# From OMZ git plugin: git push --force-with-lease origin, current branch unless exactly one is given
function ggfl -w 'git push'
    set -l b
    test (count $argv) -ne 1; and set b (git_current_branch)
    test -n "$b"; or set b $argv[1]
    git push --force-with-lease origin "$b"
end

# From OMZ git plugin: git pull origin, current branch when none is given
function ggl -w 'git pull'
    if test (count $argv) -gt 1
        git pull origin "$argv"
    else
        set -l b
        test (count $argv) -eq 0; and set b (git_current_branch)
        test -n "$b"; or set b $argv[1]
        git pull origin "$b"
    end
end

# From OMZ git plugin: git push origin, current branch when none is given
function ggp -w 'git push'
    if test (count $argv) -gt 1
        git push origin "$argv"
    else
        set -l b
        test (count $argv) -eq 0; and set b (git_current_branch)
        test -n "$b"; or set b $argv[1]
        git push origin "$b"
    end
end

# From OMZ git plugin: pull then push the current (or given) branch on origin
function ggpnp -w 'git checkout'
    if test (count $argv) -eq 0
        ggl; and ggp
    else
        ggl "$argv"; and ggp "$argv"
    end
end

# From OMZ git plugin: git pull --rebase origin, current branch unless exactly one is given
function ggu -w 'git pull'
    set -l b
    test (count $argv) -ne 1; and set b (git_current_branch)
    test -n "$b"; or set b $argv[1]
    git pull --rebase origin "$b"
end

# From OMZ git plugin: rename a branch locally and on origin
function grename
    if test -z "$argv[1]"; or test -z "$argv[2]"
        echo "Usage: grename old_branch new_branch"
        return 1
    end
    git branch -m $argv[1] $argv[2]
    if git push origin :$argv[1]
        git push --set-upstream origin $argv[2]
    end
end

# From OMZ git plugin: list tags matching a prefix, newest version first
function gtl
    git tag --sort=-v:refname -n --list "$argv[1]*"
end

# From OMZ git plugin: "unwip" all recent --wip-- commits, not just the last one
function gunwipall
    set -l _commit (git log --grep='--wip--' --invert-grep --max-count=1 --format=format:%H)
    if test "$_commit" != "$(git rev-parse HEAD)"
        git reset $_commit; or return 1
    end
end

# From OMZ git plugin: warn if the current branch is a WIP
function work_in_progress
    command git -c log.showSignature=false log -n 1 2>/dev/null | grep -q -- --wip--; and echo 'WIP!!'
end

#
# Abbreviations
#

# Abbreviations whose expansion has a command substitution are registered with
# __git_abbr_dynamic instead of `abbr -a`: the substitution runs when the
# abbreviation expands, so `gswm` becomes `git switch master` on the command
# line rather than `git switch (git_main_branch)`.
function __git_abbr_dynamic -a name template
    set -g __git_abbr_(string escape --style=var -- $name) $template
    abbr -a $name --function __git_abbr_resolve
end

# Called by abbr with the typed token; prints the template with each (…) or
# "$(…)" replaced by its escaped output.
function __git_abbr_resolve
    set -l var __git_abbr_(string escape --style=var -- $argv[1])
    set -l cmd $$var
    # -a with one capture group yields (whole match, inner command) pairs
    set -l parts (string match -ra -- '"?\$?\(([^()]*)\)"?' $cmd)
    for i in (seq 1 2 (count $parts))
        set -l out (eval $parts[(math $i + 1)] 2>/dev/null)
        # No output (e.g. not in a repo): keep the substitution as typed
        test (count $out) -gt 0; or continue
        set cmd (string replace -- $parts[$i] (string escape -- $out | string join ' ') $cmd)
    end
    printf '%s\n' $cmd
end

__git_abbr_dynamic grt 'cd "$(git rev-parse --show-toplevel; or echo .)"'
abbr -a ggpur ggu
abbr -a g git
abbr -a ga 'git add'
abbr -a gaa 'git add --all'
abbr -a gapa 'git add --patch'
abbr -a gau 'git add --update'
abbr -a gav 'git add --verbose'
__git_abbr_dynamic gwip 'git add -A; git rm (git ls-files --deleted) 2>/dev/null; git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"'
abbr -a gam 'git am'
abbr -a gama 'git am --abort'
abbr -a gamc 'git am --continue'
abbr -a gamscp 'git am --show-current-patch'
abbr -a gams 'git am --skip'
abbr -a gap 'git apply'
abbr -a gapt 'git apply --3way'
abbr -a gbs 'git bisect'
abbr -a gbsb 'git bisect bad'
abbr -a gbsg 'git bisect good'
abbr -a gbsn 'git bisect new'
abbr -a gbso 'git bisect old'
abbr -a gbsr 'git bisect reset'
abbr -a gbss 'git bisect start'
abbr -a gbl 'git blame -w'
abbr -a gb 'git branch'
abbr -a gba 'git branch --all'
abbr -a gbd 'git branch --delete'
abbr -a gbD 'git branch --delete --force'
abbr -a gbgd "LANG=C git branch --no-color -vv | grep ': gone\]' | cut -c 3- | awk '{print \$1}' | xargs git branch -d"
abbr -a gbgD "LANG=C git branch --no-color -vv | grep ': gone\]' | cut -c 3- | awk '{print \$1}' | xargs git branch -D"
abbr -a gbm 'git branch --move'
abbr -a gbnm 'git branch --no-merged'
abbr -a gbr 'git branch --remotes'
__git_abbr_dynamic ggsup 'git branch --set-upstream-to=origin/(git_current_branch)'
abbr -a gbg "LANG=C git branch -vv | grep ': gone\]'"
abbr -a gco 'git checkout'
abbr -a gcor 'git checkout --recurse-submodules'
abbr -a gcb 'git checkout -b'
abbr -a gcB 'git checkout -B'
__git_abbr_dynamic gcd 'git checkout (git_develop_branch)'
__git_abbr_dynamic gcm 'git checkout (git_main_branch)'
abbr -a gcp 'git cherry-pick'
abbr -a gcpa 'git cherry-pick --abort'
abbr -a gcpc 'git cherry-pick --continue'
abbr -a gclean 'git clean --interactive -d'
abbr -a gcl 'git clone --recurse-submodules'
abbr -a gclf 'git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules'
abbr -a gcam 'git commit --all --message'
abbr -a gcas 'git commit --all --signoff'
abbr -a gcasm 'git commit --all --signoff --message'
abbr -a gcs 'git commit --gpg-sign'
abbr -a gcss 'git commit --gpg-sign --signoff'
abbr -a gcssm 'git commit --gpg-sign --signoff --message'
abbr -a gcmsg 'git commit --message'
abbr -a gcsm 'git commit --signoff --message'
abbr -a gc 'git commit --verbose'
abbr -a gca 'git commit --verbose --all'
abbr -a gca! 'git commit --verbose --all --amend'
abbr -a gcan! 'git commit --verbose --all --no-edit --amend'
abbr -a gcans! 'git commit --verbose --all --signoff --no-edit --amend'
abbr -a gcann! 'git commit --verbose --all --date=now --no-edit --amend'
abbr -a gc! 'git commit --verbose --amend'
abbr -a gcn 'git commit --verbose --no-edit'
abbr -a gcn! 'git commit --verbose --no-edit --amend'
abbr -a gcf 'git config --list'
abbr -a gcfu 'git commit --fixup'
__git_abbr_dynamic gdct 'git describe --tags (git rev-list --tags --max-count=1)'
abbr -a gd 'git diff'
abbr -a gdca 'git diff --cached'
abbr -a gdcw 'git diff --cached --word-diff'
abbr -a gds 'git diff --staged'
abbr -a gdw 'git diff --word-diff'
abbr -a gdup 'git diff "@{upstream}"'
abbr -a gdt 'git diff-tree --no-commit-id --name-only -r'
abbr -a gf 'git fetch'
abbr -a gfa 'git fetch --all --tags --prune --jobs=10'
abbr -a gfo 'git fetch origin'
abbr -a gg 'git gui citool'
abbr -a gga 'git gui citool --amend'
abbr -a ghh 'git help'
abbr -a glgg 'git log --graph'
abbr -a glgga 'git log --graph --decorate --all'
abbr -a glgm 'git log --graph --max-count=10'
abbr -a glods 'git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset" --date=short'
abbr -a glod 'git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset"'
abbr -a glola 'git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'
abbr -a glols 'git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --stat'
abbr -a glol 'git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
abbr -a glo 'git log --oneline --decorate'
abbr -a glog 'git log --oneline --decorate --graph'
abbr -a gloga 'git log --oneline --decorate --graph --all'
abbr -a glp _git_log_prettily
abbr -a glg 'git log --stat'
abbr -a glgp 'git log --stat --patch'
abbr -a gignored 'git ls-files -v | grep "^[[:lower:]]"'
abbr -a gfg 'git ls-files | grep'
abbr -a gm 'git merge'
abbr -a gma 'git merge --abort'
abbr -a gmc 'git merge --continue'
abbr -a gms 'git merge --squash'
abbr -a gmff 'git merge --ff-only'
__git_abbr_dynamic gmom 'git merge origin/(git_main_branch)'
__git_abbr_dynamic gmum 'git merge upstream/(git_main_branch)'
abbr -a gmtl 'git mergetool --no-prompt'
abbr -a gmtlvim 'git mergetool --no-prompt --tool=vimdiff'
abbr -a gl 'git pull'
abbr -a gprv 'git pull --rebase -v'
abbr -a gpra 'git pull --rebase --autostash'
abbr -a gprav 'git pull --rebase --autostash -v'
__git_abbr_dynamic gprom 'git pull --rebase origin (git_main_branch)'
__git_abbr_dynamic gpromi 'git pull --rebase=interactive origin (git_main_branch)'
__git_abbr_dynamic gprum 'git pull --rebase upstream (git_main_branch)'
__git_abbr_dynamic gprumi 'git pull --rebase=interactive upstream (git_main_branch)'
__git_abbr_dynamic ggpull 'git pull origin "$(git_current_branch)"'
__git_abbr_dynamic gluc 'git pull upstream (git_current_branch)'
__git_abbr_dynamic glum 'git pull upstream (git_main_branch)'
abbr -a gp 'git push'
abbr -a gpd 'git push --dry-run'
abbr -a gpf! 'git push --force'
abbr -a gpf 'git push --force-with-lease --force-if-includes'
__git_abbr_dynamic gpsup 'git push --set-upstream origin (git_current_branch)'
__git_abbr_dynamic gpsupf 'git push --set-upstream origin (git_current_branch) --force-with-lease --force-if-includes'
abbr -a gpv 'git push --verbose'
abbr -a gpoat 'git push origin --all && git push origin --tags'
abbr -a gpod 'git push origin --delete'
__git_abbr_dynamic ggpush 'git push origin "$(git_current_branch)"'
abbr -a gpu 'git push upstream'
abbr -a grb 'git rebase'
abbr -a grba 'git rebase --abort'
abbr -a grbc 'git rebase --continue'
abbr -a grbi 'git rebase --interactive'
abbr -a grbo 'git rebase --onto'
abbr -a grbs 'git rebase --skip'
__git_abbr_dynamic grbd 'git rebase (git_develop_branch)'
__git_abbr_dynamic grbm 'git rebase (git_main_branch)'
__git_abbr_dynamic grbom 'git rebase origin/(git_main_branch)'
__git_abbr_dynamic grbum 'git rebase upstream/(git_main_branch)'
abbr -a grf 'git reflog'
abbr -a gr 'git remote'
abbr -a grv 'git remote --verbose'
abbr -a gra 'git remote add'
abbr -a grrm 'git remote remove'
abbr -a grmv 'git remote rename'
abbr -a grset 'git remote set-url'
abbr -a grup 'git remote update'
abbr -a grh 'git reset'
abbr -a gru 'git reset --'
abbr -a grhh 'git reset --hard'
abbr -a grhk 'git reset --keep'
abbr -a grhs 'git reset --soft'
abbr -a gpristine 'git reset --hard && git clean --force -dfx'
abbr -a gwipe 'git reset --hard && git clean --force -df'
__git_abbr_dynamic groh 'git reset origin/(git_current_branch) --hard'
abbr -a grs 'git restore'
abbr -a grss 'git restore --source'
abbr -a grst 'git restore --staged'
abbr -a gunwip 'git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && git reset HEAD~1'
abbr -a grev 'git revert'
abbr -a greva 'git revert --abort'
abbr -a grevc 'git revert --continue'
abbr -a grm 'git rm'
abbr -a grmc 'git rm --cached'
abbr -a gcount 'git shortlog --summary --numbered'
abbr -a gsh 'git show'
abbr -a gsps 'git show --pretty=short --show-signature'
abbr -a gstall 'git stash --all'
abbr -a gstaa 'git stash apply'
abbr -a gstc 'git stash clear'
abbr -a gstd 'git stash drop'
abbr -a gstl 'git stash list'
abbr -a gstp 'git stash pop'
abbr -a gsta 'git stash push'
abbr -a gsts 'git stash show --patch'
abbr -a gst 'git status'
abbr -a gss 'git status --short'
abbr -a gsb 'git status --short --branch'
abbr -a gsi 'git submodule init'
abbr -a gsu 'git submodule update'
abbr -a gsd 'git svn dcommit'
__git_abbr_dynamic git-svn-dcommit-push 'git svn dcommit && git push github (git_main_branch):svntrunk'
abbr -a gsr 'git svn rebase'
abbr -a gsw 'git switch'
abbr -a gswc 'git switch --create'
__git_abbr_dynamic gswd 'git switch (git_develop_branch)'
__git_abbr_dynamic gswm 'git switch (git_main_branch)'
abbr -a gta 'git tag --annotate'
abbr -a gts 'git tag --sign'
abbr -a gtv 'git tag | sort -V'
abbr -a gignore 'git update-index --assume-unchanged'
abbr -a gunignore 'git update-index --no-assume-unchanged'
abbr -a gwch 'git log --patch --abbrev-commit --pretty=medium --raw'
abbr -a gwtmv 'git worktree move'
# The plugin's `gsta --include-untracked`; spelled out because abbrs don't chain
abbr -a gstu 'git stash push --include-untracked'
abbr -a gk 'command gitk --all --branches & disown'
__git_abbr_dynamic gke 'command gitk --all (git log --walk-reflogs --pretty=%h) & disown'

# Custom abbreviations, not from the plugin (moved here from abbrs.fish)
abbr -a g- 'git switch -'
abbr -a gs 'git sync'
abbr -a glr 'git pull --rebase'
# Disabled: a usage note, not a command; fish reads `<new>` as a redirection.
# abbr -a grbo 'git rebase --onto <new> <old> <current-branch>'
abbr -a gw 'git worktree'
abbr -a gwa 'git worktree add'
abbr -a gwls 'git worktree list'
abbr -a gwrm 'git worktree remove'
