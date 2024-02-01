import QtQuick                          2.12
import QtQuick.Controls                 2.4 
import QtQuick.Layouts                  1.11
import QtQuick.Window                   2.2

import QGroundControl                   1.0
import QGroundControl.Controls          1.0
import QGroundControl.Controllers       1.0
import QGroundControl.FactSystem        1.0
import QGroundControl.FlightDisplay     1.0
import QGroundControl.FlightMap         1.0
import QGroundControl.Palette           1.0
import QGroundControl.ScreenTools       1.0
import QGroundControl.Vehicle           1.0

import Custom.Widgets                   1.0

Rectangle {
    id:             compassBar
    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property real   _heading:               _activeVehicle   ? _activeVehicle.heading.rawValue : 0
    property var    totalToolInsets:        _totalToolInsets    // The insets updated for the custom overlay additions
    // height:                     _flightDisplayOnMainWindow ? parent.height * 0.05 : ScreenTools.defaultFontPixelHeight * 1.5
    // width:                      _flightDisplayOnMainWindow ? parent.width * 0.9 : flightControlRectangle.width //- _toolsMargin * 2// ScreenTools.defaultFontPixelWidth  * 50
    color:                      "#DEDEDE"
    // radius:                     2
    clip:                       true
    
    QGCToolInsets {
        id:                     _totalToolInsets
        topEdgeCenterInset:     compassArrowIndicator.y + compassArrowIndicator.height
        rightEdgeBottomInset:   parent.width - compassBackground.x
    }

    MouseArea {
        anchors.fill: parent
    }
    
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