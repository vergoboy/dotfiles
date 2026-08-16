#!/usr/bin/env bash
# Toggle the Plasma-style audio applet open/closed.
set -euo pipefail

APP="$HOME/.config/hypr/scripts/audio-applet"

if pgrep -f "audio-applet$" >/dev/null 2>&1; then
    pkill -f "audio-applet$" || true
else
    nohup "$APP" >/dev/null 2>&1 &
fi
