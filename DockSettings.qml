import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// BetterDock Settings Dialog: Authentic, clean Omarchy design with full Russian/English localization
Item {
  id: root

  property var dock: null
  readonly property bool isOpened: !!dock && dock.settingsOpened
  readonly property string lang: (dock && dock.dockLanguage) ? dock.dockLanguage : "ru"
  readonly property bool isRu: lang === "ru"

  property string currentTab: "appearance"

  function close() {
    if (root.dock) {
      root.dock.closeSettings()
      if (typeof root.dock.saveSettings === "function") {
        root.dock.saveSettings()
      }
    }
  }

  function setLanguage(newLang) {
    if (root.dock) {
      root.dock.dockLanguage = newLang
      root.dock.saveSettings()
    }
  }

  OverlayWindow {
    id: dialogOverlay
    shown: root.isOpened
    WlrLayershell.namespace: "omarchy-dock-settings"

    onShownChanged: {
      if (shown) {
        Qt.callLater(function() { keyCatcher.forceActiveFocus() })
      }
    }

    // Completely transparent scrim: keeps the real desktop and real dock visible beneath
    Rectangle {
      anchors.fill: parent
      color: Qt.rgba(0, 0, 0, 0.25)
    }

    // Click outside dialog to dismiss
    MouseArea {
      anchors.fill: parent
      onClicked: root.close()
    }

    Item {
      id: keyCatcher
      anchors.fill: parent
      focus: true
      Keys.onEscapePressed: root.close()
    }

    // Main Settings Card
    Rectangle {
      id: card
      width: Math.min(parent.width - Style.space(32), Style.space(480))
      implicitHeight: contentCol.implicitHeight + Style.space(36)
      height: implicitHeight

      anchors.centerIn: parent

      radius: Style.cornerRadius > 0 ? Style.cornerRadius : 12
      color: Commons.Color.menu.background
      border.width: 1
      border.color: Commons.Color.menu.border
      clip: true

      // Catch clicks inside card so it doesn't dismiss
      MouseArea {
        anchors.fill: parent
        onClicked: function(mouse) { mouse.accepted = true }
      }

      // Drop shadow
      Rectangle {
        anchors.fill: parent
        anchors.topMargin: Style.space(6)
        radius: card.radius
        color: Qt.rgba(0, 0, 0, 0.45)
        z: -1
      }

      Column {
        id: contentCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Style.space(18)
        spacing: Style.space(14)

        // ==========================================
        // 1. Header: Title, Subtitle, Language Pill & Close
        // ==========================================
        Row {
          width: parent.width

          Column {
            width: parent.width - headerActions.width
            spacing: Style.space(2)

            Text {
              text: root.isRu ? "Настройки BetterDock" : "BetterDock Settings"
              color: Commons.Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.title
              font.bold: true
            }

            Text {
              text: root.isRu ? "Внешний вид, расположение и эффекты" : "Appearance, layout & behavior preferences"
              color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.5)
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
            }
          }

          Row {
            id: headerActions
            spacing: Style.space(8)
            anchors.verticalCenter: parent.verticalCenter

            // Language Switcher Pill [ RU | EN ]
            Rectangle {
              width: Style.space(74)
              height: Style.space(26)
              radius: height / 2
              color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.07)
              border.width: 1
              border.color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.12)
              anchors.verticalCenter: parent.verticalCenter

              Row {
                anchors.fill: parent

                // RU Button
                Rectangle {
                  width: parent.width / 2
                  height: parent.height
                  radius: height / 2
                  color: root.isRu ? Commons.Color.accent : "transparent"

                  Text {
                    anchors.centerIn: parent
                    text: "RU"
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    font.bold: true
                    color: root.isRu ? Commons.Color.menu.background : Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.6)
                  }

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.setLanguage("ru")
                  }
                }

                // EN Button
                Rectangle {
                  width: parent.width / 2
                  height: parent.height
                  radius: height / 2
                  color: !root.isRu ? Commons.Color.accent : "transparent"

                  Text {
                    anchors.centerIn: parent
                    text: "EN"
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    font.bold: true
                    color: !root.isRu ? Commons.Color.menu.background : Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.6)
                  }

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.setLanguage("en")
                  }
                }
              }
            }

            // Close Button
            Rectangle {
              width: Style.space(26)
              height: Style.space(26)
              radius: height / 2
              color: closeMouse.containsMouse ? Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.12) : "transparent"
              border.width: 1
              border.color: closeMouse.containsMouse ? Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.25) : "transparent"
              anchors.verticalCenter: parent.verticalCenter

              Text {
                anchors.centerIn: parent
                text: "✕"
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                color: closeMouse.containsMouse ? Commons.Color.foreground : Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.6)
              }

              MouseArea {
                id: closeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.close()
              }
            }
          }
        }

        // ==========================================
        // 2. Tab Navigation (Segmented Minimal Pill Bar)
        // ==========================================
        Rectangle {
          width: parent.width
          height: Style.space(34)
          radius: Style.cornerRadius > 0 ? Math.min(Style.cornerRadius, 8) : 6
          color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.05)
          border.width: 1
          border.color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.08)

          Row {
            anchors.fill: parent
            spacing: 0

            TabButton {
              tabId: "appearance"
              title: root.isRu ? "Внешний вид" : "Appearance"
              width: parent.width / 3
            }

            TabButton {
              tabId: "layout"
              title: root.isRu ? "Расположение" : "Layout"
              width: parent.width / 3
            }

            TabButton {
              tabId: "behavior"
              title: root.isRu ? "Поведение" : "Behavior"
              width: parent.width / 3
            }
          }
        }

        // ==========================================
        // 3. Tab Content Card
        // ==========================================
        Rectangle {
          id: tabContainer
          width: parent.width
          implicitHeight: activeContent.implicitHeight + Style.space(20)
          radius: Style.cornerRadius > 0 ? Style.cornerRadius : 8
          color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.025)
          border.width: 1
          border.color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.08)

          Item {
            id: activeContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Style.space(12)
            implicitHeight: appearanceView.visible ? appearanceView.implicitHeight
              : (layoutView.visible ? layoutView.implicitHeight : behaviorView.implicitHeight)

            // ----------------------------------------
            // TAB 1: APPEARANCE
            // ----------------------------------------
            Column {
              id: appearanceView
              visible: root.currentTab === "appearance"
              anchors.left: parent.left
              anchors.right: parent.right
              spacing: Style.space(12)

              // Setting 1: Background Opacity
              Column {
                width: parent.width
                spacing: Style.space(5)

                Row {
                  width: parent.width
                  Column {
                    width: parent.width - opacityBadge.width
                    Text {
                      text: root.isRu ? "Прозрачность фона" : "Background Opacity"
                      font.family: Style.font.family
                      font.pixelSize: Style.font.bodySmall
                      font.bold: true
                      color: Commons.Color.foreground
                    }
                    Text {
                      text: root.isRu ? "Степень матовости стеклянной подложки" : "Translucency level of the dock glass capsule"
                      font.family: Style.font.family
                      font.pixelSize: Style.font.caption
                      color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.5)
                    }
                  }
                  ValueBadge {
                    id: opacityBadge
                    text: root.dock ? Math.round(root.dock.dockOpacity * 100) + "%" : "72%"
                  }
                }

                SettingsSlider {
                  minimum: 0.0
                  maximum: 1.0
                  step: 0.01
                  value: root.dock ? root.dock.dockOpacity : 0.72
                  onMoved: function(val) {
                    if (root.dock) {
                      root.dock.dockOpacity = Math.round(val * 100) / 100
                      root.dock.saveSettings()
                    }
                  }
                }

                Row {
                  spacing: Style.space(6)
                  PresetChip {
                    label: root.isRu ? "0% Прозрачный" : "0% Clear"
                    active: root.dock && root.dock.dockOpacity < 0.05
                    onClicked: { if (root.dock) { root.dock.dockOpacity = 0.0; root.dock.saveSettings() } }
                  }
                  PresetChip {
                    label: root.isRu ? "50% Стекло" : "50% Glass"
                    active: root.dock && Math.abs(root.dock.dockOpacity - 0.50) < 0.05
                    onClicked: { if (root.dock) { root.dock.dockOpacity = 0.50; root.dock.saveSettings() } }
                  }
                  PresetChip {
                    label: root.isRu ? "72% Стандарт" : "72% Default"
                    active: root.dock && Math.abs(root.dock.dockOpacity - 0.72) < 0.05
                    onClicked: { if (root.dock) { root.dock.dockOpacity = 0.72; root.dock.saveSettings() } }
                  }
                  PresetChip {
                    label: root.isRu ? "100% Плотный" : "100% Solid"
                    active: root.dock && root.dock.dockOpacity > 0.95
                    onClicked: { if (root.dock) { root.dock.dockOpacity = 1.0; root.dock.saveSettings() } }
                  }
                }
              }

              SettingDivider {}

              // Setting 2: Icon Size & Dock Height
              Column {
                width: parent.width
                spacing: Style.space(5)

                Row {
                  width: parent.width
                  Column {
                    width: parent.width - sizeBadge.width
                    Text {
                      text: root.isRu ? "Размер значков и высота" : "Icon Size & Height"
                      font.family: Style.font.family
                      font.pixelSize: Style.font.bodySmall
                      font.bold: true
                      color: Commons.Color.foreground
                    }
                    Text {
                      text: root.isRu ? "Масштаб иконок и вертикальная высота панели" : "Scale of app icons and total panel thickness"
                      font.family: Style.font.family
                      font.pixelSize: Style.font.caption
                      color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.5)
                    }
                  }
                  ValueBadge {
                    id: sizeBadge
                    text: root.dock ? root.dock.dockIconSize + " px" : "36 px"
                  }
                }

                SettingsSlider {
                  minimum: 24
                  maximum: 56
                  step: 1
                  integer: true
                  value: root.dock ? root.dock.dockIconSize : 36
                  onMoved: function(val) {
                    if (root.dock) {
                      root.dock.dockIconSize = Math.round(val)
                      root.dock.saveSettings()
                    }
                  }
                }

                Row {
                  spacing: Style.space(6)
                  PresetChip {
                    label: root.isRu ? "28px Малый" : "28px Small"
                    active: root.dock && root.dock.dockIconSize === 28
                    onClicked: { if (root.dock) { root.dock.dockIconSize = 28; root.dock.saveSettings() } }
                  }
                  PresetChip {
                    label: root.isRu ? "36px Стандарт" : "36px Default"
                    active: root.dock && root.dock.dockIconSize === 36
                    onClicked: { if (root.dock) { root.dock.dockIconSize = 36; root.dock.saveSettings() } }
                  }
                  PresetChip {
                    label: root.isRu ? "44px Средний" : "44px Medium"
                    active: root.dock && root.dock.dockIconSize === 44
                    onClicked: { if (root.dock) { root.dock.dockIconSize = 44; root.dock.saveSettings() } }
                  }
                  PresetChip {
                    label: root.isRu ? "52px Большой" : "52px Large"
                    active: root.dock && root.dock.dockIconSize === 52
                    onClicked: { if (root.dock) { root.dock.dockIconSize = 52; root.dock.saveSettings() } }
                  }
                }
              }

              SettingDivider {}

              // Setting 3: Corner Radius
              Column {
                width: parent.width
                spacing: Style.space(5)

                Row {
                  width: parent.width
                  Column {
                    width: parent.width - radiusBadge.width
                    Text {
                      text: root.isRu ? "Скругление углов" : "Corner Radius"
                      font.family: Style.font.family
                      font.pixelSize: Style.font.bodySmall
                      font.bold: true
                      color: Commons.Color.foreground
                    }
                    Text {
                      text: root.isRu ? "Радиус закругления краёв панели дока" : "Curvature radius of dock corners"
                      font.family: Style.font.family
                      font.pixelSize: Style.font.caption
                      color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.5)
                    }
                  }
                  ValueBadge {
                    id: radiusBadge
                    text: root.dock ? root.dock.dockCornerRadius + " px" : "12 px"
                  }
                }

                SettingsSlider {
                  minimum: 0
                  maximum: 32
                  step: 1
                  integer: true
                  value: root.dock ? root.dock.dockCornerRadius : 12
                  onMoved: function(val) {
                    if (root.dock) {
                      root.dock.dockCornerRadius = Math.round(val)
                      root.dock.saveSettings()
                    }
                  }
                }

                Row {
                  spacing: Style.space(6)
                  PresetChip {
                    label: root.isRu ? "0px Прямые" : "0px Sharp"
                    active: root.dock && root.dock.dockCornerRadius === 0
                    onClicked: { if (root.dock) { root.dock.dockCornerRadius = 0; root.dock.saveSettings() } }
                  }
                  PresetChip {
                    label: root.isRu ? "8px Мягкие" : "8px Subtle"
                    active: root.dock && root.dock.dockCornerRadius === 8
                    onClicked: { if (root.dock) { root.dock.dockCornerRadius = 8; root.dock.saveSettings() } }
                  }
                  PresetChip {
                    label: root.isRu ? "12px Стандарт" : "12px Default"
                    active: root.dock && root.dock.dockCornerRadius === 12
                    onClicked: { if (root.dock) { root.dock.dockCornerRadius = 12; root.dock.saveSettings() } }
                  }
                  PresetChip {
                    label: root.isRu ? "24px Круглые" : "24px Round"
                    active: root.dock && root.dock.dockCornerRadius === 24
                    onClicked: { if (root.dock) { root.dock.dockCornerRadius = 24; root.dock.saveSettings() } }
                  }
                }
              }
            }

            // ----------------------------------------
            // TAB 2: LAYOUT & STYLE
            // ----------------------------------------
            Column {
              id: layoutView
              visible: root.currentTab === "layout"
              anchors.left: parent.left
              anchors.right: parent.right
              spacing: Style.space(12)

              // Setting 1: Full-Width Bar Mode
              Row {
                width: parent.width
                Column {
                  width: parent.width - fullWidthToggle.width
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: Style.space(2)

                  Text {
                    text: root.isRu ? "Режим на всю ширину" : "Full-Width Panel"
                    font.family: Style.font.family
                    font.pixelSize: Style.font.bodySmall
                    font.bold: true
                    color: Commons.Color.foreground
                  }
                  Text {
                    text: root.isRu ? "Растягивать док от края до края как системную панель" : "Extend the dock edge-to-edge as a system bar"
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.5)
                  }
                }

                CustomToggle {
                  id: fullWidthToggle
                  checked: root.dock ? root.dock.fullWidth : false
                  anchors.verticalCenter: parent.verticalCenter
                  onToggled: {
                    if (root.dock) {
                      root.dock.fullWidth = !root.dock.fullWidth
                      root.dock.saveSettings()
                    }
                  }
                }
              }

              SettingDivider {}

              // Setting 2: Floating Island Style
              Row {
                width: parent.width
                opacity: (root.dock && root.dock.fullWidth) ? 1.0 : 0.4
                enabled: root.dock && root.dock.fullWidth

                Column {
                  width: parent.width - floatingToggle.width
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: Style.space(2)

                  Text {
                    text: root.isRu ? "Плавающий остров" : "Floating Island Style"
                    font.family: Style.font.family
                    font.pixelSize: Style.font.bodySmall
                    font.bold: true
                    color: Commons.Color.foreground
                  }
                  Text {
                    text: root.isRu ? "Полнорежимная панель парит с отступами и скруглениями" : "Full-width bar floats with screen margins and rounded corners"
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.5)
                  }
                }

                CustomToggle {
                  id: floatingToggle
                  checked: root.dock ? root.dock.floatingPanel : false
                  anchors.verticalCenter: parent.verticalCenter
                  onToggled: {
                    if (root.dock && root.dock.fullWidth) {
                      root.dock.floatingPanel = !root.dock.floatingPanel
                      root.dock.saveSettings()
                    }
                  }
                }
              }

              SettingDivider {}

              // Setting 3: Icon Alignment
              Row {
                width: parent.width

                Column {
                  width: parent.width - alignSelector.width
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: Style.space(2)

                  Text {
                    text: root.isRu ? "Положение значков" : "Icon Alignment"
                    font.family: Style.font.family
                    font.pixelSize: Style.font.bodySmall
                    font.bold: true
                    color: Commons.Color.foreground
                  }
                  Text {
                    text: root.isRu ? "Выравнивание приложений внутри панели дока" : "Positioning of pinned apps along the dock"
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.5)
                  }
                }

                // Alignment Selector Pill
                Rectangle {
                  id: alignSelector
                  width: Style.space(160)
                  height: Style.space(28)
                  radius: Style.cornerRadius > 0 ? Math.min(Style.cornerRadius, 6) : 4
                  color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.08)
                  border.width: 1
                  border.color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.12)
                  anchors.verticalCenter: parent.verticalCenter

                  Row {
                    anchors.fill: parent

                    // Center
                    Rectangle {
                      width: parent.width / 2
                      height: parent.height
                      radius: parent.radius
                      color: (!root.dock || root.dock.dockAlignment !== "left") ? Commons.Color.accent : "transparent"

                      Text {
                        anchors.centerIn: parent
                        text: root.isRu ? "По центру" : "Center"
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                        font.bold: !root.dock || root.dock.dockAlignment !== "left"
                        color: (!root.dock || root.dock.dockAlignment !== "left") ? Commons.Color.menu.background : Commons.Color.foreground
                      }

                      MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                          if (root.dock) {
                            root.dock.dockAlignment = "center"
                            root.dock.saveSettings()
                          }
                        }
                      }
                    }

                    // Left
                    Rectangle {
                      width: parent.width / 2
                      height: parent.height
                      radius: parent.radius
                      color: (root.dock && root.dock.dockAlignment === "left") ? Commons.Color.accent : "transparent"

                      Text {
                        anchors.centerIn: parent
                        text: root.isRu ? "Слева" : "Left"
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                        font.bold: root.dock && root.dock.dockAlignment === "left"
                        color: (root.dock && root.dock.dockAlignment === "left") ? Commons.Color.menu.background : Commons.Color.foreground
                      }

                      MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                          if (root.dock) {
                            root.dock.dockAlignment = "left"
                            root.dock.saveSettings()
                          }
                        }
                      }
                    }
                  }
                }
              }
            }

            // ----------------------------------------
            // TAB 3: BEHAVIOR
            // ----------------------------------------
            Column {
              id: behaviorView
              visible: root.currentTab === "behavior"
              anchors.left: parent.left
              anchors.right: parent.right
              spacing: Style.space(12)

              // Setting 1: Hover Animation
              Row {
                width: parent.width
                Column {
                  width: parent.width - hoverToggle.width
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: Style.space(2)

                  Text {
                    text: root.isRu ? "Увеличение при наведении" : "Hover Magnification"
                    font.family: Style.font.family
                    font.pixelSize: Style.font.bodySmall
                    font.bold: true
                    color: Commons.Color.foreground
                  }
                  Text {
                    text: root.isRu ? "Плавное масштабирование иконки под курсором мыши" : "Magnify application icons when hovered"
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.5)
                  }
                }

                CustomToggle {
                  id: hoverToggle
                  checked: root.dock ? root.dock.hoverAnimation : true
                  anchors.verticalCenter: parent.verticalCenter
                  onToggled: {
                    if (root.dock) {
                      root.dock.hoverAnimation = !root.dock.hoverAnimation
                      root.dock.saveSettings()
                    }
                  }
                }
              }

              SettingDivider {}

              // Setting 2: Hide on Maximized Window
              Row {
                width: parent.width
                Column {
                  width: parent.width - maxToggle.width
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: Style.space(2)

                  Text {
                    text: root.isRu ? "Скрывать при максимизации" : "Hide on Maximized"
                    font.family: Style.font.family
                    font.pixelSize: Style.font.bodySmall
                    font.bold: true
                    color: Commons.Color.foreground
                  }
                  Text {
                    text: root.isRu ? "Автоматически прятать панель при развёрнутом окне" : "Hide dock automatically when a window is maximized"
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.5)
                  }
                }

                CustomToggle {
                  id: maxToggle
                  checked: root.dock ? root.dock.hideOnMaximized : true
                  anchors.verticalCenter: parent.verticalCenter
                  onToggled: {
                    if (root.dock) {
                      root.dock.hideOnMaximized = !root.dock.hideOnMaximized
                      root.dock.saveSettings()
                    }
                  }
                }
              }

              SettingDivider {}

              // Setting 3: All Workspaces
              Row {
                width: parent.width
                Column {
                  width: parent.width - wsToggle.width
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: Style.space(2)

                  Text {
                    text: root.isRu ? "Все рабочие столы" : "All Workspaces"
                    font.family: Style.font.family
                    font.pixelSize: Style.font.bodySmall
                    font.bold: true
                    color: Commons.Color.foreground
                  }
                  Text {
                    text: root.isRu ? "Отображать панель на тайловых и плавающих воркспейсах" : "Show dock across both tiling and floating workspaces"
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.5)
                  }
                }

                CustomToggle {
                  id: wsToggle
                  checked: root.dock ? root.dock.allWorkspaces : false
                  anchors.verticalCenter: parent.verticalCenter
                  onToggled: {
                    if (root.dock) {
                      root.dock.allWorkspaces = !root.dock.allWorkspaces
                      root.dock.saveSettings()
                    }
                  }
                }
              }
            }
          }
        }

        // ==========================================
        // 4. Footer: Reset & Done Buttons
        // ==========================================
        Row {
          width: parent.width

          // Reset to Defaults
          Rectangle {
            id: resetBtn
            implicitWidth: resetText.implicitWidth + Style.space(20)
            height: Style.space(32)
            radius: Style.cornerRadius > 0 ? Math.min(Style.cornerRadius, 6) : 4
            color: resetMouse.containsMouse ? Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.08) : "transparent"
            border.width: 1
            border.color: resetMouse.containsMouse ? Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.25) : Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.12)

            Text {
              id: resetText
              anchors.centerIn: parent
              text: root.isRu ? "По умолчанию" : "Reset Defaults"
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              color: resetMouse.containsMouse ? Commons.Color.foreground : Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.7)
            }

            MouseArea {
              id: resetMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (root.dock && typeof root.dock.resetSettings === "function") {
                  root.dock.resetSettings()
                }
              }
            }
          }

          Item { width: parent.width - resetBtn.width - doneBtn.width; height: 1 }

          // Done Button
          Rectangle {
            id: doneBtn
            implicitWidth: doneText.implicitWidth + Style.space(28)
            height: Style.space(32)
            radius: Style.cornerRadius > 0 ? Math.min(Style.cornerRadius, 6) : 4
            color: doneMouse.containsMouse ? Qt.lighter(Commons.Color.accent, 1.1) : Commons.Color.accent

            Text {
              id: doneText
              anchors.centerIn: parent
              text: root.isRu ? "Готово" : "Done"
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              font.bold: true
              color: Commons.Color.menu.background
            }

            MouseArea {
              id: doneMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.close()
            }
          }
        }
      }
    }
  }

  // ==========================================
  // Reusable Omarchy-Styled Inline Components
  // ==========================================

  // Tab Button
  component TabButton: Rectangle {
    id: tabBtn
    property string tabId: ""
    property string title: ""
    readonly property bool active: root.currentTab === tabId

    height: parent.height
    radius: Style.cornerRadius > 0 ? Math.min(Style.cornerRadius, 8) : 6
    color: active
      ? Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.18)
      : (tMouse.containsMouse ? Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.05) : "transparent")
    border.width: active ? 1 : 0
    border.color: Commons.Color.accent

    Behavior on color { ColorAnimation { duration: 100 } }

    Text {
      anchors.centerIn: parent
      text: tabBtn.title
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      font.bold: tabBtn.active
      color: tabBtn.active ? Commons.Color.accent : (tMouse.containsMouse ? Commons.Color.foreground : Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.65))
    }

    MouseArea {
      id: tMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.currentTab = tabBtn.tabId
    }
  }

  // Value Readout Badge Pill
  component ValueBadge: Rectangle {
    id: vBadge
    property alias text: badgeLabel.text

    implicitWidth: badgeLabel.implicitWidth + Style.space(14)
    height: Style.space(20)
    radius: Style.cornerRadius > 0 ? Math.min(Style.cornerRadius, 6) : 4
    color: Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.14)
    border.width: 1
    border.color: Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.35)

    Text {
      id: badgeLabel
      anchors.centerIn: parent
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      font.bold: true
      color: Commons.Color.accent
    }
  }

  // Preset Quick Chip
  component PresetChip: Rectangle {
    id: chip
    property string label: ""
    property bool active: false
    signal clicked()

    implicitWidth: chipLabel.implicitWidth + Style.space(12)
    height: Style.space(22)
    radius: Style.cornerRadius > 0 ? Math.min(Style.cornerRadius, 5) : 3
    color: active
      ? Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.18)
      : (chipMouse.containsMouse ? Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.08) : "transparent")
    border.width: 1
    border.color: active
      ? Commons.Color.accent
      : (chipMouse.containsMouse ? Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.25) : Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.12))

    Behavior on color { ColorAnimation { duration: 100 } }
    Behavior on border.color { ColorAnimation { duration: 100 } }

    Text {
      id: chipLabel
      anchors.centerIn: parent
      text: chip.label
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      font.bold: chip.active
      color: chip.active ? Commons.Color.accent : Commons.Color.foreground
    }

    MouseArea {
      id: chipMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: chip.clicked()
    }
  }

  // Smooth Slider
  component SettingsSlider: Item {
    id: sld
    property real value: 0
    property real minimum: 0
    property real maximum: 1
    property real step: 0.01
    property bool integer: false
    signal moved(real val)

    implicitWidth: parent ? parent.width : Style.space(200)
    implicitHeight: Style.space(18)

    readonly property real range: Math.max(0.0001, maximum - minimum)
    readonly property real progress: Math.max(0, Math.min(1, (value - minimum) / range))

    Rectangle {
      id: sldTrack
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.leftMargin: Style.space(6)
      anchors.rightMargin: Style.space(6)
      height: Style.space(4)
      radius: height / 2
      color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.15)

      Rectangle {
        height: parent.height
        width: parent.width * sld.progress
        radius: parent.radius
        color: Commons.Color.accent
      }
    }

    Rectangle {
      id: sldKnob
      width: Style.space(14)
      height: Style.space(14)
      radius: width / 2
      anchors.verticalCenter: parent.verticalCenter
      x: sldTrack.x + sldTrack.width * sld.progress - width / 2
      color: Commons.Color.accent
      border.width: 2
      border.color: Commons.Color.menu.background
      scale: sldMouse.containsMouse || sldMouse.pressed ? 1.25 : 1.0

      Behavior on scale { NumberAnimation { duration: 100 } }
    }

    MouseArea {
      id: sldMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor

      function update(mouseX) {
        if (sldTrack.width <= 0) return
        var frac = Math.max(0, Math.min(1, (mouseX - sldTrack.x) / sldTrack.width))
        var next = sld.minimum + frac * sld.range
        if (sld.integer) {
          next = Math.round(next)
        } else if (sld.step > 0) {
          next = Math.round(next / sld.step) * sld.step
        }
        next = Math.max(sld.minimum, Math.min(sld.maximum, next))
        sld.moved(next)
      }

      onPressed: function(mouse) { update(mouse.x) }
      onPositionChanged: function(mouse) { if (pressed) update(mouse.x) }
      onWheel: function(wheel) {
        var d = wheel.angleDelta.y > 0 ? (sld.integer ? 1 : sld.step) : (sld.integer ? -1 : -sld.step)
        var next = Math.max(sld.minimum, Math.min(sld.maximum, sld.value + d))
        if (sld.integer) next = Math.round(next)
        sld.moved(next)
      }
    }
  }

  // Custom Animated Toggle Switch
  component CustomToggle: Rectangle {
    id: tgl
    property bool checked: false
    signal toggled()

    width: Style.space(38)
    height: Style.space(22)
    radius: height / 2
    color: checked ? Commons.Color.accent : Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.16)
    border.width: 1
    border.color: checked ? Commons.Color.accent : Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.22)

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    Rectangle {
      width: Style.space(16)
      height: Style.space(16)
      radius: width / 2
      anchors.verticalCenter: parent.verticalCenter
      x: tgl.checked ? parent.width - width - Style.space(3) : Style.space(3)
      color: tgl.checked ? Commons.Color.menu.background : Commons.Color.foreground
      scale: tglMouse.containsMouse ? 1.08 : 1.0

      Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
      Behavior on scale { NumberAnimation { duration: 100 } }
    }

    MouseArea {
      id: tglMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: tgl.toggled()
    }
  }

  // 1px Subtle Section Divider
  component SettingDivider: Rectangle {
    width: parent ? parent.width : 100
    height: 1
    color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.08)
  }
}
