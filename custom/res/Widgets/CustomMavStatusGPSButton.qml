import QtQuick              2.11
import QtQuick.Controls     2.12
import QtQuick.Layouts      1.11

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0
import QGroundControl.FactSystem            1.0

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
    property string iconSource      // use this flag to include image source directory 

    property string statusNormal:   "Normal"
    property string statusError:    "Error"
    property string statusDisabled: "Disabled"

    property string statusActivity          // use this flag to change the indicator's status
    property bool   onMouseHighlight:       pressed | hovered | checked
    property bool   showOnMouseHighlight

    property int _horizontalPadding:    ScreenTools.defaultFontPixelWidth
    property int _verticalPadding:      Math.round(ScreenTools.defaultFontPixelHeight * heightFactor)

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property var    _vehicleInAir:      _activeVehicle ? _activeVehicle.flying || _activeVehicle.landing : false
    property bool   _vtolInFWDFlight:   _activeVehicle ? _activeVehicle.vtolInFwdFlight : false
    property bool   _armed:             _activeVehicle ? _activeVehicle.armed : false
    property real   _margins:           ScreenTools.defaultFontPixelWidth
    property real   _spacing:           ScreenTools.defaultFontPixelWidth / 2
    property bool   _healthAndArmingChecksSupported: _activeVehicle ? _activeVehicle.healthAndArmingCheckReport.supported : false

    property var activeVehicle 

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
        color:          qgcPal.button
        states: [
            State{
                name: "on_mouse"; when: onMouseHighlight && showOnMouseHighlight
                PropertyChanges {
                    target: backRect; 
                    color:  onMouseHighlight ? 
                        qgcPal.buttonHighlight : (primary ? qgcPal.primaryButton : qgcPal.button)
                }
            },
            State {
                name: "Normal"; when: statusActivity == statusNormal
                PropertyChanges {target: backRect; color: "green"}//qgcPal.buttonHighlight}
            },
            State {
                name: "Error"; when: statusActivity == statusError
                PropertyChanges {target: backRect; color: "red"}
            },
            State {
                name: "Disabled"; when: statusActivity == statusDisabled
                PropertyChanges {target: backRect; color: qgcPal.button}
            }
        ]
    }

    Component {
        id: sensorMavStatusGPSComponent

        Rectangle {
            //copied from GPSIndicator.qml
            id:                         gps_info_window
            width:                      gpsCol.width   + ScreenTools.defaultFontPixelWidth  * 3
            height:                     gpsCol.height  + ScreenTools.defaultFontPixelHeight * 2
            // width:                      flightControlRectangle.width
            // height:                     width * 0.35//gpsCol.height  + ScreenTools.defaultFontPixelHeight * 2
            radius:                     ScreenTools.defaultFontPixelHeight * 0.5
            color:                      qgcPal.window
            border.color:               qgcPal.text
            visible:                    true

            Column {
                id:                 gpsCol
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                // width:              parent.width // Math.max(gpsGrid.width, gpsLabel.width)
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.centerIn:   parent

                QGCLabel {
                    id:                         gpsLabel
                    text:                       (_activeVehicle && _activeVehicle.gps.count.value >= 0) ? qsTr("GPS Status") : qsTr("GPS Data Unavailable")
                    font.family:                ScreenTools.demiboldFontFamily
                    anchors.horizontalCenter:   parent.horizontalCenter
                }

                GridLayout {
                    id:                         gpsGrid
                    visible:                    (_activeVehicle && _activeVehicle.gps.count.value >= 0)
                    // anchors.margins:            ScreenTools.defaultFontPixelHeight
                    columnSpacing:              ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    columns: 3

                    QGCLabel { text: qsTr("GPS Count:") }
                    QGCLabel { text: _activeVehicle ? _activeVehicle.gps.count.valueString : qsTr("N/A", "No data to display") }
                    Rectangle {
                        id:     gps_count_state_rect
                        width:  height //ScreenTools.defaultFontPixelWidth
                        height: ScreenTools.defaultFontPixelHeight
                        color:  "green" // qgcPal.window
                        states: [
                            State {
                                name: "Disabled"; when: !_activeVehicle
                                PropertyChanges {target: gps_count_state_rect; color: "red"}//color: qgcPal.button}
                            },
                            State {
                                name: "Error"; when: _activeVehicle.gps.count.rawValue > 7
                                PropertyChanges {target: gps_count_state_rect; color: "green"}
                            },
                            State {
                                name: "Normal"; when: _activeVehicle.gps.count.rawValue > 3 
                                PropertyChanges {target: gps_count_state_rect; color: "yellow"}//qgcPal.buttonHighlight}
                            }
                        ]
                    }

                    QGCLabel { text: qsTr("GPS Lock:") }
                    QGCLabel { text: _activeVehicle ? _activeVehicle.gps.lock.enumStringValue : qsTr("N/A", "No data to display") }
                    Rectangle {
                        id:     gps_string_state_rect
                        width:  height //ScreenTools.defaultFontPixelWidth
                        height: ScreenTools.defaultFontPixelHeight
                        color:  "green" // qgcPal.window
                        states: [
                            State {
                                name: "Disabled"; when: !_activeVehicle
                                PropertyChanges {target: gps_string_state_rect; color: "red"}//color: qgcPal.button}
                            },
                            State {
                                name: "None"; when: _activeVehicle.gps.lock.enumStringValue == "None"
                                PropertyChanges {target: gps_string_state_rect; color: "red"}//qgcPal.buttonHighlight}
                            },
                            State {
                                name: "2D Lock"; when: _activeVehicle.gps.lock.enumStringValue == "2D Lock"
                                PropertyChanges {target: gps_string_state_rect; color: "yellow"}//qgcPal.buttonHighlight}
                            },
                            State {
                                name: "3D Lock"; when: _activeVehicle.gps.lock.enumStringValue == "3D Lock"
                                PropertyChanges {target: gps_string_state_rect; color: "green"}//qgcPal.buttonHighlight}
                            },
                            State {
                                name: "3D DGPS Lock"; when: _activeVehicle.gps.lock.enumStringValue == "3D DGPS Lock"
                                PropertyChanges {target: gps_string_state_rect; color: "green"}//qgcPal.buttonHighlight}
                            },
                            State {
                                name: "3D RTK GPS Lock (float)"; when: _activeVehicle.gps.lock.enumStringValue == "3D RTK GPS Lock (float)"
                                PropertyChanges {target: gps_string_state_rect; color: "yellow"}//qgcPal.buttonHighlight}
                            },
                            State {
                                name: "3D RTK GPS Lock (fixed)"; when: _activeVehicle.gps.lock.enumStringValue == "3D RTK GPS Lock (fixed)"
                                PropertyChanges {target: gps_string_state_rect; color: "green"}
                            },
                            State {
                                name: "Static (fixed)"; when: _activeVehicle.gps.lock.enumStringValue == "Static (fixed)"
                                PropertyChanges {target: gps_string_state_rect; color: "green"}
                            }
                        ]
                    }

                    QGCLabel { text: qsTr("HDOP:") }
                    QGCLabel { text: _activeVehicle ? _activeVehicle.gps.hdop.valueString : qsTr("--.--", "No data to display") }
                    Rectangle {
                        id:     gps_HDOP_state_rect
                        width:  height //ScreenTools.defaultFontPixelWidth
                        height: ScreenTools.defaultFontPixelHeight
                        color:  "green" // qgcPal.window
                        states: [
                            State {
                                name: "Disabled"; when: !_activeVehicle
                                PropertyChanges {target: gps_HDOP_state_rect; color: "red"}//color: qgcPal.button}
                            },
                            State {
                                name: "Nominal"; when: _activeVehicle.gps.hdop.rawValue < 1.7
                                PropertyChanges {target: gps_HDOP_state_rect; color: "green"}
                            },
                            State {
                                name: "Warning"; when: _activeVehicle.gps.hdop.rawValue < 10 
                                PropertyChanges {target: gps_HDOP_state_rect; color: "yellow"}//qgcPal.buttonHighlight}
                            }
                        ]
                    }

                    QGCLabel { text: qsTr("VDOP:") }
                    QGCLabel { text: _activeVehicle ? _activeVehicle.gps.vdop.valueString : qsTr("--.--", "No data to display") }
                    Rectangle {
                        id:     gps_VDOP_state_rect
                        width:  height //ScreenTools.defaultFontPixelWidth
                        height: ScreenTools.defaultFontPixelHeight
                        color:  "green" // qgcPal.window
                        states: [
                            State {
                                name: "Disabled"; when: !_activeVehicle
                                PropertyChanges {target: gps_VDOP_state_rect; color: "red"}//color: qgcPal.button}
                            },
                            State {
                                name: "Nominal"; when: _activeVehicle.gps.vdop.rawValue < 2.1
                                PropertyChanges {target: gps_VDOP_state_rect; color: "green"}
                            },
                            State {
                                name: "Warning"; when: _activeVehicle.gps.vdop.rawValue < 10 
                                PropertyChanges {target: gps_VDOP_state_rect; color: "yellow"}//qgcPal.buttonHighlight}
                            }
                        ]
                    }

                    // QGCLabel { text: qsTr("Course Over Ground:") }
                    // QGCLabel { text: _activeVehicle ? _activeVehicle.gps.courseOverGround.valueString : qsTr("--.--", "No data to display") }

                    QGCLabel { text: qsTr("Latitude:") }
                    QGCLabel { text: _activeVehicle ? _activeVehicle.gps.lat.valueString : qsTr("--.--", "No data to display") }
                    Rectangle {
                        id:     gps_lat_rect
                        width:  height //ScreenTools.defaultFontPixelWidth
                        height: ScreenTools.defaultFontPixelHeight
                        color:  _activeVehicle ? "green" : qgcPal.button// qgcPal.window
                    }

                    QGCLabel { text: qsTr("Longitude:") }
                    QGCLabel { text: _activeVehicle ? _activeVehicle.gps.lon.valueString : qsTr("--.--", "No data to display") }
                    Rectangle {
                        id:     gps_lon_rect
                        width:  height //ScreenTools.defaultFontPixelWidth
                        height: ScreenTools.defaultFontPixelHeight
                        color:  _activeVehicle ? "green" : qgcPal.button// qgcPal.window
                    }
                }
            }
        }
    }

    Component {
        id: vtolTransitionComponent

        Rectangle {
            width:          mainLayout.width   + (_margins * 2)
            height:         mainLayout.height  + (_margins * 2)
            radius:         ScreenTools.defaultFontPixelHeight * 0.5
            color:          qgcPal.window
            border.color:   qgcPal.text

            QGCButton {
                id:                 mainLayout
                anchors.margins:    _margins
                anchors.top:        parent.top
                anchors.left:       parent.left
                text:               _vtolInFWDFlight ? qsTr("Transition to Multi-Rotor") : qsTr("Transition to Fixed Wing")

                onClicked: {
                    if (_vtolInFWDFlight) {
                        mainWindow.vtolTransitionToMRFlightRequest()
                    } else {
                        mainWindow.vtolTransitionToFwdFlightRequest()
                    }
                    mainWindow.hideIndicatorPopup()
                }
            }
        }
    }

    Text {
        id:                         _text
        anchors {
            verticalCenter:         parent.verticalCenter
            horizontalCenter:       parent.horizontalCenter
        }
        antialiasing:               true
        text:                       _activeVehicle ? _activeVehicle.gps.lock.enumStringValue : qsTr("GPS: N/A")
        font.pointSize:             pointSize
        font.family:                ScreenTools.normalFontFamily
        color:                      qgcPal.buttonText
        enabled:                    _activeVehicle

        width:                      backRect.width
        wrapMode:                   Text.WordWrap
        maximumLineCount:           1
        horizontalAlignment:        Text.AlignHCenter
        verticalAlignment:          Text.AlignVCenter

        states: [
            State {
                name: "on_mouse"; when: onMouseHighlight && showOnMouseHighlight
                PropertyChanges {
                    target: _text; 
                    color:  onMouseHighlight ? 
                        qgcPal.buttonHighlightText : (primary ? qgcPal.primaryButtonText : qgcPal.buttonText)
                }
            },
            State {
                name: "Normal"; when: statusActivity == statusNormal
                PropertyChanges {target: _text; color: qgcPal.buttonHighlightText}
            },
            State {
                name: "Error"; when: statusActivity == statusError
                PropertyChanges {target: _text; color: qgcPal.primaryButtonText}
            },
            State {
                name: "Disabled"; when: statusActivity == statusDisabled
                PropertyChanges {target: _text; color: qgcPal.buttonText}
            }
        ]
    }

    QGCMouseArea {
        anchors.fill:   parent
        onClicked:      mainWindow.showIndicatorPopup(control, sensorMavStatusGPSComponent)
    }
}