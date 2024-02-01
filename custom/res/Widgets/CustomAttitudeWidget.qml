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
    property real _climbRate:           vehicle ? ((vehicle.climbRate.rawValue < 0.1 && vehicle.climbRate.rawValue > -0.1) ? 0 : vehicle.climbRate.rawValue) : 0

    property string _altitudeRelative_with_unit:    vehicle ? _altitudeRelative.toFixed(0) + ' ' + QGroundControl.unitsConversion.appSettingsVerticalDistanceUnitsString : "0 " + QGroundControl.unitsConversion.appSettingsVerticalDistanceUnitsString
    property string _airspeed_string_with_unit:     vehicle ? _airSpeed.toFixed(0) + ' ' + QGroundControl.unitsConversion.appSettingsSpeedUnitsString : "0 " + QGroundControl.unitsConversion.appSettingsSpeedUnitsString
    property string _climbRate_string_with_unit:    vehicle ? _climbRate.toFixed(1) + ' ' + QGroundControl.unitsConversion.appSettingsSpeedUnitsString : "0 " + QGroundControl.unitsConversion.appSettingsSpeedUnitsString

    property string _altitudeRelative_string:       isPFDSize400 ? qsTr("ALT: ")    + _altitudeRelative_with_unit   : _altitudeRelative_with_unit
    property string _airSpeed_string:               isPFDSize400 ? qsTr("AS: ")     + _airspeed_string_with_unit    : _airspeed_string_with_unit
    property string _climbRate_string:              isPFDSize400 ? qsTr("VS: ")     + _climbRate_string_with_unit   : _climbRate_string_with_unit

    property var    _flightTime:        vehicle ?  vehicle.flightTime.rawValue : 0
    property string _flightTimeStr:     secondsToHHMMSS(_flightTime)

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

    width:  size_width
    height: size_height

    property bool isPFDSize400:     root.width > 400
    property var dynamicFontSize:   isPFDSize400 ? ScreenTools.defaultFontPointSize     * 1.5   : ScreenTools.defaultFontPointSize // TODO: IF STATEMENT FOR IF root.size is of certain size
    property var dynamicFontWidth:  isPFDSize400 ? ScreenTools.defaultFontPixelWidth    * 15    : ScreenTools.defaultFontPixelWidth * 6
    property var dynamicFontHeight: isPFDSize400 ? ScreenTools.defaultFontPixelHeight   * 1.5   : ScreenTools.defaultFontPixelHeight

    property var scalingFontSize:   isPFDSize400 ? ScreenTools.defaultFontPointSize    * width * 0.00375    : ScreenTools.defaultFontPointSize
    property var scalingFontWidth:  isPFDSize400 ? ScreenTools.defaultFontPixelWidth   * width * 0.035      : ScreenTools.defaultFontPixelWidth * 6
    property var scalingFontHeight: isPFDSize400 ? ScreenTools.defaultFontPixelHeight  * width * 0.00375    : ScreenTools.defaultFontPixelHeight

    property var _borderColor:          qgcPal.text
    property var _borderWidth:          isPFDSize400 ? ScreenTools.defaultFontPointSize    * width * 0.000375    : 0.5
    property var _labelBackgroundColor: qgcPal.toolbarBackground

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
            source:             "/custom/img/attitude_crosshair_v3.svg"
            mipmap:             true
            width:              size * 0.75
            sourceSize.width:   width
            fillMode:           Image.PreserveAspectFit
            anchors.centerIn:   parent
        }
        
        //-- LABEL INDICATORS - FOR DEBUGGING ONLY
        Rectangle {
            id:                         devRootSizeDisplay // For dev reference and debugging of attitude window size. 
            anchors {
                top:                    parent.top
                horizontalCenter:       parent.horizontalCenter
                topMargin:              _toolsMargin
            }
            color:                      _labelBackgroundColor
            height:                     scalingFontHeight   
            width:                      scalingFontWidth
            visible:                    false
            border.color:               _borderColor
            border.width:               _borderWidth

            QGCLabel {
                id:                     devRootSizeDisplayLabel
                anchors {
                    horizontalCenter:   parent.horizontalCenter
                    verticalCenter:     parent.verticalCenter
                    leftMargin:         _toolsMargin + 5
                }
                text:                   root.width + qsTr(" >> ") + (root.width * 0.01)
                color:                  qgcPal.text
                font.pointSize:         scalingFontSize
                visible:                false
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
            color:              _labelBackgroundColor
            height:             scalingFontHeight   
            width:              scalingFontWidth //(Window.width > 1000) ? ScreenTools.defaultFontPixelWidth * 11 : ScreenTools.defaultFontPixelWidth * 6
            border.color:       _borderColor
            border.width:       _borderWidth

            QGCLabel {
                id:                     altitude_info
                anchors {
                    horizontalCenter:   parent.horizontalCenter
                    verticalCenter:     parent.verticalCenter
                    leftMargin:         _toolsMargin + 5
                }
                text:                   _altitudeRelative_string
                color:                  qgcPal.text
                font.pointSize:         scalingFontSize
            }
        }        
        //----------------------------------------------------
        //-- INDICATED CLIMBRATE (VERTICAL SPEED)
        Rectangle {
            id:                         climbRate_info_rectangle
            anchors {
                left:                   altitude_info_rectangle.left
                top:                    parent.top
                topMargin:              _toolsMargin
            }
            color:                      _labelBackgroundColor
            height:                     scalingFontHeight   
            width:                      scalingFontWidth //(Window.width > 1000) ? ScreenTools.defaultFontPixelWidth * 11 : ScreenTools.defaultFontPixelWidth * 6
            border.color:               _borderColor
            border.width:               _borderWidth

            QGCLabel {
                id:                     climbRate_info
                anchors {
                    horizontalCenter:   parent.horizontalCenter
                    verticalCenter:     parent.verticalCenter
                    leftMargin:         _toolsMargin + 5
                }
                text:                   _climbRate_string
                color:                  qgcPal.text
                font.pointSize:         scalingFontSize
            }
        }
        //----------------------------------------------------
        // -- ALTITUDE CLIMBRATE LADDER/BAR
        Rectangle {
            id:                         climbRate_info_ladder
            readonly property bool      isPositiveClimb: (_climbRate > 0 )
            anchors {
                top:                    isPositiveClimb ? undefined : altitude_info_rectangle.bottom
                bottom:                 isPositiveClimb ? altitude_info_rectangle.top : undefined
                right:                  climbRate_info_ladder_boundary.right
                topMargin:              -border.width
                bottomMargin:           -border.width
            }
            width:                      altitude_info_rectangle.width * 0.2
            height:                     isPositiveClimb ? 
                (climbRate_info_ladder_boundary.height * 0.5 - altitude_info_rectangle.height * 0.5) * (_climbRate / 5) :
                (climbRate_info_ladder_boundary.height * 0.5 - altitude_info_rectangle.height * 0.5) * -(_climbRate / 5) 
            color:                      qgcPal.toolbarBackground 
            border.color:               qgcPal.text
            border.width:               _borderWidth
            states: [
                State {
                            name: "CriticalPositive"; when: _climbRate > 5
                            PropertyChanges {target: climbRate_info_ladder; color: qgcPal.colorRed} 
                },
                State {
                            name: "CriticalNegative"; when: _climbRate < -5
                            PropertyChanges {target: climbRate_info_ladder; color: qgcPal.colorRed} 
                },
                State {
                            name: "HighPositive"; when: _climbRate > 2.5
                            PropertyChanges {target: climbRate_info_ladder; color: qgcPal.colorOrange} 
                },
                State {
                            name: "HighNegative"; when: _climbRate < -2.5
                            PropertyChanges {target: climbRate_info_ladder; color: qgcPal.colorOrange} 
                },
                State {
                            name: "Normal"; when: _climbRate > -2.5
                            PropertyChanges {target: climbRate_info_ladder; color: "#1b14e0"} 
                }
            ]
        }
        Rectangle {
            id:                 climbRate_info_ladder_boundary
            anchors {
                right:          altitude_info_rectangle.right
                verticalCenter: instrument.verticalCenter
            }
            width:              _borderWidth < 1 ? 1 : _borderWidth
            height:             flightMode_info_rectangle.y - flightMode_info_rectangle.height * 2
            color:              qgcPal.text
            Rectangle {
                anchors {
                    right:       parent.right
                    bottom:     parent.bottom
                }
                width:          climbRate_info_ladder.width
                height:         _borderWidth < 1 ? 1 : _borderWidth
                color:          qgcPal.text
            }
            Rectangle {
                anchors {
                    right:           parent.right
                    top:            parent.top
                    topMargin:      (parent.height * 0.5 - altitude_info_rectangle.height * 0.5) * 0.5
                }
                width:          climbRate_info_ladder.width * 0.5
                height:         _borderWidth < 1 ? 1 : _borderWidth
                color:          qgcPal.text
            }
            Rectangle {
                anchors {
                    right:       parent.right
                    bottom:     parent.top
                }
                width:          climbRate_info_ladder.width 
                height:         _borderWidth < 1 ? 1 : _borderWidth
                color:          qgcPal.text
            }
            Rectangle {
                anchors {
                    right:               parent.right
                    bottom:             parent.bottom
                    bottomMargin:       (parent.height * 0.5 - altitude_info_rectangle.height * 0.5) * 0.5
                }
                width:          climbRate_info_ladder.width * 0.5
                height:         _borderWidth < 1 ? 1 : _borderWidth
                color:          qgcPal.text
            }
        }

        //----------------------------------------------------
        //-- INDICATED AIR SPEED
        Rectangle {
            id:                         airspeed_info_rectangle
            anchors {
                verticalCenter:         parent.verticalCenter
                left:                   parent.left
                leftMargin:             _toolsMargin + instrument.width * 0.05
            }
            color:                      _labelBackgroundColor
            height:                     scalingFontHeight   
            width:                      scalingFontWidth  // (Window.width > 1000) ? ScreenTools.defaultFontPixelWidth * 11 : ScreenTools.defaultFontPixelWidth * 6
            border.color:               _borderColor
            border.width:               _borderWidth

            QGCLabel {
                id:                     airspeed_info
                anchors {
                    horizontalCenter:   parent.horizontalCenter
                    verticalCenter:     parent.verticalCenter
                    leftMargin:         _toolsMargin + 5
                }
                text:                   _airSpeed_string
                color:                  qgcPal.text
                font.pointSize:         scalingFontSize
            }
        }
        //----------------------------------------------------
        //-- INDICATED FLIGHT MODE SELECTED
        Rectangle {
            id:                         flightMode_info_rectangle
            anchors {
                right:                  altitude_info_rectangle.right
                top:                    heading_info_rectangle.top
            }
            color:                      _labelBackgroundColor
            height:                     scalingFontHeight   
            width:                      scalingFontWidth //(Window.width > 1000) ? ScreenTools.defaultFontPixelWidth * 11 : ScreenTools.defaultFontPixelWidth * 6
            border.color:               _borderColor
            border.width:               _borderWidth

            QGCLabel {
                id:                     flightMode_info
                anchors {
                    horizontalCenter:   parent.horizontalCenter
                    verticalCenter:     parent.verticalCenter
                    leftMargin:         _toolsMargin + 5
                }
                text: _flightMode
                color: qgcPal.text
                font.pointSize:         scalingFontSize
            }
        }
        //----------------------------------------------------
        //-- CURRENT WAYPOINT
        Rectangle {
            id:                         currentWaypoint_info_rectangle
            anchors {
                left:                   airspeed_info_rectangle.left
                top:                    heading_info_rectangle.top
            }
            color:                      _labelBackgroundColor
            height:                     scalingFontHeight   
            width:                      scalingFontWidth
            border.color:               _borderColor
            border.width:               _borderWidth

            QGCLabel {
                id:                     currentWaypoint_info
                anchors {
                    horizontalCenter:   parent.horizontalCenter
                    verticalCenter:     parent.verticalCenter
                    leftMargin:         _toolsMargin + 5
                }
                text:                   _currentIndex
                color:                  qgcPal.text
                font.pointSize:         scalingFontSize
            }
        }
        //----------------------------------------------------
        //-- INDICATED HEADING
        Rectangle {
            id:                         heading_info_rectangle
            anchors.bottom:             parent.bottom
            anchors.bottomMargin:       _toolsMargin
            anchors.horizontalCenter:   parent.horizontalCenter
            color:                      _labelBackgroundColor
            height:                     scalingFontHeight   
            width:                      scalingFontWidth // ScreenTools.defaultFontPixelWidth * 5
            border.color:               _borderColor
            border.width:               _borderWidth

            QGCLabel {
                property int    _heading:           vehicle ? vehicle.heading.rawValue : 0
                property string _headingString:     vehicle ? vehicle.heading.rawValue.toFixed(0) : "000"
                property string _headingString2:    _headingString.length  === 1 ? "0" + _headingString  : _headingString
                property string _headingString3:    _headingString2.length === 2 ? "0" + _headingString2 : _headingString2

                property string _compassHeadingString: {
                    if (_heading >= 337.5 || _heading <= 22.5) {
                        return "N"
                    }
                    else if (_heading >= 22.5 && _heading <= 67.5) {
                        return "NE"
                    }
                    else if (_heading >= 67.5 && _heading <= 112.5) {
                        return "E"
                    }
                    else if (_heading >= 112.5 && _heading <= 157.5) {
                        return "SE"
                    }
                    else if (_heading >= 157.5 && _heading <= 202.5) {
                        return "S"
                    }
                    else if (_heading >= 202.5 && _heading <= 247.5) {
                        return "SW"
                    }
                    else if (_heading >= 247.5 && _heading <= 292.5) {
                        return "W"
                    }
                    else if (_heading >= 292.5 && _heading <= 337.5) {
                        return "NW"
                    }
                    return ""
                }

                anchors.horizontalCenter:   parent.horizontalCenter
                anchors.verticalCenter:     parent.verticalCenter
                text:                       vehicle ? _headingString3 + " " + _compassHeadingString : "000 N"
                color:                      qgcPal.text
                visible:                    showHeading
                // font.pointSize:             ScreenTools.smallFontPointSize
                font.pointSize:             scalingFontSize
            }
        }
        //----------------------------------------------------
        //-- INDICATED ELAPSED TIME
        Rectangle {
            id:                         flightTime_info_rectangle
            anchors.bottom:             airspeed_info_rectangle.top
            anchors.bottomMargin:       _toolsMargin
            anchors.horizontalCenter:   airspeed_info_rectangle.horizontalCenter
            color:                      _labelBackgroundColor
            height:                     scalingFontHeight   
            width:                      scalingFontWidth // ScreenTools.defaultFontPixelWidth * 5
            border.color:               _borderColor
            border.width:               _borderWidth
            visible:                    false

            QGCLabel {
                anchors.horizontalCenter:   parent.horizontalCenter
                anchors.verticalCenter:     parent.verticalCenter
                text:                       _flightTimeStr
                color:                      qgcPal.text
                font.pointSize:             scalingFontSize
            }
        }
        QGCLabel {
            anchors.bottom:             currentWaypoint_info_rectangle.top
            anchors.bottomMargin:       _toolsMargin
            anchors.left:               currentWaypoint_info_rectangle.left
            text:                       qsTr("Δt: ") + _flightTimeStr
            color:                      qgcPal.text
            font.pointSize:             scalingFontSize
        }
        //----------------------------------------------------
        //-- INDICATED FLIGHT DISTANCE
        Rectangle {
            id:                         flightDistance_info_rectangle
            anchors.bottom:             currentWaypoint_info_rectangle.top
            anchors.bottomMargin:       _toolsMargin
            anchors.horizontalCenter:   currentWaypoint_info_rectangle.horizontalCenter
            color:                      _labelBackgroundColor
            height:                     scalingFontHeight   
            width:                      scalingFontWidth // ScreenTools.defaultFontPixelWidth * 5
            border.color:               _borderColor
            border.width:               _borderWidth
            visible:                    false

            QGCLabel {
                anchors.horizontalCenter:   parent.horizontalCenter
                anchors.verticalCenter:     parent.verticalCenter
                text:                       vehicle ? vehicle.flightDistance.rawValue.toFixed(0) + " " + QGroundControl.unitsConversion.appSettingsVerticalDistanceUnitsString : "0" + " " + QGroundControl.unitsConversion.appSettingsVerticalDistanceUnitsString
                color:                      qgcPal.text
                font.pointSize:             scalingFontSize
            }
        }
        //----------------------------------------------------
        //-- INDICATED DISTANCE FROM HOME
        Rectangle {
            id:                         distanceToHome_info_rectangle
            anchors.bottom:             flightMode_info_rectangle.bottom
            anchors.bottomMargin:       _toolsMargin
            anchors.horizontalCenter:   flightMode_info_rectangle.horizontalCenter
            color:                      _labelBackgroundColor
            height:                     scalingFontHeight   
            width:                      scalingFontWidth // ScreenTools.defaultFontPixelWidth * 5
            border.color:               _borderColor
            border.width:               _borderWidth
            visible:                    false

            QGCLabel {
                anchors.horizontalCenter:   parent.horizontalCenter
                anchors.verticalCenter:     parent.verticalCenter
                text:                       vehicle ? vehicle.distanceToHome.rawValue.toFixed(0) + " " + QGroundControl.unitsConversion.appSettingsVerticalDistanceUnitsString : "0" + " " + QGroundControl.unitsConversion.appSettingsVerticalDistanceUnitsString
                color:                      qgcPal.text
                font.pointSize:             scalingFontSize
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
