#!/bin/bash

tmux new-session -d -s pwndbg_panes 2>/dev/null || true
if [[ $1 != "--" ]]; then
    tmux send-keys -t pwndbg_panes "gdb $*" Enter
fi
tmux attach -t pwndbg_panes