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

ColumnLayout {
    id:             root
    spacing:        ScreenTools.defaultFontPixelWidth * 0.5
    property var    activeVehicle

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
                text:                       (activeVehicle && activeVehicle.gps.count.value >= 0) ? qsTr("GPS Status") : qsTr("GPS Data Unavailable")
                font.family:                ScreenTools.demiboldFontFamily
                anchors.horizontalCenter:   parent.horizontalCenter
            }

            GridLayout {
                id:                         gpsGrid
                visible:                    (activeVehicle && activeVehicle.gps.count.value >= 0)
                // anchors.margins:            ScreenTools.defaultFontPixelHeight
                columnSpacing:              ScreenTools.defaultFontPixelWidth
                anchors.horizontalCenter:   parent.horizontalCenter
                columns:                    3

                QGCLabel { text: qsTr("GPS Count:") }
                QGCLabel { text: activeVehicle ? activeVehicle.gps.count.valueString : qsTr("N/A", "No data to display") }
                Rectangle {
                    id:     gps_count_state_rect
                    width:  height //ScreenTools.defaultFontPixelWidth
                    height: ScreenTools.defaultFontPixelHeight
                    color:  "green" // qgcPal.window
                    states: [
                        State {
                            name: "Disabled"; when: !activeVehicle
                            PropertyChanges {target: gps_count_state_rect; color: "red"}//color: qgcPal.button}
                        },
                        State {
                            name: "Normal"; when: activeVehicle.gps.count.rawValue > 7
                            PropertyChanges {target: gps_count_state_rect; color: "green"}
                        },
                        State {
                            name: "Warning"; when: activeVehicle.gps.count.rawValue > 3 
                            PropertyChanges {target: gps_count_state_rect; color: "yellow"}//qgcPal.buttonHighlight}
                        }
                    ]
                }

                QGCLabel { text: qsTr("GPS Lock:") }
                QGCLabel { text: activeVehicle ? activeVehicle.gps.lock.enumStringValue : qsTr("N/A", "No data to display") }
                Rectangle {
                    id:     gps_string_state_rect
                    width:  height //ScreenTools.defaultFontPixelWidth
                    height: ScreenTools.defaultFontPixelHeight
                    color:  "green" // qgcPal.window
                    states: [
                        State {
                            name: "Disabled"; when: !activeVehicle
                            PropertyChanges {target: gps_string_state_rect; color: "red"}//color: qgcPal.button}
                        },
                        State {
                            name: "None"; when: activeVehicle.gps.lock.enumStringValue == "None"
                            PropertyChanges {target: gps_string_state_rect; color: "red"}//qgcPal.buttonHighlight}
                        },
                        State {
                            name: "2D Lock"; when: activeVehicle.gps.lock.enumStringValue == "2D Lock"
                            PropertyChanges {target: gps_string_state_rect; color: "yellow"}//qgcPal.buttonHighlight}
                        },
                        State {
                            name: "3D Lock"; when: activeVehicle.gps.lock.enumStringValue == "3D Lock"
                            PropertyChanges {target: gps_string_state_rect; color: "green"}//qgcPal.buttonHighlight}
                        },
                        State {
                            name: "3D DGPS Lock"; when: activeVehicle.gps.lock.enumStringValue == "3D DGPS Lock"
                            PropertyChanges {target: gps_string_state_rect; color: "green"}//qgcPal.buttonHighlight}
                        },
                        State {
                            name: "3D RTK GPS Lock (float)"; when: activeVehicle.gps.lock.enumStringValue == "3D RTK GPS Lock (float)"
                            PropertyChanges {target: gps_string_state_rect; color: "yellow"}//qgcPal.buttonHighlight}
                        },
                        State {
                            name: "3D RTK GPS Lock (fixed)"; when: activeVehicle.gps.lock.enumStringValue == "3D RTK GPS Lock (fixed)"
                            PropertyChanges {target: gps_string_state_rect; color: "green"}
                        },
                        State {
                            name: "Static (fixed)"; when: activeVehicle.gps.lock.enumStringValue == "Static (fixed)"
                            PropertyChanges {target: gps_string_state_rect; color: "green"}
                        }
                    ]
                }

                QGCLabel { text: qsTr("HDOP:") }
                QGCLabel { text: activeVehicle ? activeVehicle.gps.hdop.valueString : qsTr("--.--", "No data to display") }
                Rectangle {
                    id:     gps_HDOP_state_rect
                    width:  height //ScreenTools.defaultFontPixelWidth
                    height: ScreenTools.defaultFontPixelHeight
                    color:  "green" // qgcPal.window
                    states: [
                        State {
                            name: "Disabled"; when: !activeVehicle
                            PropertyChanges {target: gps_HDOP_state_rect; color: "red"}//color: qgcPal.button}
                        },
                        State {
                            name: "Nominal"; when: activeVehicle.gps.hdop.rawValue < 1.7
                            PropertyChanges {target: gps_HDOP_state_rect; color: "green"}
                        },
                        State {
                            name: "Warning"; when: activeVehicle.gps.hdop.rawValue < 10 
                            PropertyChanges {target: gps_HDOP_state_rect; color: "yellow"}//qgcPal.buttonHighlight}
                        }
                    ]
                }

                QGCLabel { text: qsTr("VDOP:") }
                QGCLabel { text: activeVehicle ? activeVehicle.gps.vdop.valueString : qsTr("--.--", "No data to display") }
                Rectangle {
                    id:     gps_VDOP_state_rect
                    width:  height //ScreenTools.defaultFontPixelWidth
                    height: ScreenTools.defaultFontPixelHeight
                    color:  "green" // qgcPal.window
                    states: [
                        State {
                            name: "Disabled"; when: !activeVehicle
                            PropertyChanges {target: gps_VDOP_state_rect; color: "red"}//color: qgcPal.button}
                        },
                        State {
                            name: "Nominal"; when: activeVehicle.gps.vdop.rawValue < 2.1
                            PropertyChanges {target: gps_VDOP_state_rect; color: "green"}
                        },
                        State {
                            name: "Warning"; when: activeVehicle.gps.vdop.rawValue < 10 
                            PropertyChanges {target: gps_VDOP_state_rect; color: "yellow"}//qgcPal.buttonHighlight}
                        }
                    ]
                }

                // QGCLabel { text: qsTr("Course Over Ground:") }
                // QGCLabel { text: activeVehicle ? activeVehicle.gps.courseOverGround.valueString : qsTr("--.--", "No data to display") }

                QGCLabel { text: qsTr("Latitude:") }
                QGCLabel { text: activeVehicle ? activeVehicle.gps.lat.valueString : qsTr("--.--", "No data to display") }
                Rectangle {
                    id:     gps_lat_rect
                    width:  height //ScreenTools.defaultFontPixelWidth
                    height: ScreenTools.defaultFontPixelHeight
                    color:  activeVehicle ? "green" : qgcPal.button// qgcPal.window
                }

                QGCLabel { text: qsTr("Longitude:") }
                QGCLabel { text: activeVehicle ? activeVehicle.gps.lon.valueString : qsTr("--.--", "No data to display") }
                Rectangle {
                    id:     gps_lon_rect
                    width:  height //ScreenTools.defaultFontPixelWidth
                    height: ScreenTools.defaultFontPixelHeight
                    color:  activeVehicle ? "green" : qgcPal.button// qgcPal.window
                }
            }
        }
    }
}