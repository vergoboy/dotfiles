import Quickshell
import QtQuick

// Arch Linux logo -> toggles the Sidebar app via IPC.
BarButton {
    iconSrc: "../shared/icons/archlinux.svg"
    colorize: true
    onClicked: {
        Quickshell.execDetached(["qs", "ipc", "call", "sidebar", "toggle"])
    }
}
