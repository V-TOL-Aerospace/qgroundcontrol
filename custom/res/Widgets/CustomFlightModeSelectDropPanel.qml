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

ColumnLayout {
    id:         root
    spacing:    ScreenTools.defaultFontPixelWidth * 0.5

    property var activeVehicle
    property bool _useShortListModes:   true

    property var _flightModesFixedWingShortList: [
        // "Manual",
        // "Stabilize",
        // "FBW A",
        "FBW B",
        "Cruise",
        "Auto"
    ]

    property var _flightModesCopterShortList: [
        "Loiter",
        // "Altitude Hold",
        // "Stabilize",
        "Auto"
    ]
    
    FactPanelController {
        id:     controller
    }

    Repeater {
        model: activeVehicle ? 
            (_useShortListModes ? ( controller.vehicle.fixedWing ? _flightModesFixedWingShortList : _flightModesCopterShortList) 
            : activeVehicle.flightModes) : []

        QGCButton {
            text: modelData
            Layout.fillWidth: true
            onClicked: {
                dropPanel.hide()
                activeVehicle.flightMode = text
                mainWindow.hideIndicatorPopup()
            }
        }
    }
}