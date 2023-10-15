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

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

import Custom.Widgets 1.0

Item {
    property var parentToolInsets                       // These insets tell you what screen real estate is available for positioning the controls in your overlay
    property var totalToolInsets:   _totalToolInsets    // The insets updated for the custom overlay additions
    property var mapControl

    readonly property string noGPS:         qsTr("NO GPS")
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

    // Right Side button controls
    Rectangle{
        id:                     rightSideButtonControls_Boarder
        anchors.top:            _toolsMargin
        // anchors.rightMargin:    _toolsMargin
        anchors.right:          parent.right
        height:                 screen.height
        width:                  ScreenTools.defaultFontPixelWidth * 10 +  _toolsMargin//screen.width * 0.05
        color:                  qgcPal.windowShadeDark
        visible:                _test_visible
        Rectangle{
            id:                     rightSideButtonControls
            anchors.top:            _toolsMargin
            // anchors.rightMargin:    _toolsMargin
            anchors.right:          parent.right
            height:                 screen.height
            width:                  ScreenTools.defaultFontPixelWidth * 10 //screen.width * 0.05
            color:                  qgcPal.windowShade
            visible:                _test_visible
        }
    }

    // left Side button controls
    Rectangle{
        id:                     leftSideButtonControls_Boarder
        anchors.top:            _toolsMargin
        // anchors.rightMargin:    _toolsMargin
        anchors.left:          parent.left
        height:                 screen.height
        width:                  ScreenTools.defaultFontPixelWidth * 10 +  _toolsMargin//screen.width * 0.05
        color:                  qgcPal.windowShadeDark
        visible:                _test_visible
        Rectangle{
            id:                     leftSideButtonControls
            anchors.top:            _toolsMargin
            // anchors.rightMargin:    _toolsMargin
            anchors.left:          parent.left
            height:                 screen.height
            width:                  ScreenTools.defaultFontPixelWidth * 10 //screen.width * 0.05
            color:                  qgcPal.windowShade
            visible:                _test_visible
        }
    }

    // Flight control rectangle
    Rectangle{
        id:                     flightControlRectangle
        anchors.top:            _toolsMargin
        // anchors.rightMargin:    _toolsMargin
        anchors.left:          leftSideButtonControls_Boarder.right
        height:                 screen.height
        width:                  screen.width * 0.1
        color:                  qgcPal.windowShade
        visible:                _test_visible
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
        height:                 flightControlRectangle.width // ScreenTools.defaultFontPixelHeight * 6
        width:                  height
        // radius:                 height * 0.5
        color:                  qgcPal.windowShade
        visible:                _test_visible

        CustomAttitudeWidget {
            size:               parent.height * 0.95
            vehicle:            _activeVehicle
            showHeading:        true
            anchors.centerIn:   parent
        }
    }

    // HEADING INDICATOR 2 - RADIAL HEADING INDICATOR
    Rectangle {
        id:                     compassBackground
        anchors.top:            attitudeIndicator.bottom
        anchors.topMargin:      _toolsMargin //-attitudeIndicator.width / 2
        anchors.horizontalCenter:          flightControlRectangle.horizontalCenter
        width:                  flightControlRectangle.width //-anchors.rightMargin + compassBezel.width + (_toolsMargin * 2)
        height:                 attitudeIndicator.height
        radius:                 2
        color:                  qgcPal.windowShade //qgcPal.window

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
        anchors.top: compassBackground.bottom
        width:  flightControlRectangle.width
        height: gpsCol.height  + ScreenTools.defaultFontPixelHeight * 2
        radius: ScreenTools.defaultFontPixelHeight * 0.5
        color:  qgcPal.window
        border.color:   qgcPal.text

        Column {
            id:                 gpsCol
            spacing:            ScreenTools.defaultFontPixelHeight * 0.5
            width:              Math.max(gpsGrid.width, gpsLabel.width)
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
}
