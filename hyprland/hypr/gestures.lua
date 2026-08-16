-------------------------------------------------------
-- Gestures
-------------------------------------------------------

-- Workspaces (3-finger swipe left/right or up/down to switch workspace)
hl.gesture({
    fingers = 3,
    direction = "vertical",
    action = "workspace"
})
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Fullscreen on  
hl.gesture({ fingers = 4, direction = "pinchout", action = function ()
    hl.dispatch(hl.dsp.window.fullscreen({ action="set" })) 
end})

-- Fullscreen off  
hl.gesture({ fingers = 4, direction = "pinchin", action = function ()
    hl.dispatch(hl.dsp.window.fullscreen({ action="unset" })) 
end})