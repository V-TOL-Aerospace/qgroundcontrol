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

    property string _altitudeRelative_string:       isPFDSize400 ? qsTr("ALT: ")    + _altitudeRelative_with_unit   : _altitudeRelative_with_unit
    property string _airSpeed_string:               isPFDSize400 ? qsTr("AS: ")     + _airspeed_string_with_unit    : _airspeed_string_with_unit
    property string _climbRate_string:              isPFDSize400 ? qsTr("VS: ")     + _climbRate_string_with_unit   : _climbRate_string_with_unit

    width:  size_width
    height: size_height

    property bool isPFDSize400:     root.width > 400
    property var dynamicFontSize:   isPFDSize400 ? ScreenTools.defaultFontPointSize     * 1.5   : ScreenTools.defaultFontPointSize // TODO: IF STATEMENT FOR IF root.size is of certain size
    property var dynamicFontWidth:  isPFDSize400 ? ScreenTools.defaultFontPixelWidth    * 15    : ScreenTools.defaultFontPixelWidth * 6
    property var dynamicFontHeight: isPFDSize400 ? ScreenTools.defaultFontPixelHeight   * 1.5   : ScreenTools.defaultFontPixelHeight

    property var scalingFontSize:   isPFDSize400 ? ScreenTools.defaultFontPointSize    * width * 0.00375    : ScreenTools.defaultFontPointSize
    property var scalingFontWidth:  isPFDSize400 ? ScreenTools.defaultFontPixelWidth   * width * 0.035      : ScreenTools.defaultFontPixelWidth * 6
    property var scalingFontHeight: isPFDSize400 ? ScreenTools.defaultFontPixelHeight  * width * 0.00375    : ScreenTools.defaultFontPixelHeight

    Item {
        id:             instrument
        anchors.fill:   parent
        visible:        false

        //-- INSTRUMENT ICONS
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
                origin.x:       root.width  * 0.5
                origin.y:       root.height * 0.5
                angle:          -_rollAngle
            }
        }
        //----------------------------------------------------
        //-- Pointer
        Image {
            id:                     pointer
            height:                 size * 0.0625
            width:                  height
            source:                 "/custom/img/attitude_pointer.svg"
            antialiasing:           true
            fillMode:               Image.PreserveAspectFit
            sourceSize.height:      height
            anchors {
                top:                parent.top
                horizontalCenter:   parent.horizontalCenter
            }
        }
        //----------------------------------------------------
        //-- Pitch
        CustomQGCPitchIndicator {
            id:                 pitchWidget
            visible:            root.showPitch
            size:               root.size * 0.5
            anchors {
                verticalCenter: parent.verticalCenter
            }
            pitchAngle:         _pitchAngle
            rollAngle:          _rollAngle
            color:              Qt.rgba(0,0,0,0)
            _fontSize:          scalingFontSize
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
        
        //-- LABEL INDICATORS - FOR DEBUGGING ONLY
        Rectangle {
            id:                     devRootSizeDisplay // For dev reference and debugging of attitude window size. 
            anchors {
                top:                parent.top
                horizontalCenter:   parent.horizontalCenter
                topMargin:          _toolsMargin
            }
            color:                  qgcPal.windowShadeDark
            height:                 scalingFontHeight   
            width:                  scalingFontWidth
            visible:                true

            QGCLabel {
                id:                 devRootSizeDisplayLabel
                anchors {
                    horizontalCenter:   parent.horizontalCenter
                    verticalCenter:     parent.verticalCenter
                    leftMargin:         _toolsMargin + 5
                }
                text:               root.width + qsTr(" >> ") + (root.width * 0.01)
                color:              qgcPal.text
                font.pointSize:     scalingFontSize
                visible:            true
            }
        }

        //----------------------------------------------------
        //-- INDICATED RELATIVE ALTITUDE 
        Rectangle {
            id:                 altitude_info_rectangle
            anchors {
                verticalCenter: parent.verticalCenter
                right:          parent.right 
                rightMargin:    _toolsMargin + instrument.width * 0.05
            }
            color:              qgcPal.windowShadeDark
            height:             scalingFontHeight   
            width:              scalingFontWidth //(Window.width > 1000) ? ScreenTools.defaultFontPixelWidth * 11 : ScreenTools.defaultFontPixelWidth * 6

            QGCLabel{
                id:                     altitude_info
                anchors {
                    horizontalCenter:   parent.horizontalCenter
                    verticalCenter:     parent.verticalCenter
                    leftMargin:         _toolsMargin + 5
                }
                text:                   _altitudeRelative_string
                color:                  qgcPal.text
                font.pointSize:     scalingFontSize
            }
        }
        //----------------------------------------------------
        //-- INDICATED AIR SPEED
        Rectangle{
            id:                         airspeed_info_rectangle
            anchors {
                verticalCenter:         parent.verticalCenter
                left:                   parent.left
                leftMargin:             _toolsMargin + instrument.width * 0.05
            }
            color:                      qgcPal.windowShadeDark
            height:                     scalingFontHeight   
            width:                      scalingFontWidth  // (Window.width > 1000) ? ScreenTools.defaultFontPixelWidth * 11 : ScreenTools.defaultFontPixelWidth * 6

            QGCLabel{
                id: airspeed_info
                anchors {
                    horizontalCenter:   parent.horizontalCenter
                    verticalCenter:     parent.verticalCenter
                    leftMargin:         _toolsMargin + 5
                }
                text:                   _airSpeed_string
                color:                  qgcPal.text
                font.pointSize:     scalingFontSize
            }
        }
        //----------------------------------------------------
        //-- INDICATED FLIGHT MODE SELECTED
        Rectangle{
            id:                 flightMode_info_rectangle
            anchors {
                right:          altitude_info_rectangle.right
                top:            heading_info_rectangle.top
            }
            color:              qgcPal.windowShadeDark
            height:             scalingFontHeight   
            width:              scalingFontWidth //(Window.width > 1000) ? ScreenTools.defaultFontPixelWidth * 11 : ScreenTools.defaultFontPixelWidth * 6

            QGCLabel{
                id:                     flightMode_info
                anchors {
                    horizontalCenter:   parent.horizontalCenter
                    verticalCenter:     parent.verticalCenter
                    leftMargin:         _toolsMargin + 5
                }
                text: _flightMode
                color: qgcPal.text
                font.pointSize:     scalingFontSize
            }
        }
        //----------------------------------------------------
        //-- CURRENT WAYPOINT
        Rectangle{
            id:                 currentWaypoint_info_rectangle
            anchors {
                left:           airspeed_info_rectangle.left           
                top:            heading_info_rectangle.top
            }
            color:              qgcPal.windowShadeDark
            height:             scalingFontHeight   
            width:              scalingFontWidth

            QGCLabel{
                id:                     currentWaypoint_info
                anchors {
                    horizontalCenter:   parent.horizontalCenter
                    verticalCenter:     parent.verticalCenter
                    leftMargin:         _toolsMargin + 5
                }
                text: _currentIndex
                color: qgcPal.text
                font.pointSize:     scalingFontSize
            }
        }
        //----------------------------------------------------
        //-- INDICATED CLIMBRATE
        Rectangle{
            id:                 climbRate_info_rectangle
            anchors {
                left:           altitude_info_rectangle.left           
                top:            altitude_info_rectangle.bottom
                topMargin:      _toolsMargin
            }
            color:              qgcPal.windowShadeDark
            height:             scalingFontHeight   
            width:              scalingFontWidth //(Window.width > 1000) ? ScreenTools.defaultFontPixelWidth * 11 : ScreenTools.defaultFontPixelWidth * 6

            QGCLabel{
                id:                     climbRate_info
                anchors {
                    horizontalCenter:   parent.horizontalCenter
                    verticalCenter:     parent.verticalCenter
                    leftMargin:         _toolsMargin + 5
                }
                text: _climbRate_string
                color: qgcPal.text
                font.pointSize:     scalingFontSize
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
            height:                     scalingFontHeight   
            width:                      scalingFontWidth // ScreenTools.defaultFontPixelWidth * 5

            QGCLabel {
                property string _headingString:     vehicle ? vehicle.heading.rawValue.toFixed(0) : "OFF"
                property string _headingString2:    _headingString.length  === 1 ? "0" + _headingString  : _headingString
                property string _headingString3:    _headingString2.length === 2 ? "0" + _headingString2 : _headingString2
                anchors.horizontalCenter:   parent.horizontalCenter
                anchors.verticalCenter:     parent.verticalCenter
                text:                       _headingString3
                color:                      qgcPal.text
                visible:                    showHeading
                // font.pointSize:             ScreenTools.smallFontPointSize
                font.pointSize:     scalingFontSize
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
