/* Nordic Blur Theme for Rofi
 * Based on Nord color palette with blur/transparency
 * Colors: https://www.nordtheme.com
 */

* {
    /* Nord Palette */
    nord0:       #2E3440;
    nord1:       #3B4252;
    nord2:       #434C5E;
    nord3:       #4C566A;
    nord4:       #D8DEE9;
    nord5:       #E5E9F0;
    nord6:       #ECEFF4;
    nord7:       #8FBCBB;
    nord8:       #88C0D0;
    nord9:       #81A1C1;
    nord10:      #5E81AC;
    nord11:      #BF616A;
    nord12:      #D08770;
    nord13:      #EBCB8B;
    nord14:      #A3BE8C;
    nord15:      #B48EAD;

    /* Semantic */
    background:           #2E344080;
    background-alt:       #3B425280;
    foreground:           #D8DEE9;
    selected:             #88C0D0;
    selected-fg:          #2E3440;
    urgent:               #BF616A;
    active:               #A3BE8C;
    border-color:         #88C0D0;
    separator-color:      #4C566A;

    /* Reset */
    background-color:     transparent;
    text-color:           @foreground;
    border:               0;
    margin:               0;
    padding:              0;
    spacing:              0;
}

window {
    width:                480px;
    background-color:     @background;
    border:               2px solid;
    border-color:         @border-color;
    border-radius:        12px;
    padding:              12px;
}

mainbox {
    background-color:     transparent;
    children:             [ inputbar, message, mode-switcher, listview ];
    spacing:              8px;
}

/* ── Input Bar ── */
inputbar {
    background-color:     @background-alt;
    border-radius:        8px;
    padding:              10px 14px;
    spacing:              8px;
    children:             [ prompt, entry ];
}

prompt {
    text-color:           @selected;
    font:                 "JetBrainsMono Nerd Font Bold 12";
}

entry {
    text-color:           @foreground;
    placeholder:          "Search...";
    placeholder-color:    #4C566A;
    cursor:               text;
}

/* ── Mode Switcher ── */
mode-switcher {
    background-color:     transparent;
    spacing:              6px;
}

button {
    background-color:     @background-alt;
    text-color:           @foreground;
    border-radius:        6px;
    padding:              6px 10px;
}

button selected {
    background-color:     @selected;
    text-color:           @selected-fg;
}

/* ── List ── */
listview {
    background-color:     transparent;
    columns:              1;
    lines:                8;
    spacing:              4px;
    scrollbar:            false;
    border:               0;
}

element {
    background-color:     transparent;
    border-radius:        8px;
    padding:              8px 10px;
    spacing:              10px;
    children:             [ element-icon, element-text ];
}

element normal.normal,
element alternate.normal {
    background-color:     transparent;
    text-color:           @foreground;
}

element selected.normal {
    background-color:     @selected;
    text-color:           @selected-fg;
}

element normal.urgent,
element alternate.urgent {
    text-color:           @urgent;
}

element normal.active,
element alternate.active {
    text-color:           @active;
}

element selected.urgent {
    background-color:     @urgent;
    text-color:           @selected-fg;
}

element selected.active {
    background-color:     @active;
    text-color:           @selected-fg;
}

element-icon {
    size:                 24px;
    vertical-align:       0.5;
}

element-text {
    text-color:           inherit;
    vertical-align:       0.5;
    highlight:            bold;
}

/* ── Message ── */
message {
    background-color:     @background-alt;
    border-radius:        8px;
    padding:              8px 12px;
}

textbox {
    text-color:           @foreground;
}

/* ── Scrollbar ── */
scrollbar {
    background-color:     @background-alt;
    handle-color:         @selected;
    handle-width:         4px;
    border-radius:        4px;
    width:                4px;
}

window {
    blur-background: true;
}
