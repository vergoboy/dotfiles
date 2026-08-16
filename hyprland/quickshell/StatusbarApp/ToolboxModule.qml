import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects
import qs.CustomTheme

// Windows-style "toolbox": the chevron button hides the background app icons
// (system tray hosts like Hiddify, Throne, Telegram...) and opens a popup
// drawer below the bar where they live. The button disappears entirely while
// no tray items exist, exactly like the Windows hidden-icons caret.
//
// The drawer reuses SystemTrayModule, so every tray icon keeps its normal
// left-click action and right-click context menu.
Rectangle {
    id: root

    // True while the system tray has no items. StatusbarWindow's right-area
    // Loader watches this and hides the toolbox button (reusing the same
    // mechanism the plain SystemTrayModule used).
    readonly property bool collapsed: trayContent.collapsed

    // Whether the drawer popup is open.
    property bool menuOpen: false
    // Set by the keyboard navigation in StatusbarWindow.
    property bool focused: false

    // True while any tray context menu is open. The bar pins itself expanded
    // while this is set (see SystemTrayModule for the reasoning).
    readonly property bool trayMenuOpen: trayContent.menuOpen

    // Mouse click / keyboard Return: toggle the drawer.
    function activate(): void {
        root.menuOpen = !root.menuOpen
    }

    readonly property bool active: mouseArea.containsMouse || root.focused || root.menuOpen

    implicitWidth: 30
    implicitHeight: 30
    radius: 15

    // Same accent-filled circle as BarButton on hover/selection/open.
    color: active ? Theme.primary : "transparent"
    Behavior on color {
        ColorAnimation { duration: 500; easing.type: Easing.OutQuint }
    }

    Image {
        anchors.centerIn: parent
        source: "../shared/icons/toolbox.svg"
        width: 18
        height: 18
        sourceSize.width: 18
        sourceSize.height: 18
        fillMode: Image.PreserveAspectFit
        layer.enabled: true
        layer.effect: MultiEffect {
            colorization: 1.0
            colorizationColor: root.active ? Theme.background : Theme.primary
            Behavior on colorizationColor {
                ColorAnimation { duration: 500; easing.type: Easing.OutQuint }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activate()
    }

    // ==========================================
    // TOOLBOX DRAWER
    // ==========================================
    // Anchored just below the button. grabFocus lets a click outside dismiss
    // the drawer. It lives inside the module so its anchor item survives the
    // bar collapsing while the tray icons are in use.
    PopupWindow {
        id: popup
        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.margins.top: 10
        // Center the drawer under the button.
        anchor.rect.x: root.width / 2 - popup.width / 2

        visible: root.menuOpen

        // Grab input while open so a click anywhere outside the drawer
        // dismisses it — the same primitive the status bar itself uses.
        HyprlandFocusGrab {
            windows: [popup]
            active: root.menuOpen
            onCleared: root.menuOpen = false
        }

        implicitWidth: 260
        implicitHeight: trayContent.implicitHeight + 16
        color: "transparent"

        // Take keyboard focus while open so Escape closes the drawer.
        FocusScope {
            id: keyScope
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: root.menuOpen = false
        }

        onVisibleChanged: {
            if (visible)
                keyScope.forceActiveFocus()
        }

        // Card background, matching the sidebar's context menus.
        Rectangle {
            anchors.fill: parent
            radius: 8
            color: Theme.background
            border.color: Theme.primary
            border.width: 1
        }

        // The tray items, centered in the drawer. SystemTrayModule sizes to
        // its contents, so the drawer hugs whatever icons are present.
        SystemTrayModule {
            id: trayContent
            anchors.centerIn: parent
        }
    }
}
