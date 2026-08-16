#!/usr/bin/env bash
# Show a short notification (1s) whenever the active keyboard layout changes.
#
# Listens on the Hyprland event socket for "activelayout" events. This fires
# regardless of how the layout was switched (xkb grp:alt_shift_toggle, waybar,
# or the statusbar keyboard module), so the user always gets feedback.

instance=$(hyprctl instances -j 2>/dev/null | jq -r '.[0].instance' 2>/dev/null)
runtime="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
socket="/$runtime/hypr/$instance/.socket2.sock"
if [ -z "$instance" ] || [ ! -S "$socket" ]; then
    exit 1
fi

# Human-friendly label for the notification.
layout_label() {
    local layout="$1"
    case "$layout" in
        *English*)  echo "English (US)" ;;
        *Persian*|*Farsi*) echo "Persian (FA)" ;;
        *French*)   echo "French (FR)" ;;
        *)          echo "$layout" ;;
    esac
}

notify_layout() {
    local layout="$1"
    local label
    label=$(layout_label "$layout")
    notify-send -a "Keyboard Layout" -u low -t 1000 -r 998877 -i input-keyboard "$label"
}

socat -u "UNIX-CONNECT:$socket" - 2>/dev/null | while IFS= read -r line; do
    case "$line" in
        activelayout*)
            notify_layout "${line##*>>}"
            ;;
    esac
done
