# Start/attach tmux.
# Let continuum's restore land before creating anything,
# otherwise the session we create races the restore and leaves a stray window.
function tt
    tmux start-server
    for i in (seq 10)
        tmux has-session 2>/dev/null; and break
        sleep 0.2
    end
    tmux attach 2>/dev/null; or tmux new-session -s H
end
