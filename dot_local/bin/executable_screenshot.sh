#!/bin/bash

TEMP=$(mktemp -u).png
/home/bamarler/.local/bin/grimblast save area "$TEMP"

if [ -f "$TEMP" ]; then
    wl-copy < "$TEMP"
    
    ACTION=$(notify-send "Screenshot captured" \
        "Copied to clipboard" \
        --action=save="Save" \
        --action=open="Open")
    
    if [ "$ACTION" = "save" ]; then
        mkdir -p ~/Pictures/Screenshots
        FILE=~/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png
        cp "$TEMP" "$FILE"
        notify-send "Screenshot saved" "$FILE"
    elif [ "$ACTION" = "open" ]; then
        xdg-open "$TEMP"
    fi
    
    rm -f "$TEMP"
fi
