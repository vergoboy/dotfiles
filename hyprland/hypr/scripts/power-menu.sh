#!/usr/bin/env bash
# -----------------------------------------------------
# Power menu with single-key shortcuts:
#   u = Shutdown, r = Reboot, s = Suspend, l = Lock, q = Logout
# Press the letter then Enter, or arrow keys to select.
# -----------------------------------------------------

choice=$(printf '%s\n' \
    "u  Shutdown" \
    "r  Reboot" \
    "s  Suspend" \
    "l  Lock" \
    "q  Logout" |
    rofi -dmenu -i -p " Power " -theme "$HOME/.config/rofi/config.rasi")

power="$HOME/.config/ml4w/scripts/ml4w-power"

case "$choice" in
    *Shutdown) "$power" -p ;;
    *Reboot)   "$power" -r ;;
    *Suspend)  "$power" -s ;;
    *Lock)     "$power" -l ;;
    *Logout)   "$power" -e ;;
esac
