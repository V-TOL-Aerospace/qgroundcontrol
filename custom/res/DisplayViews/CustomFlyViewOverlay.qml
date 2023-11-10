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

import QtQuick          2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts  1.11

import QtPositioning            5.3
import QtQuick.Window           2.2

import QGroundControl               1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0

import Custom.Widgets 1.0

Item {
    property bool showIndicator: true
    property var parentToolInsets                       // These insets tell you what screen real estate is available for positioning the controls in your overlay
    property var totalToolInsets:   _totalToolInsets    // The insets updated for the custom overlay additions
    property var mapControl

    readonly property string noGPS:                 qsTr("NO GPS")
    readonly property real   indicatorValueWidth:   ScreenTools.defaultFontPixelWidth * 7

    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property real   _indicatorDiameter:     ScreenTools.defaultFontPixelWidth * 18
    property real   _indicatorsHeight:      ScreenTools.defaultFontPixelHeight
    property var    _sepColor:              qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0,0,0,0.5) : Qt.rgba(1,1,1,0.5)
    property color  _indicatorsColor:       qgcPal.text
    property bool   _isVehicleGps:          _activeVehicle ? _activeVehicle.gps.count.rawValue > 1 && _activeVehicle.gps.hdop.rawValue < 1.4 : false
    property string _altitude:              _activeVehicle ? (isNaN(_activeVehicle.altitudeRelative.value) ? "0.0" : _activeVehicle.altitudeRelative.value.toFixed(1)) + ' ' + _activeVehicle.altitudeRelative.units : "0.0"
    property string _distanceStr:           isNaN(_distance) ? "0" : _distance.toFixed(0) + ' ' + QGroundControl.unitsConversion.appSettingsHorizontalDistanceUnitsString
    property real   _heading:               _activeVehicle   ? _activeVehicle.heading.rawValue : 0
    property real   _distance:              _activeVehicle ? _activeVehicle.distanceToHome.rawValue : 0
    property string _messageTitle:          ""
    property string _messageText:           ""
    property real   _toolsMargin:           ScreenTools.defaultFontPixelWidth * 0.75
    property bool   _test_visible:          true

    property real   scalable_button_height:         Window.height/8 - _toolsMargin
    property real   scalable_warnings_panel_width:  topWarningDisplay.width/7 - _toolsMargin

    property real   _tabWidth:              Window.width * 0.075 // ScreenTools.defaultFontPixelWidth * 12      
    property int    _unhealthySensors:      _activeVehicle ? _activeVehicle.sensorsUnhealthyBits : 1
    property bool   _communicationLost:     _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false

    property string statusNormal:           "Normal" // CustomStatusIndicator.statusNormal 
    property string statusError:            "Error"// CustomStatusIndicator.statusError 
    property string statusDisabled:         "Disabled"// CustomStatusIndicator.statusDisabled 
    
    // property var planController:            _planController
    // property var guidedController:          _guidedController
    // property var _guidedController:         guidedActionsController
    // property var _guidedActionList:         guidedActionList
    // property var _guidedValueSlider:        guidedValueSlider
    // property var _mapControl:               mapControl

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

    QGCToolInsets {
        id:                     _totalToolInsets
        topEdgeCenterInset:     compassArrowIndicator.y + compassArrowIndicator.height
        rightEdgeBottomInset:   parent.width - compassBackground.x
    }

    // TOP RECTANGLE WARNING PANELS AREA
    Rectangle {
        id:     topWarningDisplay_boarder
        anchors {
            top:    parent.top
            left:   flightControlRectangle.right
            right:  rightSideButtonControls_Boarder.left
        }
        color:      qgcPal.windowShadeDark
        height:     parent.height * 0.08
        MouseArea {
            anchors.fill: parent
        }
        Rectangle {
            id:                     topWarningDisplay
            anchors {
                top:                parent.top
                horizontalCenter:   parent.horizontalCenter
            }
            height:                 parent.height - _toolsMargin
            width:                  parent.width - _toolsMargin
            color:                  qgcPal.windowShade
            CustomMavStatusButton {
                id:             warning_panel_0
                anchors {
                    top:        parent.top
                    topMargin:  _toolsMargin
                    left:       parent.left
                    leftMargin: _toolsMargin
                }
                // text:                   qsTr("SENSORS")
                height:                 parent.height * 0.5 - _toolsMargin
                width:                  scalable_warnings_panel_width
                showBorder:             true
                activeVehicle:          _activeVehicle
                statusActivity:         _activeVehicle ? (_activeVehicle.allSensorsHealthy ? statusNormal : statusError ) : statusDisabled
                showOnMouseHighlight:   true
            }
            CustomStatusIndicator {
                id:             warning_panel_1
                anchors {
                    top:        warning_panel_0.bottom
                    topMargin:  _toolsMargin
                    left:       parent.left
                    leftMargin: _toolsMargin
                }
                text:           _activeVehicle ? (_activeVehicle.armed ? qsTr("ARMED") : qsTr("DISARMED")) : qsTr("DISARMED")
                height:         parent.height * 0.5 - _toolsMargin
                width:          scalable_warnings_panel_width
                showBorder:     true
                statusActivity:   _activeVehicle ? (_activeVehicle.armed ? statusNormal : statusError) : statusDisabled
            }

            CustomStatusIndicator {
                id:             warning_panel_2
                anchors {
                    top:        parent.top
                    topMargin:  _toolsMargin
                    left:       warning_panel_0.right
                    leftMargin: _toolsMargin
                }
                text:           _activeVehicle ? _activeVehicle.gps.lock.enumStringValue : qsTr("GPS: N/A")
                height:         parent.height * 0.5 - _toolsMargin
                width:          scalable_warnings_panel_width
                showBorder:     true
                statusActivity: _activeVehicle ? ((_unhealthySensors & Vehicle.SysStatusSensorGPS) ? statusError : statusNormal) : statusDisabled
            }
            CustomStatusIndicator {
                id:             warning_panel_3
                anchors {
                    top:        warning_panel_2.bottom
                    topMargin:  _toolsMargin
                    left:       warning_panel_1.right
                    leftMargin: _toolsMargin
                }
                text:           qsTr("MAG")
                height:         parent.height * 0.5 - _toolsMargin
                width:          scalable_warnings_panel_width
                showBorder:     true
                statusActivity: _activeVehicle ? ((_unhealthySensors & Vehicle.SysStatusSensor3dMag) ? statusError : statusNormal) : statusDisabled
            }

            CustomStatusIndicator {
                id:             warning_panel_4
                anchors {
                    top:        parent.top
                    topMargin:  _toolsMargin
                    left:       warning_panel_2.right
                    leftMargin: _toolsMargin
                }
                text:           qsTr("ACCEL")
                height:         parent.height * 0.5 - _toolsMargin
                width:          scalable_warnings_panel_width
                showBorder:     true
                statusActivity: _activeVehicle ? ((_unhealthySensors & Vehicle.SysStatusSensor3dAccel) ? statusError : statusNormal) : statusDisabled
            }
            CustomStatusIndicator {
                id:             warning_panel_5
                anchors {
                    top:        warning_panel_4.bottom
                    topMargin:  _toolsMargin
                    left:       warning_panel_2.right
                    leftMargin: _toolsMargin
                }
                text:           qsTr("GYRO")
                height:         parent.height * 0.5 - _toolsMargin
                width:          scalable_warnings_panel_width
                showBorder:     true
                statusActivity: _activeVehicle ? ((_unhealthySensors & Vehicle.SysStatusSensor3dGyro) ? statusError : statusNormal) : statusDisabled
            }

            CustomStatusIndicator {
                id:             warning_panel_6
                anchors {
                    top:        parent.top
                    topMargin:  _toolsMargin
                    left:       warning_panel_4.right
                    leftMargin: _toolsMargin
                }
                text:           qsTr("AHRS")
                height:         parent.height * 0.5 - _toolsMargin
                width:          scalable_warnings_panel_width
                showBorder:     true
                statusActivity: _activeVehicle ? ((_unhealthySensors & Vehicle.SysStatusSensorAHRS) ? statusError : statusNormal) : statusDisabled
            }
            CustomStatusIndicator {
                id:             warning_panel_7
                anchors {
                    top:        warning_panel_6.bottom
                    topMargin:  _toolsMargin
                    left:       warning_panel_4.right
                    leftMargin: _toolsMargin
                }
                text:           qsTr(" ")
                height:         parent.height * 0.5 - _toolsMargin
                width:          scalable_warnings_panel_width
                showBorder:     true
                enabled:        false
            }

            CustomStatusIndicator {
                id:             warning_panel_8
                anchors {
                    top:        parent.top
                    topMargin:  _toolsMargin
                    left:       warning_panel_6.right
                    leftMargin: _toolsMargin
                }
                text:           qsTr(" ")
                height:         parent.height * 0.5 - _toolsMargin
                width:          scalable_warnings_panel_width
                showBorder:     true
                enabled:        false
            }
            CustomStatusIndicator {
                id:             warning_panel_9
                anchors {
                    top:        warning_panel_8.bottom
                    topMargin:  _toolsMargin
                    left:       warning_panel_6.right
                    leftMargin: _toolsMargin
                }
                text:           qsTr(" ")
                height:         parent.height * 0.5 - _toolsMargin
                width:          scalable_warnings_panel_width
                showBorder:     true
                enabled:        false
            }

            CustomStatusIndicator {
                id:             warning_panel_10
                anchors {
                    top:        parent.top
                    topMargin:  _toolsMargin
                    left:       warning_panel_8.right
                    leftMargin: _toolsMargin
                }
                text:           qsTr(" ")
                height:         parent.height * 0.5 - _toolsMargin
                width:          scalable_warnings_panel_width
                showBorder:     true
                enabled:        false
            }
            CustomStatusIndicator {
                id:             warning_panel_11
                anchors {
                    top:        warning_panel_10.bottom
                    topMargin:  _toolsMargin
                    left:       warning_panel_8.right
                    leftMargin: _toolsMargin
                }
                text:           qsTr(" ")
                height:         parent.height * 0.5 - _toolsMargin
                width:          scalable_warnings_panel_width
                showBorder:     true
                enabled:        false
            }

            CustomStatusIndicator {
                id:             warning_panel_12
                anchors {
                    top:        parent.top
                    topMargin:  _toolsMargin
                    left:       warning_panel_10.right
                    leftMargin: _toolsMargin
                }
                text:           Window.width
                height:         parent.height * 0.5 - _toolsMargin
                width:          scalable_warnings_panel_width
                showBorder:     true
                enabled:        false
            }
            CustomStatusIndicator {
                id:             warning_panel_13
                anchors {
                    top:        warning_panel_12.bottom
                    topMargin:  _toolsMargin
                    left:       warning_panel_10.right
                    leftMargin: _toolsMargin
                }
                text:           Window.height
                height:         parent.height * 0.5 - _toolsMargin
                width:          scalable_warnings_panel_width
                showBorder:     true
                enabled:        false
            }
        }
    }

    // RIGHT SIDE BUTTON CONTROLS
    Rectangle {
        id:                     rightSideButtonControls_Boarder
        anchors {
            topMargin:      _toolsMargin
            right:          parent.right
        }
        height:             Screen.height
        width:              _tabWidth +  _toolsMargin
        color:              qgcPal.windowShadeDark
        visible:            _test_visible
        MouseArea {
            anchors.fill:   parent
        }
        Rectangle {
            id:                     rightSideButtonControls
            anchors {
                right:              parent.right
            }
            height:                 parent.height
            width:                  _tabWidth 
            color:                  qgcPal.windowShade
            visible:                _test_visible
            CustomStatusIndicator {
                id:             right_button_0
                height:         scalable_button_height 
                width:          parent.width
                showBorder:     true
                anchors {
                    top:        parent.top
                    topMargin:  _toolsMargin
                }
                text:           _activeVehicle ? qsTr("CONN"):qsTr("DISCONN")
                iconSource:     _activeVehicle ? "/qmlimages/Connect.svg" : "/qmlimages/Disconnect.svg"
                // onClicked:      _activeVehicle.closeVehicle()
                // enabled:        false
                statusActivity:   _activeVehicle ? "Normal" : "Disabled"
            }
            CustomIconButton {
                id:             right_button_1
                height:         scalable_button_height 
                width:          parent.width
                showBorder:     true
                anchors {
                    top:        right_button_0.bottom
                    topMargin:  _toolsMargin
                }
                text:           _activeVehicle ? (_activeVehicle.armed ? qsTr("ARMED") : qsTr("DISARMED")) : qsTr("DISARMED")
                iconSource:     _activeVehicle ? (_activeVehicle.armed ? "/qmlimages/Armed.svg" : "/qmlimages/Disarmed.svg") : "/qmlimages/Disarmed.svg"
                onClicked:      _activeVehicle.armed ? _guidedController.confirmAction(_guidedController.actionDisarm, 1) : _guidedController.confirmAction(_guidedController.actionArm, 1) //_activeVehicle.armed ? _activeVehicle.armed = false : _activeVehicle.armed = true
                enabled:        _activeVehicle
                grayscale:      false
            }
            CustomFlightModeButton {
                id:             right_button_2
                height:         scalable_button_height 
                width:          parent.width
                showBorder:     true
                anchors {
                    top:        right_button_1.bottom
                    topMargin:  _toolsMargin
                }
                text:           qsTr(" ")
                enabled:        _activeVehicle
                activeVehicle: _activeVehicle
            }
            CustomIconButton {
                id:             right_button_3
                height:         scalable_button_height 
                width:          parent.width
                showBorder:     true
                anchors {
                    top:        right_button_2.bottom
                    topMargin:  _toolsMargin
                }
                text:           qsTr("Set Takeoff")
                iconSource:     "/res/takeoff.svg"
                enabled:        _activeVehicle ? (_activeVehicle.armed ? false:true): false
                onClicked:      _guidedController.confirmAction(_guidedController.actionSetWaypoint, 1)
            }
            CustomIconButton {
                id:             right_button_4
                height:         scalable_button_height 
                width:          parent.width
                showBorder:     true
                anchors {
                    top:        right_button_3.bottom
                    topMargin:  _toolsMargin
                }
                text:           qsTr("RTL")
                iconSource:     "/res/rtl.svg"
                enabled:        _activeVehicle ? (_activeVehicle.armed ? true:false): false
                onClicked:      _guidedController.confirmAction(_guidedController.actionRTL, 1)
            }
            CustomIconButton {
                id:             right_button_5
                height:         scalable_button_height 
                width:          parent.width
                showBorder:     true
                anchors { 
                    top:        right_button_4.bottom
                    topMargin:  _toolsMargin
                }
                text:           qsTr(" ")
                enabled:        false //_activeVehicle
            }
            CustomIconButton {
                id:             right_button_6
                height:         scalable_button_height 
                width:          parent.width
                showBorder:     true
                anchors {
                    top:        right_button_5.bottom
                    topMargin:  _toolsMargin
                }
                text:           qsTr(" ")
                enabled:        false //_activeVehicle
            }
            CustomIconButton {
                id:             right_button_7
                height:         scalable_button_height 
                width:          parent.width
                showBorder:     true
                anchors {
                    top:            right_button_6.bottom
                    topMargin:      _toolsMargin
                    bottomMargin:   _toolsMargin
                }
                text:           qsTr(" ")
                enabled:        false //_activeVehicle
            }
        }
    }

    // LEFT SIDE BUTTON CONTROLS
    Rectangle {
        id:                     leftSideButtonControls_Boarder
        anchors {
            topMargin:          _toolsMargin
            left:               parent.left
        }
        height:                 parent.height
        width:                  _tabWidth +  _toolsMargin
        color:                  qgcPal.windowShadeDark
        visible:                true
        MouseArea {
            anchors.fill: parent
        }
        Rectangle {
            id:                 leftSideButtonControls
            anchors {
                left:           parent.left
            }
            height:             parent.height
            width:              _tabWidth 
            color:              qgcPal.windowShade
            visible:            _test_visible
            CustomIconButton {
                id:             button_0
                onClicked:      mainWindow.showPlanView()
                height:         scalable_button_height 
                width:          parent.width
                showBorder:     true
                anchors {
                    top:        parent.top
                    topMargin:  _toolsMargin
                }
                text:           qsTr("Plan")
                iconSource:     "/qmlimages/Plan.svg"
            }
            CustomIconButton {
                id:             button_1
                text:           qsTr("Fly View")
                height:         scalable_button_height 
                width:          parent.width
                showBorder:     true
                anchors {
                    top:        button_0.bottom
                    topMargin:  _toolsMargin
                }
                enabled: false
            }
            CustomIconButton {
                id:             button_2
                height:         scalable_button_height 
                width:          parent.width
                showBorder:     true
                anchors {
                    top:        button_1.bottom
                    topMargin:  _toolsMargin
                }
                text:           qsTr("")
                enabled:        false
            }
            CustomIconButton {
                id:             button_3
                height:         scalable_button_height 
                width:          parent.width
                showBorder:     true
                anchors {
                    top:        button_2.bottom
                    topMargin:  _toolsMargin
                }
                text:           qsTr("")
                enabled:        false
            }
            CustomIconButton {
                id:             button_4
                height:         scalable_button_height 
                width:          parent.width
                showBorder:     true
                anchors {
                    top:        button_3.bottom
                    topMargin:  _toolsMargin
                }
                text:           qsTr("")
                enabled:        false
            }
            CustomIconButton {
                id:             button_5
                height:         scalable_button_height 
                width:          parent.width
                showBorder:     true
                anchors {
                    top:        button_4.bottom
                    topMargin:  _toolsMargin
                }
                text:           qsTr("")
                enabled:        false
            }
            CustomIconButton {
                id:             button_6
                height:         scalable_button_height 
                width:          parent.width
                showBorder:     true
                anchors {
                    top:    button_5.bottom
                    topMargin: _toolsMargin
                }
                
                text:           qsTr("Vehicle")
                iconSource:     "/qmlimages/Gears.svg"
                onClicked: {
                    if (!mainWindow.preventViewSwitch()) {
                        mainWindow.showSetupTool()
                    }
                }
            }
            CustomIconButton {
                id:             button_7
                height:         scalable_button_height 
                width:          parent.width
                showBorder:     true
                anchors {
                    top:    button_6.bottom
                    topMargin: _toolsMargin
                    bottomMargin: _toolsMargin
                }

                text:           qsTr("App")
                iconSource:     "/res/gear-white.svg"
                onClicked: {
                    if (!mainWindow.preventViewSwitch()) {
                        mainWindow.showSettingsTool()
                    }
                }     //mainWindow.showToolSelectDialog()
            }
        }
    }

    // FLIGHT CONTROL AREA - PFD AND OTHER FLIGHT CRITICAL INFORMATION ARE ANCHORED TO THIS RECTANGLE
    Rectangle {
        id:                     flightControlRectangle
        anchors {
            topMargin: _toolsMargin
            left:      leftSideButtonControls_Boarder.right
        }
        height:                 Window.height
        width:                  Window.width * 0.2
        color:                  qgcPal.windowShade
        visible:                _test_visible
        MouseArea {
            anchors.fill: parent
        }
    }

    //-------------------------------------------------------------------------
    // HEADING INTDICATOR 1 - HORIZONTAL HEADING TAPE
    Rectangle {
        id:                         compassBar
        height:                     ScreenTools.defaultFontPixelHeight * 1.5
        width:                      flightControlRectangle.width - _toolsMargin * 2// ScreenTools.defaultFontPixelWidth  * 50
        color:                      "#DEDEDE"
        radius:                     2
        clip:                       true
        anchors.top:                flightControlRectangle.top
        anchors.topMargin:          _toolsMargin //-headingIndicator.height / 2
        // anchors.left:               flightControlRectangle.right
        anchors.horizontalCenter:   flightControlRectangle.horizontalCenter
        Repeater {
            model: 720
            QGCLabel {
                function _normalize(degrees) {
                    var a = degrees % 360
                    if (a < 0) a += 360
                    return a
                }
                property int _startAngle: modelData + 180 + _heading
                property int _angle: _normalize(_startAngle)
                anchors.verticalCenter: parent.verticalCenter
                x:              visible ? ((modelData * (compassBar.width / 360)) - (width * 0.5)) : 0
                visible:        _angle % 45 == 0
                color:          "#75505565"
                font.pointSize: ScreenTools.smallFontPointSize
                text: {
                    switch(_angle) {
                    case 0:     return "N"
                    case 45:    return "NE"
                    case 90:    return "E"
                    case 135:   return "SE"
                    case 180:   return "S"
                    case 225:   return "SW"
                    case 270:   return "W"
                    case 315:   return "NW"
                    }
                    return ""
                }
            }
        }
        Rectangle {
            id:                         headingIndicator
            height:                     ScreenTools.defaultFontPixelHeight
            width:                      ScreenTools.defaultFontPixelWidth * 4
            color:                      qgcPal.windowShadeDark
            anchors.bottom:             compassBar.top
            // anchors.topMargin:          _toolsMargin
            anchors.horizontalCenter:   compassBar.horizontalCenter
            QGCLabel {
                text:                   _heading
                color:                  qgcPal.text
                font.pointSize:         ScreenTools.smallFontPointSize
                anchors.centerIn:       parent
            }
        }
        Image {
            id:                         compassArrowIndicator
            height:                     _indicatorsHeight
            width:                      height
            source:                     "/custom/img/compass_pointer.svg"
            fillMode:                   Image.PreserveAspectFit
            sourceSize.height:          height
            anchors.top:                compassBar.bottom
            anchors.topMargin:          -height / 2
            anchors.horizontalCenter:   compassBar.horizontalCenter
        }
    }
        
    // MAIN FLIGHT ATTITUDE INDICATOR
    Rectangle {
        id:                     attitudeIndicator
        anchors.top:            compassBar.bottom
        anchors.rightMargin:    _toolsMargin
        anchors.leftMargin:     _toolsMargin
        // anchors.bottom:         parent.bottom
        anchors.horizontalCenter:          flightControlRectangle.horizontalCenter
        width:                 flightControlRectangle.width // ScreenTools.defaultFontPixelHeight * 6
        height:                width *0.65
        // radius:              height * 0.5
        color:                  qgcPal.windowShade
        visible:                _test_visible

        CustomAttitudeWidget {
            // size:               parent.height * 0.95
            size_width:              parent.width
            size_height:             parent.height
            vehicle:            _activeVehicle
            showHeading:        true
            anchors.centerIn:   parent
        }
    }

    // HEADING INDICATOR 2 - RADIAL HEADING INDICATOR (VISIBILITY HAS BEEN SET TO FALSE)
    Rectangle {
        id:                     compassBackground
        anchors.top:            attitudeIndicator.bottom
        anchors.topMargin:      _toolsMargin //-attitudeIndicator.width / 2
        anchors.horizontalCenter:          flightControlRectangle.horizontalCenter
        width:                  flightControlRectangle.width //-anchors.rightMargin + compassBezel.width + (_toolsMargin * 2)
        height:                 attitudeIndicator.height
        radius:                 2
        color:                  qgcPal.windowShade //qgcPal.window
        visible: false

        Rectangle {
            id:                     compassBezel
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin:     _toolsMargin
            anchors.left:           parent.left
            width:                  height
            height:                 parent.height - (northLabelBackground.height / 2) - (headingLabelBackground.height / 2)
            radius:                 height / 2
            border.color:           qgcPal.text
            border.width:           1
            color:                  Qt.rgba(0,0,0,0)
        }

        Rectangle {
            id:                         northLabelBackground
            anchors.top:                compassBezel.top
            anchors.topMargin:          -height / 2
            anchors.horizontalCenter:   compassBezel.horizontalCenter
            width:                      northLabel.contentWidth * 1.5
            height:                     northLabel.contentHeight * 1.5
            radius:                     ScreenTools.defaultFontPixelWidth  * 0.25
            color:                      qgcPal.windowShade

            QGCLabel {
                id:                 northLabel
                anchors.centerIn:   parent
                text:               "N"
                color:              qgcPal.text
                font.pointSize:     ScreenTools.smallFontPointSize
            }
        }

        Image {
            id:                 headingNeedle
            anchors.centerIn:   compassBezel
            height:             compassBezel.height * 0.75
            width:              height
            source:             "/custom/img/compass_needle.svg"
            fillMode:           Image.PreserveAspectFit
            sourceSize.height:  height
            transform: [
                Rotation {
                    origin.x:   headingNeedle.width  / 2
                    origin.y:   headingNeedle.height / 2
                    angle:      _heading
                }]
        }

        Rectangle {
            id:                         headingLabelBackground
            anchors.top:                compassBezel.bottom
            anchors.topMargin:          -height / 2
            anchors.horizontalCenter:   compassBezel.horizontalCenter
            width:                      headingLabel.contentWidth * 1.5
            height:                     headingLabel.contentHeight * 1.5
            radius:                     ScreenTools.defaultFontPixelWidth  * 0.25
            color:                      qgcPal.windowShade

            QGCLabel {
                id:                 headingLabel
                anchors.centerIn:   parent
                text:               _heading
                color:              qgcPal.text
                font.pointSize:     ScreenTools.smallFontPointSize
            }
        }
    }

    // GPS STATUS INDICATOR
    Rectangle {
        //copied from GPSIndicator.qml
        id: gps_info_window
        anchors.horizontalCenter: flightControlRectangle.horizontalCenter
        anchors.top: compassBackground.visible ? compassBackground.bottom:attitudeIndicator.bottom
        width:  flightControlRectangle.width
        height: width * 0.35//gpsCol.height  + ScreenTools.defaultFontPixelHeight * 2
        radius: ScreenTools.defaultFontPixelHeight * 0.5
        color:  qgcPal.window
        border.color:   qgcPal.text

        Column {
            id:                 gpsCol
            spacing:            ScreenTools.defaultFontPixelHeight * 0.5
            width:              parent.width // Math.max(gpsGrid.width, gpsLabel.width)
            anchors.margins:    ScreenTools.defaultFontPixelHeight
            anchors.centerIn:   parent

            QGCLabel {
                id:             gpsLabel
                text:           (_activeVehicle && _activeVehicle.gps.count.value >= 0) ? qsTr("GPS Status") : qsTr("GPS Data Unavailable")
                font.family:    ScreenTools.demiboldFontFamily
                anchors.horizontalCenter: parent.horizontalCenter
            }

            GridLayout {
                id:                 gpsGrid
                visible:            (_activeVehicle && _activeVehicle.gps.count.value >= 0)
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                columnSpacing:      ScreenTools.defaultFontPixelWidth
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 2

                QGCLabel { text: qsTr("GPS Count:") }
                QGCLabel { text: _activeVehicle ? _activeVehicle.gps.count.valueString : qsTr("N/A", "No data to display") }
                QGCLabel { text: qsTr("GPS Lock:") }
                QGCLabel { text: _activeVehicle ? _activeVehicle.gps.lock.enumStringValue : qsTr("N/A", "No data to display") }
                QGCLabel { text: qsTr("HDOP:") }
                QGCLabel { text: _activeVehicle ? _activeVehicle.gps.hdop.valueString : qsTr("--.--", "No data to display") }
                QGCLabel { text: qsTr("VDOP:") }
                QGCLabel { text: _activeVehicle ? _activeVehicle.gps.vdop.valueString : qsTr("--.--", "No data to display") }
                //QGCLabel { text: qsTr("Course Over Ground:") }
                //QGCLabel { text: _activeVehicle ? _activeVehicle.gps.courseOverGround.valueString : qsTr("--.--", "No data to display") }
            }
        }
    }
    CustomMavMessageWidget {
        id:             messageWindow
        width:          flightControlRectangle.width
        height:         width
        anchors {
            top:                gps_info_window.bottom
            horizontalCenter:   flightControlRectangle.horizontalCenter
        }
        _activeVehicle: _activeVehicle
    }
}
