function reload-tmux
    if set -q TMUX
        for pane in (tmux list-panes -a -F "#{pane_id} #{pane_current_command}" | awk '$2=="fish" {print $1}')
            tmux send-keys -t $pane "exec fish" C-m
        end
        echo "Done! Restarted fish in all active panes."
    else
        exec fish
    end
end
