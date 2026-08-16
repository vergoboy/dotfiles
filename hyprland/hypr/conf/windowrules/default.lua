-- VLC: dark, semi-transparent interface with blur (blur is enabled globally),
-- fullscreen playback stays fully opaque so the video is not see-through.
hl.window_rule({
    name = "vlc-transparency",
    match = { class = "vlc" },
    opacity = "0.8 override 0.7 override 1.0 override"
})

-- Audio applet: floating Plasma-style panel, top-right under the status bar
hl.window_rule({
    name = "audio-applet",
    match = { class = "audio-applet" },
    float = true,
    pin = true,
    size = "400 640",
    move = "100%-408 52",
    rounding = 14,
    border_size = 1
})
