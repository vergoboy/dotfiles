#!/usr/bin/env bash
# Toggle the AI scratchpad: special workspace "ai" running opencode in kitty

windows=$(hyprctl workspaces -j 2>/dev/null | jq -r '.[] | select(.name == "special:ai") | .windows' 2>/dev/null)
hyprctl dispatch togglespecialworkspace ai
if [ -z "$windows" ] || [ "$windows" = "0" ]; then
    sleep 0.5
    kitty --class ai-scratchpad opencode >/dev/null 2>&1 &
fi
