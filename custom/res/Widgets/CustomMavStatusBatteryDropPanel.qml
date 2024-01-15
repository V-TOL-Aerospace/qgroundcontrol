import QtQuick              2.11
import QtQuick.Controls     2.12
import QtQuick.Layouts      1.11

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.FactControls          1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.Palette               1.0
import QGroundControl.ScreenTools           1.0

ColumnLayout {
    id:             root
    spacing:        ScreenTools.defaultFontPixelWidth * 0.5
    
    property var    activeVehicle
    property var    _batteryGroup:              activeVehicle && activeVehicle.batteries.count ? activeVehicle.batteries.get(0) : undefined
    property var    _batteryValue:              _batteryGroup ? _batteryGroup.percentRemaining.value : 0
    property var    _batteryPercentRemaining:   isNaN(_batteryValue) ? 0 : _batteryValue
    property var    _batteryVoltageValue:       _batteryGroup.voltage.rawValue 
    property var    _batteryVoltage:            _batteryGroup.voltage.valueString 
    property var    _batteryVoltageString:      _batteryVoltage + qsTr(" ") + _batteryGroup.voltage.units

    Rectangle {
        id:             batteryInfoWindow
        width:          batteryInfoColumn.width     + ScreenTools.defaultFontPixelWidth  * 3
        height:         batteryInfoColumn.height    + ScreenTools.defaultFontPixelHeight * 2
        radius:         ScreenTools.defaultFontPixelHeight * 0.5
        color:          qgcPal.window
        border.color:   qgcPal.text
        
        Column {
            id:             batteryInfoColumn
            spacing:        ScreenTools.defaultFontPixelHeight * 0.5
            anchors {
                margins:    ScreenTools.defaultFontPixelHeight
                centerIn:   parent
            }

            QGCLabel {
                id:                         batteryInfoLabel
                text:                       activeVehicle ? qsTr("Battery Info") : qsTr("No Aircraft Connected")
                font.family:                ScreenTools.demiboldFontFamily
                anchors.horizontalCenter:   parent.horizontalCenter
            }

            GridLayout {
                id:                         batteryInfoGridLayout
                visible:                    activeVehicle
                columnSpacing:              ScreenTools.defaultFontPixelHeight
                anchors.horizontalCenter:   parent.horizontalCenter
                columns:                    3

                QGCLabel { text: qsTr("Battery Pertentage (%): ") }
                QGCLabel { text: _batteryPercentRemaining + qsTr(" %") }
                Rectangle {
                    id:     batteryInfoRect_Percentage
                    width:  height
                    height: ScreenTools.defaultFontPixelHeight
                    color:  qgcPal.windowShade
                    states: [
                        State {
                            name: "Disabled"; when: !_batteryGroup
                            PropertyChanges {target: batteryInfoRect_Percentage; color: qgcPal.windowShade} 
                        },
                        State {
                            name: "Normal"; when: _batteryPercentRemaining > 75
                            PropertyChanges {target: batteryInfoRect_Percentage; color: qgcPal.colorGreen}
                        },
                        State {
                            name: "Warning"; when: _batteryPercentRemaining > 50 
                            PropertyChanges {target: batteryInfoRect_Percentage; color: qgcPal.colorOrange} 
                        },
                        State {
                            name: "Critical"; when: _batteryPercentRemaining > 0.1 
                            PropertyChanges {target: batteryInfoRect_Percentage; color: qgcPal.colorOrange} 
                        }
                    ]
                }

                QGCLabel { text: qsTr("Battery Voltage (V): ") }
                QGCLabel { text: _batteryVoltageString }
                Rectangle {
                    id:     batteryInfoRect_Voltage
                    width:  height
                    height: ScreenTools.defaultFontPixelHeight
                    color:  qgcPal.windowShade
                    states: [
                        State {
                            name: "Disabled"; when: isNaN(_batteryVoltageValue)
                            PropertyChanges {target: batteryInfoRect_Voltage; color: qgcPal.windowShade} 
                        },
                        State {
                            name: "Normal"; when: _batteryPercentRemaining > 75
                            PropertyChanges {target: batteryInfoRect_Voltage; color: qgcPal.colorGreen}
                        },
                        State {
                            name: "Warning"; when: _batteryPercentRemaining > 50 
                            PropertyChanges {target: batteryInfoRect_Voltage; color: qgcPal.colorOrange} 
                        },
                        State {
                            name: "Critical"; when: _batteryPercentRemaining > 0.1 
                            PropertyChanges {target: batteryInfoRect_Voltage; color: qgcPal.colorOrange} 
                        }
                    ]
                }

                QGCLabel { text: qsTr("Battery Current (A): ") }
                QGCLabel { text: qsTr("") }
                Rectangle {
                    id:     batteryInfoRect_Current
                    width:  height
                    height: ScreenTools.defaultFontPixelHeight
                    color:  qgcPal.windowShade
                    states: [
                        State {
                            name: "Disabled"; when: !_batteryGroup
                            PropertyChanges {target: batteryInfoRect_Current; color: qgcPal.windowShade} 
                        },
                        State {
                            name: "Normal"; when: _batteryPercentRemaining > 75
                            PropertyChanges {target: batteryInfoRect_Current; color: qgcPal.colorGreen}
                        },
                        State {
                            name: "Warning"; when: _batteryPercentRemaining > 50 
                            PropertyChanges {target: batteryInfoRect_Current; color: qgcPal.colorOrange} 
                        },
                        State {
                            name: "Critical"; when: _batteryPercentRemaining > 0.1 
                            PropertyChanges {target: batteryInfoRect_Current; color: qgcPal.colorOrange} 
                        }
                    ]
                }
            }
        }
    }
}
