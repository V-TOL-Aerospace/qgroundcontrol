/****************************************************************************
 *
 * (c) 2009-2019 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 * @file
 *   @author Gus Grubba <gus@auterion.com>
 */

import QtQuick              2.11
import QtGraphicalEffects   1.0

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0
import QGroundControl.FlightMap     1.0

Item {
    id: root

    property bool showPitch:    true
    property var  vehicle:      null
    property real size_width
    property real size_height
    property real size:         size_width

    property bool showHeading:  true

    property real _rollAngle:   vehicle ? vehicle.roll.rawValue  : 0
    property real _pitchAngle:  vehicle ? vehicle.pitch.rawValue : 0

    property real _altitudeRelative: vehicle ? vehicle.altitudeRelative.rawValue : 0
    property real _airSpeed: vehicle ? vehicle.airSpeed.rawValue : 0
    property string _altitudeRelative_string: vehicle ? _altitudeRelative.toFixed(0) + ' ' + QGroundControl.unitsConversion.appSettingsVerticalDistanceUnitsString : "0 " + QGroundControl.unitsConversion.appSettingsVerticalDistanceUnitsString
    property string _airSpeed_string: vehicle ? _airSpeed.toFixed(0) + ' ' + QGroundControl.unitsConversion.appSettingsSpeedUnitsString : "0 " + QGroundControl.unitsConversion.appSettingsSpeedUnitsString

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
        QGCPitchIndicator {
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
        //-- Relative Altitude Number
        Rectangle{
            id: altitude_info_rectangle
            anchors.right: parent.right
            anchors.rightMargin: _toolsMargin
            anchors.verticalCenter: parent.verticalCenter
            color:                      qgcPal.windowShadeDark
            height:                     ScreenTools.defaultFontPixelHeight
            width:                      ScreenTools.defaultFontPixelWidth * 7

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
        //-- Air Speed Number
        Rectangle{
            id:                         airspeed_info_rectangle
            anchors.left:               parent.left
            anchors.leftMargin:         _toolsMargin
            anchors.verticalCenter:     parent.verticalCenter
            color:                      qgcPal.windowShadeDark
            height:                     ScreenTools.defaultFontPixelHeight
            width:                      ScreenTools.defaultFontPixelWidth * 7

            QGCLabel{
                id: airspeed_info
                anchors.horizontalCenter:   parent.horizontalCenter
                anchors.verticalCenter:     parent.verticalCenter
                anchors.leftMargin: _toolsMargin + 5
                text: _airSpeed_string
                color: "white"
            }
        }

        //----------------------------------------------------
        //-- Heading Number 
        Rectangle{
            id:                         heading_info_rectangle
            anchors.bottom:             parent.bottom
            anchors.bottomMargin:       _toolsMargin
            anchors.horizontalCenter:   parent.horizontalCenter
            color:                      qgcPal.windowShadeDark
            height:                     ScreenTools.defaultFontPixelHeight
            width:                      ScreenTools.defaultFontPixelWidth * 7

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
        // radius:         width / 2
        color:          "black"
        visible:        true
    }

    OpacityMask {
        anchors.fill:   instrument
        source:         instrument
        maskSource:     mask
    }

    Rectangle {
        id:             borderRect
        anchors.fill:   parent
        // radius:         width / 2
        color:          Qt.rgba(0,0,0,0)
        border.color:   "#000"
        border.width:   1
    }

}
