function cc --description "Attach to (or start) the persistent Claude Code tmux session"
    if set -q TMUX
        claude $argv
    else
        tmux new-session -A -s claude -c $HOME/Projects claude $argv
    end
end
