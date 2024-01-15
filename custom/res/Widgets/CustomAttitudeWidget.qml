import QtQuick              2.11
import QtGraphicalEffects   1.0
import QtQuick.Window       2.2

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0
import QGroundControl.FlightMap     1.0

import Custom.Widgets 1.0

Item {
    id: root

    property bool showPitch:        true
    property var  vehicle:          null
    property real size_width
    property real size_height 
    property real size:             size_width
    property bool showHeading:      true
    property bool showBackground:   true

    property real _rollAngle:       vehicle ? vehicle.roll.rawValue  : 0
    property real _pitchAngle:      vehicle ? vehicle.pitch.rawValue : 0
    property string _flightMode:    vehicle ? vehicle.flightMode : qsTr("N/A")
    property string _currentIndex:  vehicle ? (vehicle.missionItemIndex.rawValue == 1 ? qsTr("T/O") : qsTr("WP ") + vehicle.missionItemIndex.rawValue): qsTr("N/A")

    property real _altitudeRelative:    vehicle ? vehicle.altitudeRelative.rawValue : 0
    property real _airSpeed:            vehicle ? vehicle.airSpeed.rawValue : 0
    property real _climbRate:           vehicle ? vehicle.climbRate.rawValue : 0

    property string _altitudeRelative_with_unit:    vehicle ? _altitudeRelative.toFixed(0) + ' ' + QGroundControl.unitsConversion.appSettingsVerticalDistanceUnitsString : "0 " + QGroundControl.unitsConversion.appSettingsVerticalDistanceUnitsString
    property string _airspeed_string_with_unit:     vehicle ? _airSpeed.toFixed(0) + ' ' + QGroundControl.unitsConversion.appSettingsSpeedUnitsString : "0 " + QGroundControl.unitsConversion.appSettingsSpeedUnitsString
    property string _climbRate_string_with_unit:    vehicle ? _climbRate.toFixed(1) + ' ' + QGroundControl.unitsConversion.appSettingsSpeedUnitsString : "0 " + QGroundControl.unitsConversion.appSettingsSpeedUnitsString

    property string _altitudeRelative_string:       (Window.width < 1000) ? _altitudeRelative_with_unit: qsTr("ALT: ") + _altitudeRelative_with_unit 
    property string _airSpeed_string:               (Window.width < 1000) ? _airspeed_string_with_unit : qsTr("AS: ") + _airspeed_string_with_unit 
    property string _climbRate_string:              (Window.width < 1000) ? _climbRate_string_with_unit : qsTr("VS: ") + _climbRate_string_with_unit 

    width:  size_width
    height: size_height

    Item {
        id:             instrument
        anchors.fill:   parent
        visible:        false

        //----------------------------------------------------
        //-- Artificial Horizon
        CustomArtificialHorizon {
            rollAngle:          _rollAngle
            pitchAngle:         _pitchAngle
            skyColor1:          vehicle ? "#0a2e50" : qgcPal.windowShade
            skyColor2:          vehicle ? "#2f85d4" : qgcPal.windowShade
            groundColor1:       vehicle ? "#897459" : qgcPal.windowShadeDark
            groundColor2:       vehicle ? "#4b3820" : qgcPal.windowShadeDark
            anchors.fill:       parent
            visible:            showBackground
        }
        //----------------------------------------------------
        //-- Instrument Dial
        Image {
            id:                 instrumentDial
            source:             "/custom/img/attitude_dial.svg"
            mipmap:             true
            fillMode:           Image.PreserveAspectFit
            anchors.fill:       parent
            sourceSize.height:  parent.height
            transform: Rotation {
                origin.x:       root.width  / 2
                origin.y:       root.height / 2
                angle:          -_rollAngle
            }
        }
        //----------------------------------------------------
        //-- Pointer
        Image {
            id:                 pointer
            height:             size * 0.0625
            width:              height
            source:             "/custom/img/attitude_pointer.svg"
            antialiasing:       true
            fillMode:           Image.PreserveAspectFit
            sourceSize.height:  height
            anchors.top:        parent.top
            anchors.horizontalCenter: parent.horizontalCenter
        }
        //----------------------------------------------------
        //-- Pitch
        CustomQGCPitchIndicator {
            id:                 pitchWidget
            visible:            root.showPitch
            size:               root.size * 0.5
            anchors.verticalCenter: parent.verticalCenter
            pitchAngle:         _pitchAngle
            rollAngle:          _rollAngle
            color:              Qt.rgba(0,0,0,0)
        }
        //----------------------------------------------------
        //-- Cross Hair
        Image {
            id:                 crossHair
            anchors.centerIn:   parent
            source:             "/custom/img/attitude_crosshair_v2.svg"
            mipmap:             true
            width:              size * 0.75
            sourceSize.width:   width
            fillMode:           Image.PreserveAspectFit
        }
        //----------------------------------------------------
        //-- INDICATED RELATIVE ALTITUDE
        Rectangle{
            id: altitude_info_rectangle
            anchors.right: parent.right
            anchors.rightMargin: _toolsMargin
            anchors.verticalCenter: parent.verticalCenter
            color:                      qgcPal.windowShadeDark
            height:                     ScreenTools.defaultFontPixelHeight
            width:                      (Window.width > 1000) ? ScreenTools.defaultFontPixelWidth * 11 : ScreenTools.defaultFontPixelWidth * 6

            QGCLabel{
                id: altitude_info
                anchors.horizontalCenter:   parent.horizontalCenter
                anchors.verticalCenter:     parent.verticalCenter
                anchors.leftMargin: _toolsMargin + 5
                text: _altitudeRelative_string
                color: "white"
            }
        }
        //----------------------------------------------------
        //-- INDICATED AIR SPEED
        Rectangle{
            id:                         airspeed_info_rectangle
            anchors.left:               parent.left
            anchors.leftMargin:         _toolsMargin
            anchors.verticalCenter:     parent.verticalCenter
            color:                      qgcPal.windowShadeDark
            height:                     ScreenTools.defaultFontPixelHeight
            width:                      (Window.width > 1000) ? ScreenTools.defaultFontPixelWidth * 11 : ScreenTools.defaultFontPixelWidth * 5

            QGCLabel{
                id: airspeed_info
                anchors {
                    horizontalCenter:   parent.horizontalCenter
                    verticalCenter:     parent.verticalCenter
                    leftMargin:         _toolsMargin + 5
                }
                text:                   _airSpeed_string
                color:                  "white"
            }
        }
        //----------------------------------------------------
        //-- INDICATED FLIGHT MODE SELECTED
        Rectangle{
            id: flightMode_info_rectangle
            anchors {
                right:          altitude_info_rectangle.right
                top:            heading_info_rectangle.top
            }
            color:              qgcPal.windowShadeDark
            height:             ScreenTools.defaultFontPixelHeight
            width:              (Window.width > 1000) ? ScreenTools.defaultFontPixelWidth * 11 : ScreenTools.defaultFontPixelWidth * 6

            QGCLabel{
                id: flightMode_info
                anchors {
                    horizontalCenter:   parent.horizontalCenter
                    verticalCenter:     parent.verticalCenter
                    leftMargin:         _toolsMargin + 5
                }
                text: _flightMode
                color: "white"
            }
        }
        //----------------------------------------------------
        //-- CURRENT WAYPOINT
        Rectangle{
            id: currentWaypoint_info_rectangle
            anchors {
                left:           airspeed_info_rectangle.left           
                top:            heading_info_rectangle.top
            }
            color:              qgcPal.windowShadeDark
            height:             ScreenTools.defaultFontPixelHeight
            width:              ScreenTools.defaultFontPixelWidth * 5

            QGCLabel{
                id: currentWaypoint_info
                anchors {
                    horizontalCenter:   parent.horizontalCenter
                    verticalCenter:     parent.verticalCenter
                    leftMargin:         _toolsMargin + 5
                }
                text: _currentIndex
                color: "white"
            }
        }
        //----------------------------------------------------
        //-- INDICATED CLIMBRATE
        Rectangle{
            id: climbRate_info_rectangle
            anchors {
                left:           altitude_info_rectangle.left           
                top:            altitude_info_rectangle.bottom
                topMargin:      _toolsMargin
            }
            color:              qgcPal.windowShadeDark
            height:             ScreenTools.defaultFontPixelHeight
            width:              (Window.width > 1000) ? ScreenTools.defaultFontPixelWidth * 11 : ScreenTools.defaultFontPixelWidth * 6

            QGCLabel{
                id: climbRate_info
                anchors {
                    horizontalCenter:   parent.horizontalCenter
                    verticalCenter:     parent.verticalCenter
                    leftMargin:         _toolsMargin + 5
                }
                text: _climbRate_string
                color: "white"
            }
        }
        //----------------------------------------------------
        //-- INDICATED HEADING 
        Rectangle{
            id:                         heading_info_rectangle
            anchors.bottom:             parent.bottom
            anchors.bottomMargin:       _toolsMargin
            anchors.horizontalCenter:   parent.horizontalCenter
            color:                      qgcPal.windowShadeDark
            height:                     ScreenTools.defaultFontPixelHeight
            width:                      ScreenTools.defaultFontPixelWidth * 5

            QGCLabel {
                anchors.horizontalCenter:   parent.horizontalCenter
                anchors.verticalCenter:     parent.verticalCenter
                text:                       _headingString3
                color:                      "white"
                visible:                    showHeading
                // font.pointSize:             ScreenTools.smallFontPointSize
                property string _headingString: vehicle ? vehicle.heading.rawValue.toFixed(0) : "OFF"
                property string _headingString2: _headingString.length  === 1 ? "0" + _headingString  : _headingString
                property string _headingString3: _headingString2.length === 2 ? "0" + _headingString2 : _headingString2
            }
        }
    }

    Rectangle {
        id:             mask
        anchors.fill:   instrument
        // radius:         width * 0.5
        color:          "black"
        visible:        showBackground
    }

    OpacityMask {
        anchors.fill:   instrument
        source:         instrument
        maskSource:     mask
    }

    Rectangle {
        id:             borderRect
        anchors.fill:   parent
        // radius:         width * 0.5
        color:          Qt.rgba(0,0,0,0)
        border.color:   "#000"
        border.width:   1
    }

}
