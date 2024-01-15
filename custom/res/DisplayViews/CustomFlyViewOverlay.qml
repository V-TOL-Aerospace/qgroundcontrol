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

    property real   _tabWidth:              (Window.width < 1000) ? (Window.width * 0.05) : (Window.width * 0.04)// ScreenTools.defaultFontPixelWidth * 12      
    property int    _unhealthySensors:      _activeVehicle ? _activeVehicle.sensorsUnhealthyBits : 1
    property bool   _communicationLost:     _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false

    property string statusNormal:           "Normal" // CustomMavStatusIndicator.statusNormal 
    property string statusError:            "Error"// CustomMavStatusIndicator.statusError 
    property string statusDisabled:         "Disabled"// CustomMavStatusIndicator.statusDisabled 

    property string statusHealthyColorHEX:  "#1b8539"
    property string statusWarningColorHEX:  "#a88714"
    property string statusCriticalColorHEX: "#c33838"
    
    // property var planController:            _planController
    // property var guidedController:          _guidedController
    // property var _guidedController:         guidedActionsController
    // property var _guidedActionList:         guidedActionList
    // property var _guidedValueSlider:        guidedValueSlider
    // property var _mapControl:               mapControl

    readonly property int dropLeft:     1
    readonly property int dropRight:    2
    readonly property int dropUp:       3
    readonly property int dropDown:     4

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

    // TOP RECTANGLE WARNING PANELS AREA (OLD)
    Rectangle {
        id:         topWarningDisplay_boarder
        visible:    false
        anchors {
            top:    parent.top
            left:   attitudeIndicator.right // flightControlRectangle.right
            right:  rightSide_toolStrip.left // rightSideButtonControls_Boarder.left
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
                right:              parent.right
            }
            height:                 parent.height - _toolsMargin
            width:                  parent.width - _toolsMargin
            color:                  qgcPal.windowShade
            CustomMavStatusButton {
                id:             warning_panel_0
                enabled:        _activeVehicle
                anchors {
                    top:        parent.top
                    topMargin:  _toolsMargin
                    left:       parent.left
                    leftMargin: _toolsMargin
                }
                // text:                   qsTr("SENSORS")
                height:                 parent.height - _toolsMargin
                width:                  scalable_warnings_panel_width
                showBorder:             true
                activeVehicle:          _activeVehicle
                statusActivity:         _activeVehicle ? (_activeVehicle.allSensorsHealthy ? statusNormal : statusError ) : statusDisabled
                showOnMouseHighlight:   true
            }
            // CustomMavStatusIndicator {
            //     id:             warning_panel_1
            //     anchors {
            //         top:        warning_panel_0.bottom
            //         topMargin:  _toolsMargin
            //         left:       parent.left
            //         leftMargin: _toolsMargin
            //     }
            //     text:           _activeVehicle ? (_activeVehicle.armed ? qsTr("ARMED") : qsTr("DISARMED")) : qsTr("DISARMED")
            //     height:         parent.height - _toolsMargin
            //     width:          scalable_warnings_panel_width
            //     showBorder:     true
            //     statusActivity: _activeVehicle ? (_activeVehicle.armed ? statusNormal : statusError) : statusDisabled
            //     visible:        false
            // }

            CustomMavStatusGPSButton {
                id:                 warning_panel_2
                enabled:            _activeVehicle
                anchors {
                    top:            parent.top
                    topMargin:      _toolsMargin
                    left:           warning_panel_0.right
                    leftMargin:     _toolsMargin
                }
                // text:                   _activeVehicle ? _activeVehicle.gps.lock.enumStringValue : qsTr("GPS: N/A")
                height:                 parent.height - _toolsMargin
                width:                  scalable_warnings_panel_width
                showBorder:             true
                statusActivity:         _activeVehicle ? ((_unhealthySensors & Vehicle.SysStatusSensorGPS) ? statusError : statusNormal) : statusDisabled
                showOnMouseHighlight:   true
            }

            CustomMavStatusIndicator {
                id:             warning_panel_4
                enabled:        _activeVehicle
                anchors {
                    top:        parent.top
                    topMargin:  _toolsMargin
                    left:       warning_panel_2.right
                    leftMargin: _toolsMargin
                }
                text:           qsTr("MAG")
                height:         parent.height - _toolsMargin
                width:          scalable_warnings_panel_width
                showBorder:     true
                statusActivity: _activeVehicle ? ((_unhealthySensors & Vehicle.SysStatusSensor3dMag) ? statusError : statusNormal) : statusDisabled
            }
            // CustomMavStatusIndicator {
            //     id:             warning_panel_5
            //     anchors {
            //         top:        warning_panel_4.bottom
            //         topMargin:  _toolsMargin
            //         left:       warning_panel_2.right
            //         leftMargin: _toolsMargin
            //     }
            //     text:           qsTr("NOT IN USE")
            //     height:         parent.height * 0.5 - _toolsMargin
            //     width:          scalable_warnings_panel_width
            //     showBorder:     true
            //     statusActivity: _activeVehicle ? ((_unhealthySensors & Vehicle.SysStatusSensor3dGyro) ? statusError : statusNormal) : statusDisabled
            //     visible:        false
            // }

            CustomMavStatusIndicator {
                id:             warning_panel_6
                enabled:        _activeVehicle
                anchors {
                    top:        parent.top
                    topMargin:  _toolsMargin
                    left:       warning_panel_4.right
                    leftMargin: _toolsMargin
                }
                text:           qsTr("ACCEL")
                height:         parent.height - _toolsMargin
                width:          scalable_warnings_panel_width
                showBorder:     true
                statusActivity: _activeVehicle ? ((_unhealthySensors & Vehicle.SysStatusSensor3dAccel) ? statusError : statusNormal) : statusDisabled
            }
            // CustomMavStatusIndicator {
            //     id:             warning_panel_7
            //     anchors {
            //         top:        warning_panel_6.bottom
            //         topMargin:  _toolsMargin
            //         left:       warning_panel_4.right
            //         leftMargin: _toolsMargin
            //     }
            //     text:           qsTr(" ")
            //     height:         parent.height * 0.5 - _toolsMargin
            //     width:          scalable_warnings_panel_width
            //     showBorder:     true
            //     enabled:        false
            //     visible:        false
            // }

            CustomMavStatusIndicator {
                id:             warning_panel_8
                enabled:        _activeVehicle
                anchors {
                    top:        parent.top
                    topMargin:  _toolsMargin
                    left:       warning_panel_6.right
                    leftMargin: _toolsMargin
                }
                text:           qsTr("GYRO")
                height:         parent.height - _toolsMargin
                width:          scalable_warnings_panel_width
                showBorder:     true
                statusActivity: _activeVehicle ? ((_unhealthySensors & Vehicle.SysStatusSensor3dGyro) ? statusError : statusNormal) : statusDisabled
            }
            // CustomMavStatusIndicator {
            //     id:             warning_panel_9
            //     anchors {
            //         top:        warning_panel_8.bottom
            //         topMargin:  _toolsMargin
            //         left:       warning_panel_6.right
            //         leftMargin: _toolsMargin
            //     }
            //     text:           qsTr(" ")
            //     height:         parent.height * 0.5 - _toolsMargin
            //     width:          scalable_warnings_panel_width
            //     showBorder:     true
            //     enabled:        false
            //     visible:        false
            // }

            CustomMavStatusIndicator {
                id:             warning_panel_10
                enabled:        _activeVehicle
                anchors {
                    top:        parent.top
                    topMargin:  _toolsMargin
                    left:       warning_panel_8.right
                    leftMargin: _toolsMargin
                }
                text:           qsTr("AHRS")
                height:         parent.height - _toolsMargin
                width:          scalable_warnings_panel_width
                showBorder:     true
                statusActivity: _activeVehicle ? ((_unhealthySensors & Vehicle.SysStatusSensorAHRS) ? statusError : statusNormal) : statusDisabled
            }
            // CustomMavStatusIndicator {
            //     id:             warning_panel_11
            //     anchors {
            //         top:        warning_panel_10.bottom
            //         topMargin:  _toolsMargin
            //         left:       warning_panel_8.right
            //         leftMargin: _toolsMargin
            //     }
            //     text:           qsTr(" ")
            //     height:         parent.height * 0.5 - _toolsMargin
            //     width:          scalable_warnings_panel_width
            //     showBorder:     true
            //     enabled:        false
            //     visible:        false
            // }

            CustomMavStatusIndicator {
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
            CustomMavStatusIndicator {
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

    // RIGHT SIDE BUTTON TOOL STRIP
    CustomToolStrip {
        id: rightSide_toolStrip
        anchors {
            right:  parent.right
            top:    parent.top
            bottom: parent.bottom
        }
        z:                  QGroundControl.zOrderWidgets
        maxHeight:          parent.height - rightSide_toolStrip.y
        dropDirection:      dropLeft

        ToolStripActionList {
            id: rightSide_toolStripActionList
            model: [
                CustomToolStripAction {
                    text:           _activeVehicle ? qsTr("Connected"):qsTr("Disconn")
                    iconSource:     _activeVehicle ? "/qmlimages/Connect.svg" : "/qmlimages/Disconnect.svg"
                    enabled:        _activeVehicle
                    iconTrueColor:  true
                    buttonColor:    _activeVehicle ? statusHealthyColorHEX : qgcPal.toolbarBackground
                },
                CustomToolStripAction {
                    text:           _activeVehicle ? (_activeVehicle.armed ? qsTr("Armed") : qsTr("Disarmed")) : qsTr("Disarmed")
                    iconSource:     _activeVehicle ? (_activeVehicle.armed ? "/qmlimages/Armed.svg" : "/qmlimages/Disarmed.svg") : "/qmlimages/Disarmed.svg"
                    onTriggered:    _activeVehicle.armed ? _guidedController.confirmAction(_guidedController.actionDisarm, 1) : _guidedController.confirmAction(_guidedController.actionArm, 1)
                    enabled:        _activeVehicle
                    iconTrueColor:  true
                },
                ToolStripAction {
                    text:               _activeVehicle ? _activeVehicle.flightMode : qsTr("N/A") 
                    enabled:            _activeVehicle
                    iconSource:         "/qmlimages/FlightModesComponentIcon.png"
                    dropPanelComponent: flightModeSelectDropPanel
                },
                ToolStripAction {
                    text:           qsTr("Set Takeoff")
                    iconSource:     "/res/takeoff.svg"
                    enabled:        _activeVehicle ? (_activeVehicle.armed ? false:true): false
                    onTriggered:    _activeVehicle.setCurrentMissionSequence(1)
                },
                ToolStripAction {
                    text:           qsTr("RTL")
                    iconSource:     "/res/rtl.svg"
                    enabled:        _activeVehicle ? (_activeVehicle.armed ? true:false): false
                    onTriggered:    _guidedController.confirmAction(_guidedController.actionRTL, 1)
                },
                ToolStripAction {
                    text:           qsTr(" ")
                    enabled:        false
                },
                ToolStripAction {
                    text:           qsTr(" ")
                    enabled:        false
                },
                ToolStripAction {
                    text:           qsTr(" ")
                    enabled:        false
                }
            ]
        }
        model: rightSide_toolStripActionList.model
    }


    // RIGHT SIDE BUTTON CONTROLS - OLD
    Rectangle {
        id:                     rightSideButtonControls_Boarder
        anchors {
            topMargin:      _toolsMargin
            right:          parent.right
        }
        height:             Screen.height
        width:              _tabWidth +  _toolsMargin
        color:              qgcPal.windowShadeDark
        visible:            false
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
            CustomMavStatusIndicator {
                id:             right_button_0
                height:         scalable_button_height 
                width:          parent.width
                showBorder:     true
                anchors {
                    top:        parent.top
                    topMargin:  _toolsMargin
                }
                text:           _activeVehicle ? qsTr("Connected"):qsTr("Disconn")
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
                onClicked:      _activeVehicle.setCurrentMissionSequence(1) //_guidedController.confirmAction(_guidedController.actionSetWaypoint, 1)
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
                // text:           qsTr("WP ") + _guidedController._currentMissionIndex
                enabled:        false // _activeVehicle
                // onClicked:      _guidedController.confirmAction(_guidedController.actionSetWaypoint, _guidedController._currentMissionIndex + 1)
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

    // LEFT SIDE BUTTON TOOL STRIP
    CustomToolStrip {
        id: leftSide_toolStrip
        anchors {
            left:   parent.left
            top:    parent.top
            bottom: parent.bottom
        }
        z:                  QGroundControl.zOrderWidgets
        maxHeight:          parent.height - leftSide_toolStrip.y
        dropDirection:      dropRight

        ToolStripActionList {
            id: leftSide_toolStripActionList
            model: [
                ToolStripAction {
                    text:           qsTr("Plan View")
                    iconSource:     "/qmlimages/Plan.svg"
                    onTriggered:    mainWindow.showPlanView()
                },
                ToolStripAction {
                    text:           qsTr(" ")
                    enabled:        false
                    // text:           qsTr("Swap Display")
                    // iconSource:     "/InstrumentValueIcons/view-carousel.svg"
                    // enabled:        _activeVehicle
                    // onTriggered:    swapFlightDisplay()
                },
                CustomToolStripAction {
                    text:           qsTr("Battery")
                    enabled:        _activeVehicle
                    iconSource:     getBatteryIcon()
                    buttonColor:    getBatteryColor()
                },
                CustomToolStripAction {
                    text:               qsTr("Sensors")
                    iconSource:         "/InstrumentValueIcons/align-left.svg"
                    enabled:            _activeVehicle
                    dropPanelComponent: statusSenrosDropPanel
                    buttonColor:        getSensorsStatusColor()
                },
                CustomToolStripAction {
                    text:               (_activeVehicle && _activeVehicle.gps.count.value >= 0) ? qsTr("GPS Status") : qsTr("NO GPS")
                    enabled:            _activeVehicle
                    iconSource:         "/InstrumentValueIcons/radar.svg"
                    dropPanelComponent: statusGPSDropPanel
                    buttonColor:        getGPSStatusColor()
                },
                CustomToolStripAction {
                    text:               qsTr("Messages")
                    iconSource:         "/qmlimages/Megaphone.svg"
                    enabled:            _activeVehicle
                    dropPanelComponent: messageDropPanel
                    buttonColor:        getMessageColor()
                },
                ToolStripAction {
                    text:               qsTr("Vehicle")
                    iconSource:         "/qmlimages/Gears.svg"
                    onTriggered: {
                        if (!mainWindow.preventViewSwitch()) {
                            mainWindow.showSetupTool()
                        } 
                    } 
                },
                ToolStripAction {                
                    text:               qsTr("App")
                    iconSource:         "/res/gear-white.svg"
                    onTriggered: {
                        if (!mainWindow.preventViewSwitch()) {
                            mainWindow.showSettingsTool()
                        }
                    } 
                }
            ]
        }
        
        model: leftSide_toolStripActionList.model
    }

    // LEFT SIDE BUTTON CONTROLS - OLD
    Rectangle {
        id:                     leftSideButtonControls_Boarder
        anchors {
            topMargin:          _toolsMargin
            left:               parent.left
        }
        height:                 parent.height
        width:                  _tabWidth +  _toolsMargin
        color:                  qgcPal.windowShadeDark
        visible:                false
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
                iconSource:     "/qmlimages/PaperPlane.svg"
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
                    top:        button_5.bottom
                    topMargin:  _toolsMargin
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
                    top:        button_6.bottom
                    topMargin:  _toolsMargin
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
        id:                 flightControlRectangle
        visible:            false
        anchors {
            topMargin:      _toolsMargin
            left:           leftSide_toolStrip.right //leftSideButtonControls_Boarder.right
        }
        height:             Window.height
        width:              Window.width * 0.2
        color:              qgcPal.windowShade
        MouseArea {
            anchors.fill:   parent
        }
    }
    
    //-------------------------------------------------------------------------
    // MAIN FLIGHT ATTITUDE INDICATOR
    property bool _flightDisplayOnMainWindow: false
    function swapFlightDisplay() {
        _flightDisplayOnMainWindow = !_flightDisplayOnMainWindow
    }    

    Rectangle {
        id:                     attitudeIndicator
        MouseArea {
            anchors.fill: parent
        }
        anchors {
            top:                compassBar.bottom
            left:               leftSide_toolStrip.right
        }
        width:                  flightControlRectangle.width // ScreenTools.defaultFontPixelHeight * 6
        height:                 width * 0.65
        radius:                 height * 0.5
        color:                  qgcPal.windowShade
        visible:                true

        CustomAttitudeWidget {
            // size:               parent.height * 0.95
            size_width:         parent.width
            size_height:        parent.height
            vehicle:            _activeVehicle
            anchors.centerIn:   parent
            visible:            !_flightDisplayOnMainWindow
        }
    }   

    //-------------------------------------------------------------------------
    // HEADING INTDICATOR 1 - HORIZONTAL HEADING TAPE
    Rectangle {
        id:                         compassBar
        height:                     _flightDisplayOnMainWindow ? parent.height * 0.05 : ScreenTools.defaultFontPixelHeight * 1.5
        width:                      _flightDisplayOnMainWindow ? parent.width * 0.9 : flightControlRectangle.width //- _toolsMargin * 2// ScreenTools.defaultFontPixelWidth  * 50
        color:                      "#DEDEDE"
        // radius:                     2
        clip:                       true
        MouseArea {
            anchors.fill: parent
        }
        anchors {
            top:                    parent.top
            // topMargin:              _toolsMargin
            horizontalCenter:       _flightDisplayOnMainWindow ? parent.horizontalCenter : attitudeIndicator.horizontalCenter
        }
        // anchors.top:                parent.top //flightControlRectangle.top
        // anchors.topMargin:          _toolsMargin //-headingIndicator.height / 2
        // anchors.left:               flightControlRectangle.right
        // anchors.horizontalCenter:   flightControlRectangle.horizontalCenter
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
            id:                     headingIndicator
            height:                 ScreenTools.defaultFontPixelHeight
            width:                  ScreenTools.defaultFontPixelWidth * 4
            color:                  qgcPal.windowShadeDark
            anchors {
                bottom:             compassBar.top
                horizontalCenter:   compassBar.horizontalCenter
                // topMargin:          _toolsMargin
            }
            QGCLabel {
                text:               _heading
                color:              qgcPal.text
                font.pointSize:     ScreenTools.smallFontPointSize
                anchors.centerIn:   parent
            }
        }
        Image {
            id:                     compassArrowIndicator
            height:                 _indicatorsHeight
            width:                  height
            source:                 "/custom/img/compass_pointer.svg"
            fillMode:               Image.PreserveAspectFit
            sourceSize.height:      height
            anchors {
                top:                compassBar.bottom
                topMargin:          -height / 2
                horizontalCenter:   compassBar.horizontalCenter
            }
        }
    }

    //-------------------------------------------------------------------------
    // HEADING INDICATOR 2 - RADIAL HEADING INDICATOR (VISIBILITY SET TO FALSE)
    Rectangle {
        id:                     compassBackground
        anchors {
            top:                attitudeIndicator.bottom
            topMargin:          _toolsMargin //-attitudeIndicator.width / 2
            horizontalCenter:   flightControlRectangle.horizontalCenter
        }
        width:                  flightControlRectangle.width //-anchors.rightMargin + compassBezel.width + (_toolsMargin * 2)
        height:                 attitudeIndicator.height
        radius:                 2
        color:                  qgcPal.windowShade //qgcPal.window
        visible: false

        Rectangle {
            id:                     compassBezel
            anchors {
                verticalCenter:     parent.verticalCenter
                leftMargin:         _toolsMargin
                left:               parent.left
            }
            width:                  height
            height:                 parent.height - (northLabelBackground.height / 2) - (headingLabelBackground.height / 2)
            radius:                 height / 2
            border.color:           qgcPal.text
            border.width:           1
            color:                  Qt.rgba(0,0,0,0)
        }

        Rectangle {
            id:                     northLabelBackground
            anchors {
                top:                compassBezel.top
                topMargin:          -height / 2
                horizontalCenter:   compassBezel.horizontalCenter
            }
            width:                  northLabel.contentWidth * 1.5
            height:                 northLabel.contentHeight * 1.5
            radius:                 ScreenTools.defaultFontPixelWidth  * 0.25
            color:                  qgcPal.windowShade

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

    //-------------------------------------------------------------------------
    // GPS STATUS INDICATOR - Rectangular Section (VISIBILITY SET TO FALSE, LEGACY LAYOUT FROM NEURON V3)
    Rectangle {
        //copied from GPSIndicator.qml
        id:                         gps_info_window
        anchors.horizontalCenter:   flightControlRectangle.horizontalCenter
        anchors.top:                compassBackground.visible ? compassBackground.bottom:attitudeIndicator.bottom
        width:                      flightControlRectangle.width
        height:                     width * 0.35//gpsCol.height  + ScreenTools.defaultFontPixelHeight * 2
        radius:                     ScreenTools.defaultFontPixelHeight * 0.5
        color:                      qgcPal.window
        border.color:               qgcPal.text
        visible:                    false

        Column {
            id:                 gpsCol
            spacing:            ScreenTools.defaultFontPixelHeight * 0.5
            width:              parent.width // Math.max(gpsGrid.width, gpsLabel.width)
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

    //-------------------------------------------------------------------------
    // MAV MESSAGE INDICATOR
    // function from messageIndicator.qml for use in Side ToolStrip
    function getMessageColor() {
        if (_activeVehicle) {
            if (_activeVehicle.messageTypeNone)
                return statusHealthyColorHEX // qgcPal.toolbarBackground // qgcPal.colorGrey
            if (_activeVehicle.messageTypeNormal)
                return qgcPal.colorBlue;
            if (_activeVehicle.messageTypeWarning)
                return statusWarningColorHEX // qgcPal.colorOrange;
            if (_activeVehicle.messageTypeError)
                return statusCriticalColorHEX // qgcPal.colorRed;
            // Cannot be so make make it obnoxious to show error
            console.warn("MessageIndicator.qml:getMessageColor Invalid vehicle message type", _activeVehicle.messageTypeNone)
            return "purple";
        }
        //-- It can only get here when closing (vehicle gone while window active)
        return qgcPal.toolbarBackground // qgcPal.colorGrey
    }

    Component {
        id: messageDropPanel
        ColumnLayout {
            spacing:    ScreenTools.defaultFontPixelWidth * 0.5
            width:      messageWindow.width
            height:     messageWindow.height
            // QGCLabel { text: qsTr("Messages:") }
            CustomMavMessageWidget {
                id:                     messageWindow
                width:                  Window.width - leftSide_toolStrip.width*3
                height:                 flightControlRectangle.width
                anchors.fill:           parent.fill
            }
        }
    }

    //-------------------------------------------------------------------------
    // MAV MESSAGE INDICATOR (LEGACY LAYOUT FROM NEURON V3
    // function from messageIndicator.qml for use in Side ToolStrip
    CustomMavMessageWidget {
        property real height_gps_info:       Window.height - compassBar.height - attitudeIndicator.height - gps_info_window.height - _toolsMargin
        property real height_no_gps_info:    Window.height - compassBar.height - attitudeIndicator.height - _toolsMargin
        visible:                false

        id:                     static_messageWindow
        width:                  flightControlRectangle.width
        height:                 (gps_info_window.visible ? height_gps_info : height_no_gps_info) - 1
        anchors {
            top:                gps_info_window.visible ? gps_info_window.bottom : gps_info_window.top
            horizontalCenter:   flightControlRectangle.horizontalCenter
        }
    }

    //-------------------------------------------------------------------------
    // FLIGHT SELECT DROP PANEL
    Component {
        id: flightModeSelectDropPanel
        CustomFlightModeSelectDropPanel {
            activeVehicle:      _activeVehicle
        }
    }

    //-------------------------------------------------------------------------
    // GPS DROP PANEL COMPONENT
    Component {
        id: statusGPSDropPanel
        CustomMavStatusGPSDropPanel {
            activeVehicle: _activeVehicle
        }
    }

    function getGPSStatusColor() {
        if (_activeVehicle) {
            if (_unhealthySensors & Vehicle.SysStatusSensorGPS) {
                return statusCriticalColorHEX;
            }
            else {
                return statusHealthyColorHEX;
            }
        }
        return qgcPal.toolbarBackground;
    }

    //-------------------------------------------------------------------------
    // SENSORS STATUS DROP PANEL COMPONENT
    Component {
        id: statusSenrosDropPanel
        CustomMavStatusSensorsDropPanel {
            activeVehicle: _activeVehicle
        }
    }

    function getSensorsStatusColor() {
        if (_activeVehicle) {
            if (_activeVehicle.allSensorsHealthy) {
                return statusHealthyColorHEX;
            }
            else {
                return statusCriticalColorHEX;
            }
        }
        return qgcPal.toolbarBackground;
    }

    //-------------------------------------------------------------------------
    // BATTERY INDICATOR COMPONENT
    property var    _batteryGroup:          _activeVehicle && _activeVehicle.batteries.count ? _activeVehicle.batteries.get(0) : undefined
    property var    _batteryValue:          _batteryGroup ? _batteryGroup.percentRemaining.value : 0
    property var    _batPercentRemaining:   isNaN(_batteryValue) ? 0 : _batteryValue

    function getBatteryColor() {
        if(_activeVehicle) {
            if(_batPercentRemaining > 75) {
                return qgcPal.colorGreen;
            }
            if(_batPercentRemaining > 50) {
                return qgcPal.colorOrange;
            }
            if(_batPercentRemaining > 0.1) {
                return qgcPal.colorRed;
            }
        }
        return  qgcPal.toolbarBackground;//qgcPal.colorGrey
    }

    function getBatteryIcon() {
        if(_activeVehicle) {
            if(_batPercentRemaining > 75) {
                return "/InstrumentValueIcons/battery-full.svg";
            }
            if(_batPercentRemaining > 50) {
                return "/InstrumentValueIcons/battery-half.svg";
            }
            if(_batPercentRemaining > 0.1) {
                return "/InstrumentValueIcons/battery-low.svg";
            }
        }
        return "/InstrumentValueIcons/battery-low.svg"
    }
}
