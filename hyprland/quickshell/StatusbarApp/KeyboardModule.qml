import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.CustomTheme

// Keyboard layout + caps lock indicator. Shows the active keyboard layout as a
// short label (EN / FA) with a small accent dot when caps lock is engaged.
// The layout is updated instantly through the Hyprland socket (activelayout
// event); the caps lock state is polled, since Hyprland does not emit a socket
// event for modifier state changes. Clicking cycles to the next layout.
Rectangle {
    id: root

    // Current keyboard layout, e.g. "English (US)".
    property string layoutFull: ""
    // Short label shown in the bar, e.g. "EN" / "FA".
    property string layoutShort: "--"
    // Caps lock state of the main keyboard.
    property bool capsLock: false
    // Name of the main keyboard device (for layout cycling).
    property string deviceName: ""
    // Set by the keyboard navigation in StatusbarWindow.
    property bool focused: false
    signal clicked()

    // Run the module's action (mouse click or keyboard Return).
    function activate(): void { root.cycleLayout() }

    function cycleLayout(): void {
        if (root.deviceName !== "")
            Quickshell.execDetached(["hyprctl", "switchxkblayout", root.deviceName, "next"])
    }

    // Collapse a full layout name into a short label.
    function shorten(full): string {
        let name = full.toLowerCase()
        if (name.includes("persian") || name.includes("farsi") || name.includes("(ir"))
            return "FA"
        if (name.includes("english") || name.includes("(us"))
            return "EN"
        if (name.length >= 2)
            return name.substring(0, 2).toUpperCase()
        return full
    }

    // --- layout updates: instant via Hyprland socket ---
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name !== "activelayout")
                return
            // data format: "<monitor>,<layout>"
            let parts = event.data.split(",")
            root.layoutFull = parts.slice(1).join(",").trim()
            root.layoutShort = root.shorten(root.layoutFull)
        }
    }

    // --- caps lock + initial state: poll hyprctl ---
    Timer {
        id: pollTimer
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.poll()
    }

    function poll(): void {
        getDevices.running = true
    }

    Process {
        id: getDevices
        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector {
            id: devicesCollector
            onStreamFinished: {
                try {
                    let data = JSON.parse(devicesCollector.text)
                    for (let i = 0; i < data.keyboards.length; i++) {
                        let kb = data.keyboards[i]
                        if (kb.main !== true)
                            continue
                        root.capsLock = kb.capsLock === true
                        root.deviceName = kb.name
                        if (kb.active_keymap !== undefined && kb.active_keymap !== "") {
                            root.layoutFull = kb.active_keymap
                            root.layoutShort = root.shorten(root.layoutFull)
                        }
                        break
                    }
                } catch (e) {
                    // ignore transient parse errors
                }
            }
        }
    }

    Component.onCompleted: root.poll()

    readonly property bool active: mouseArea.containsMouse || root.focused

    implicitWidth: layout.implicitWidth + 18
    implicitHeight: 30
    radius: 15
    color: root.active ? Theme.primary : "transparent"

    Behavior on color {
        ColorAnimation { duration: 500; easing.type: Easing.OutQuint }
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 5

        Text {
            id: layoutText
            text: root.layoutShort
            color: root.capsLock ? Theme.error : Theme.primary
            font.family: Theme.fontFamily
            font.pixelSize: 13
            font.bold: true

            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }

        Rectangle {
            width: 6
            height: 6
            radius: 3
            color: Theme.error
            opacity: root.capsLock ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
