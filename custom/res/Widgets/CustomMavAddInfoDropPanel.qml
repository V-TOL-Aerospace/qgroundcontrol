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

    property string _distanceUnit:          QGroundControl.unitsConversion.appSettingsVerticalDistanceUnitsString

    property real   _distanceToHomeRaw:     activeVehicle ? activeVehicle.distanceToHome.rawValue : 0
    property real   _flightDistanceRaw:     activeVehicle ? activeVehicle.flightDistance.rawValue : 0
    property real   _headingToHome:         activeVehicle ? activeVehicle.headingToHome.rawValue  : 0 
    property var    _hobbsMeasure:          activeVehicle ? activeVehicle.hobbs.rawValue  : "0000:00:00"

    property string _distanceToHomeStr:     _distanceToHomeRaw.toFixed(0) + " " + _distanceUnit
    property string _flightDistanceStr:     _flightDistanceRaw.toFixed(0) + " " + _distanceUnit
    property string _headingToHomeStr:      _headingToHome ? _headingToHome.toFixed(0) : "At Home"

    Rectangle {
        id:                         additional_info_window
        width:                      additional_info_column.width   + ScreenTools.defaultFontPixelWidth  * 3
        height:                     additional_info_column.height  + ScreenTools.defaultFontPixelHeight * 2
        radius:                     ScreenTools.defaultFontPixelHeight * 0.5
        color:                      qgcPal.window
        border.color:               qgcPal.text
        visible:                    true

        Column {
            id:                 additional_info_column
            spacing:            ScreenTools.defaultFontPixelHeight * 0.5
            anchors.margins:    ScreenTools.defaultFontPixelHeight
            anchors.centerIn:   parent

            QGCLabel {
                id:                         additional_info_title
                text:                       qsTr("                     Additional Info                     ")
                font.family:                ScreenTools.demiboldFontFamily
                anchors.horizontalCenter:   parent.horizontalCenter
            }

            GridLayout {
                id:                         additional_info_grid
                visible:                    true
                columnSpacing:              ScreenTools.defaultFontPixelWidth
                anchors.horizontalCenter:   parent.horizontalCenter
                columns:                    2

                QGCLabel { text: qsTr("Hobbs Counter (HHHH:MM:SS):")}
                QGCLabel { text: activeVehicle ? _hobbsMeasure : qsTr("N/A", "No data to display")}

                QGCLabel { text: qsTr("Distance Traveled:") }
                QGCLabel { text: activeVehicle ? _flightDistanceStr : qsTr("N/A", "No data to display") }

                QGCLabel { text: qsTr("Distance To Home:") }
                QGCLabel { text: activeVehicle ? _distanceToHomeStr : qsTr("N/A", "No data to display") }

                QGCLabel { text: qsTr("Heading To Home:") }
                QGCLabel { text: activeVehicle ? _headingToHomeStr : qsTr("N/A", "No data to display") }
            }
        }
    }
}