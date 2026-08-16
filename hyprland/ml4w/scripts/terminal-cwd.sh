#!/usr/bin/env bash
# Open a terminal in the working directory of the focused window

pid=$(hyprctl activewindow -j 2>/dev/null | jq -r '.pid' 2>/dev/null)
dir=""
if [ -n "$pid" ] && [ "$pid" != "null" ]; then
    dir=$(readlink "/proc/$pid/cwd" 2>/dev/null)
fi
if [ ! -d "$dir" ]; then
    dir="$HOME"
fi
kitty --directory "$dir"
