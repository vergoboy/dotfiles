#!/usr/bin/env bash
# rofi-music — کنترل موزیک
# پشتیبانی از: mpd/ncmpcpp, playerctl (spotify, elisa, ...)

get_player() {
    if command -v playerctl &>/dev/null; then
        playerctl -l 2>/dev/null | head -1
    fi
}

get_status() {
    local player="$1"
    if [[ -n "$player" ]]; then
        local title artist status
        title=$(playerctl -p "$player" metadata title 2>/dev/null)
        artist=$(playerctl -p "$player" metadata artist 2>/dev/null)
        status=$(playerctl -p "$player" status 2>/dev/null)
        echo "${status} — ${artist} - ${title}"
    else
        echo "No player running"
    fi
}

PLAYER=$(get_player)
STATUS=$(get_status "$PLAYER")

OPTIONS=(
    " Play/Pause"
    " Next"
    " Previous"
    "󰖁 Stop"
    "󰝝 Volume Up"
    "󰝞 Volume Down"
    "───────────"
    "󰋋 Now Playing: $STATUS"
)

selected=$(printf '%s\n' "${OPTIONS[@]}" | rofi -dmenu \
    -p " Music" \
    -theme "$HOME/.config/rofi/themes/nordic-blur.rasi" \
    -theme-str 'window {width: 500px;}' \
    -no-custom \
    -selected-row 0)

[[ -z "$selected" ]] && exit 0

case "$selected" in
    " Play/Pause")  playerctl -p "$PLAYER" play-pause ;;
    " Next")        playerctl -p "$PLAYER" next ;;
    " Previous")    playerctl -p "$PLAYER" previous ;;
    "󰖁 Stop")       playerctl -p "$PLAYER" stop ;;
    "󰝝 Volume Up")  pactl set-sink-volume @DEFAULT_SINK@ +5% ;;
    "󰝞 Volume Down") pactl set-sink-volume @DEFAULT_SINK@ -5% ;;
esac
