import QtQuick                          2.12
import QtQuick.Controls                 2.4
import QtQuick.Layouts                  1.11
import QtQuick.Windows                  2.2

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
    id:             compassBackground    
    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property real   _heading:               _activeVehicle   ? _activeVehicle.heading.rawValue : 0
    property var    totalToolInsets:        _totalToolInsets    // The insets updated for the custom overlay additions

    width:                  Window.width * 0.1 // flightControlRectangle.width //-anchors.rightMargin + compassBezel.width + (_toolsMargin * 2)
    height:                 width //attitudeIndicator.height
    radius:                 width * 0.5
    color:                  qgcPal.toolbarBackground // qgcPal.windowShade //qgcPal.window
    border.color:           qgcPal.text
    border.width:           0.5

    Rectangle {
        id:                     compassBezel
        anchors {
            centerIn:           parent
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