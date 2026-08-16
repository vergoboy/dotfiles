import Quickshell
import Quickshell.Networking
import QtQuick
import qs.CustomTheme

// Network status indicator, moved into the bar from the system tray (nm-applet).
// Shows wifi, ethernet or "no connection" depending on NetworkManager state and
// follows the statusbar theme like every other icon. Clicking opens the network
// connection editor. Reads through Quickshell's Networking service, which is
// backed by NetworkManager; no shell-out is needed.
BarButton {
    id: root

    // The currently connected device (wifi, ethernet, ...), or null when there
    // is no active connection.
    property var activeDevice: null

    readonly property bool connected: root.activeDevice !== null
    readonly property bool wired: root.connected && root.activeDevice.type === DeviceType.Wired

    readonly property string iconSource: {
        if (!root.connected)
            return "../shared/icons/wifi-off.svg"
        if (root.wired)
            return "../shared/icons/ethernet.svg"
        return "../shared/icons/wifi.svg"
    }

    iconSrc: root.iconSource
    colorize: true

    onClicked: Quickshell.execDetached(["nm-connection-editor"])

    // Re-pick the active device when the device list changes (device plugged
    // in/out, wifi radio on/off).
    Connections {
        target: Networking.devices
        function onValuesChanged(): void { root.refresh() }
    }

    // ...and hook each device's connect/disconnect signal once at startup so a
    // connection change without a device-list change is still caught. Duplicate
    // connects are ignored by Qt, so refresh() is safe to call repeatedly.
    Component.onCompleted: root.refresh()

    function refresh(): void {
        let devices = Networking.devices.values
        for (let i = 0; i < devices.length; i++)
            devices[i].connectedChanged.connect(root.refresh)

        let found = null
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].connected) {
                found = devices[i]
                break
            }
        }
        root.activeDevice = found
    }
}
