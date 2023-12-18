import QtQuick                  2.11
import QtQuick.Controls         2.12
import QtQuick.Layouts          1.11

import QGroundControl                       1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.FactControls          1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

Button {
    id:             control
    hoverEnabled:   true
    topPadding:     _verticalPadding
    bottomPadding:  _verticalPadding
    leftPadding:    _horizontalPadding
    rightPadding:   _horizontalPadding
    focusPolicy:    Qt.ClickFocus

    property bool   primary:        false                               ///< primary button for a group of buttons
    property real   pointSize:      ScreenTools.defaultFontPointSize    ///< Point size for button text
    property bool   showBorder:     qgcPal.globalTheme === QGCPalette.Light
    property bool   iconLeft:       false
    property real   backRadius:     0
    property real   heightFactor:   0.5
    property string iconSource

    property bool   _showHighlight:     pressed | hovered | checked

    property int _horizontalPadding:    ScreenTools.defaultFontPixelWidth
    property int _verticalPadding:      Math.round(ScreenTools.defaultFontPixelHeight * heightFactor)
    
    property var activeVehicle 

    property bool _useShortListModes:   true
    property var _flightModesFixedWingShortList: [
        "Manual",
        "Stabilize",
        "FBW A",
        "FBW B",
        "Cruise",
        "Auto"
    ]

    property var _flightModesCopterShortList: [
        "Loiter",
        "Alt Hold",
        "Stabilize",
        "Auto"
    ]

    FactPanelController {
        id:     controller
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    background: Rectangle {
        id:             backRect
        implicitWidth:  ScreenTools.implicitButtonWidth
        implicitHeight: ScreenTools.implicitButtonHeight
        radius:         backRadius
        border {
            width:      showBorder ? 1 : 0
            color:      qgcPal.buttonText
        }
        color:          _showHighlight ?
                            qgcPal.buttonHighlight :
                            (primary ? qgcPal.primaryButton : qgcPal.button)
    }

    contentItem: Item {
        id:                     _item_root
        // Layout.preferredWidth:  rowLayout.width

        property real fontPointSize: ScreenTools.largeFontPointSize

        Component {
            id: flightModeMenu

            Rectangle {
                width: flickable.width + (ScreenTools.defaultFontPixelWidth * 2)
                height: flickable.height + (ScreenTools.defaultFontPixelWidth * 2)
                radius: ScreenTools.defaultFontPixelHeight * 0.5
                color: qgcPal.window
                border.color: qgcPal.text

                QGCFlickable {
                    id: flickable
                    anchors.margins: ScreenTools.defaultFontPixelWidth
                    anchors.top: parent.top
                    anchors.left: parent.left
                    width: mainLayout.width
                    height: _fullWindowHeight <= mainLayout.height ? _fullWindowHeight : mainLayout.height
                    flickableDirection: Flickable.VerticalFlick
                    contentHeight: mainLayout.height
                    contentWidth: mainLayout.width

                    property real _fullWindowHeight: mainWindow.contentItem.height - (indicatorPopup.padding * 2) - (ScreenTools.defaultFontPixelWidth * 2)

                    ColumnLayout {
                        id: mainLayout
                        spacing: ScreenTools.defaultFontPixelWidth / 2

                        Repeater {
                            model: activeVehicle ? 
                                (_useShortListModes ? ( controller.vehicle.fixedWing ? _flightModesFixedWingShortList : _flightModesCopterShortList) 
                                : activeVehicle.flightModes) : []

                            QGCButton {
                                text: modelData
                                Layout.fillWidth: true
                                onClicked: {
                                    activeVehicle.flightMode = text
                                    mainWindow.hideIndicatorPopup()
                                }
                            }
                        }
                    }
                }
            }
        }
       
        Text {
            id:                     text
            // anchors.centerIn:       parent
            anchors.bottom:             parent.bottom
            anchors.bottomMargin:       parent.bottomMargin
            anchors.horizontalCenter:   parent.horizontalCenter
            antialiasing:               true
            text:                       activeVehicle ? activeVehicle.flightMode : qsTr("N/A", "No data to display")
            font.pointSize:             pointSize
            font.family:                ScreenTools.normalFontFamily
            color:                      _showHighlight ?
                                            qgcPal.buttonHighlightText :
                                            (primary ? qgcPal.primaryButtonText : qgcPal.buttonText)
        }

        QGCColoredImage {
            id:                     icon
            source:                 "/qmlimages/FlightModesComponentIcon.png"
            height:                 source === "" ? 0 : text.height *2
            width:                  height
            color:                  text.color
            fillMode:               Image.PreserveAspectFit
            sourceSize.height:      height
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        QGCMouseArea {
            anchors.fill:   parent
            onClicked:      mainWindow.showIndicatorPopup(control, flightModeMenu)
        }
    }
}
