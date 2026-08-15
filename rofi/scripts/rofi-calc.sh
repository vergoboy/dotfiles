#!/usr/bin/env bash
# rofi-calc — محاسبه و تبدیل واحد
# Dependencies: python3, units (gnu-units), xdotool یا wl-clipboard

SESSION="${XDG_SESSION_TYPE:-x11}"

copy_result() {
    if [[ "$SESSION" == "wayland" ]]; then
        echo -n "$1" | wl-copy
    else
        echo -n "$1" | xclip -selection clipboard
    fi
    notify-send "rofi-calc" "Copied: $1"
}

calculate() {
    local expr="$1"

    # تبدیل واحد با gnu-units
    if echo "$expr" | grep -qiE ' (in|to) '; then
        if command -v units &>/dev/null; then
            local from to
            from=$(echo "$expr" | sed 's/ \(in\|to\) .*//')
            to=$(echo "$expr"   | sed 's/.* \(in\|to\) //')
            result=$(units -t "$from" "$to" 2>/dev/null)
            [[ -n "$result" ]] && echo "$result" && return
        fi
    fi

    # محاسبه ریاضی با python
    python3 -c "
import math
try:
    result = eval('$expr', {'__builtins__': {}}, vars(math))
    print(result)
except Exception as e:
    print(f'Error: {e}')
" 2>/dev/null
}

PROMPT=" Calc"
INPUT=$(echo "" | rofi -dmenu \
    -p "$PROMPT" \
    -theme "$HOME/.config/rofi/themes/nordic-blur.rasi" \
    -theme-str 'window {width: 480px;} listview {lines: 0;}' \
    -mesg "Examples: 2+2 | sqrt(144) | 100km in miles | 1kg in lb")

[[ -z "$INPUT" ]] && exit 0

RESULT=$(calculate "$INPUT")

if [[ -n "$RESULT" ]]; then
    CONFIRM=$(echo "$RESULT" | rofi -dmenu \
        -p " Result" \
        -theme "$HOME/.config/rofi/themes/nordic-blur.rasi" \
        -theme-str 'window {width: 480px;} listview {lines: 1;}' \
        -mesg "Enter to copy | Esc to exit")
    [[ -n "$CONFIRM" ]] && copy_result "$RESULT"
fi
