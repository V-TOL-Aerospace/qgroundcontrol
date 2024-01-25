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
import QGroundControl.Vehicle               1.0

ColumnLayout {
    id:             root
    spacing:        ScreenTools.defaultFontPixelWidth * 0.5
    property var    activeVehicle

    property string _distanceUnit:          QGroundControl.unitsConversion.appSettingsVerticalDistanceUnitsString

    property real   _distanceToHomeRaw:     activeVehicle ? activeVehicle.distanceToHome.rawValue : 0 
    property real   _flightDistanceRaw:     activeVehicle ? activeVehicle.flightDistance.rawValue : 0 
    property real   _headingToHome:         activeVehicle ? activeVehicle.headingToHome.rawValue  : 0 
    property real   _headingFromHome:       activeVehicle ? getHeadingFromHome(_headingToHome)    : 0
    property var    _hobbsMeasure:          activeVehicle ? activeVehicle.hobbs.rawValue  : "0000:00:00" 
    property real   _timeToHome:            activeVehicle ? activeVehicle.timeToHome.rawValue : 0

    property string _distanceToHomeStr:     _distanceToHomeRaw.toFixed(0) + " " + _distanceUnit
    property string _flightDistanceStr:     _flightDistanceRaw.toFixed(0) + " " + _distanceUnit
    property string _timeToHomeStr:         secondsToHHMMSS(_timeToHome)
    property var    _flightTime:            activeVehicle ? activeVehicle.flightTime.rawValue : 0 
    property string _flightTimeStr:         secondsToHHMMSS(_flightTime)
    
    property string _headingToHomeStr:      _headingToHome ? headingInThreeSpaces(_headingToHome.toFixed(0)) + " " + compassHeadingStr(_headingToHome) : "At Home Position"
    property string _headingFromHomeStr:    _headingFromHome ? headingInThreeSpaces(_headingFromHome.toFixed(0)) + " " + compassHeadingStr(_headingFromHome) : "At Home Position"

    function compassHeadingStr(compass_heading) {
        if (compass_heading >= 337.5 || compass_heading <= 22.5) {
            return "N"
        }
        else if (compass_heading >= 22.5 && compass_heading <= 67.5) {
            return "NE"
        }
        else if (compass_heading >= 67.5 && compass_heading <= 112.5) {
            return "E"
        }
        else if (compass_heading >= 112.5 && compass_heading <= 157.5) {
            return "SE"
        }
        else if (compass_heading >= 157.5 && compass_heading <= 202.5) {
            return "S"
        }
        else if (compass_heading >= 202.5 && compass_heading <= 247.5) {
            return "SW"
        }
        else if (compass_heading >= 247.5 && compass_heading <= 292.5) {
            return "W"
        }
        else if (compass_heading >= 292.5 && compass_heading <= 337.5) {
            return "NW"
        }
        return ""
    }

    function secondsToHHMMSS(timeS) {
        var sec_num = parseInt(timeS, 10);
        var hours   = Math.floor(sec_num / 3600);
        var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
        var seconds = sec_num - (hours * 3600) - (minutes * 60);
        if (hours   < 10) {hours   = "0"+hours;}
        if (minutes < 10) {minutes = "0"+minutes;}
        if (seconds < 10) {seconds = "0"+seconds;}
        return hours+':'+minutes+':'+seconds;
    }

    function getHeadingFromHome(headingToHome) {
        var headingFromHome = headingToHome - 180;
        if (headingFromHome < 0) {
            headingFromHome = 360 + headingFromHome;
        }
        return headingFromHome
    }

    function headingInThreeSpaces(heading1) {
        var heading2 = heading1.length === 1 ? "0" + heading1 : heading1;
        var heading3 = heading2.length === 2 ? "0" + heading2 : heading2;
        return heading3
    }

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

                QGCLabel { text: qsTr("Current Date & Time")}
                QGCLabel { text: activeVehicle ? Date().toString() : qsTr("No data to display")}

                QGCLabel { text: qsTr("Hobbs Counter (HHHH:MM:SS):")}
                QGCLabel { text: activeVehicle ? _hobbsMeasure : qsTr("No data to display")}
                                
                QGCLabel { text: qsTr("Flight Time Δt (HH:MM:SS): ")}
                QGCLabel { text: _flightTimeStr}

                QGCLabel { text: qsTr("Distance Traveled:") }
                QGCLabel { text: activeVehicle ? _flightDistanceStr : qsTr("No data to display") }

                QGCLabel { text: qsTr("Distance To Home:") }
                QGCLabel { text: activeVehicle ? _distanceToHomeStr : qsTr("No data to display") }

                QGCLabel { text: qsTr("Est. Time To Home (HH:MM:SS):") }
                QGCLabel { text: activeVehicle ? _timeToHomeStr : qsTr("No data to display") }

                QGCLabel { text: qsTr("Heading To Home:") }
                QGCLabel { text: _headingToHomeStr }

                QGCLabel { text: qsTr("Heading From Home:") }
                QGCLabel { text: _headingFromHomeStr }
            }
        }
    }
}