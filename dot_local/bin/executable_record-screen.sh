#!/bin/bash

if pgrep -x wf-recorder > /dev/null; then
    pkill -INT wf-recorder
    sleep 1
    
    LATEST=$(ls -t ~/Videos/recording-*.mp4 2>/dev/null | head -n1)
    if [ -n "$LATEST" ]; then
        ACTION=$(notify-send "Recording saved" \
            "$(basename "$LATEST")" \
            --action=open="Open Video" \
            --action=folder="Show Folder")
        
        if [ "$ACTION" = "open" ]; then
            xdg-open "$LATEST"
        elif [ "$ACTION" = "folder" ]; then
            xdg-open ~/Videos
        fi
    fi
else
    mkdir -p ~/Videos
    GEOMETRY=$(slurp)
    if [ -n "$GEOMETRY" ]; then
        FILE=~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4
        notify-send "Recording started" "Press SHIFT+Print to stop"
        wf-recorder -g "$GEOMETRY" -f "$FILE"
    fi
fi
