/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick 2.12

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.FlightDisplay 1.0

Item {
    id:         _root
    visible:    QGroundControl.videoManager.hasVideo

    property Item   pipState:         videoPipState
    property bool   showPFD:          true
    property bool   showBackground:   true

    property real   _rollAngle:       _activeVehicle ? _activeVehicle.roll.rawValue  : 0
    property real   _pitchAngle:      _activeVehicle ? _activeVehicle.pitch.rawValue : 0

    property bool   _communicationLost:     _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property bool   _communicationState:    _activeVehicle && !_communicationLost

    QGCPipState {
        id:         videoPipState
        pipOverlay: _pipOverlay
        isDark:     true

        onWindowAboutToOpen: {
            QGroundControl.videoManager.stopVideo()
            videoStartDelay.start()
        }

        onWindowAboutToClose: {
            QGroundControl.videoManager.stopVideo()
            videoStartDelay.start()
        }

        onStateChanged: {
            if (pipState.state !== pipState.fullState) {
                QGroundControl.videoManager.fullScreen = false
            }
        }
    }

    Timer {
        id:           videoStartDelay
        interval:     2000;
        running:      false
        repeat:       false
        onTriggered:  QGroundControl.videoManager.startVideo()
    }
    
    //----------------------------------------------------
    //-- Artificial Horizon - behind video stream
    CustomArtificialHorizon {
        rollAngle:          _rollAngle
        pitchAngle:         _pitchAngle
        skyColor1:          _communicationState ? "#0a2e50" : qgcPal.windowShade
        skyColor2:          _communicationState ? "#2f85d4" : qgcPal.windowShade
        groundColor1:       _communicationState ? "#897459" : qgcPal.windowShadeDark
        groundColor2:       _communicationState ? "#4b3820" : qgcPal.windowShadeDark
        anchors.fill:       parent
        visible:            QGroundControl.videoManager.isGStreamer && showBackground && showPFD
    }
    
    //-- Video Streaming
    CustomFlightDisplayViewVideo {
        id:             videoStreaming
        anchors.fill:   parent
        useSmallFont:   _root.pipState.state !== _root.pipState.fullState
        visible:        QGroundControl.videoManager.isGStreamer
    }
    //-- UVC Video (USB Camera or Video Device)
    Loader {
        id:             cameraLoader
        anchors.fill:   parent
        visible:        !QGroundControl.videoManager.isGStreamer
        source:         QGroundControl.videoManager.uvcEnabled ? "qrc:/qml/FlightDisplayViewUVC.qml" : "qrc:/qml/FlightDisplayViewDummy.qml"
    }

    CustomAttitudeWidget {
        vehicle:            _activeVehicle
        showBackground:     false
        anchors.fill:       parent
        visible:            QGroundControl.videoManager.isGStreamer && showPFD
        size_width:         parent.width
        size_height:        parent.height
    }

    QGCLabel {
        text: qsTr("Double-click to exit full screen")
        font.pointSize: ScreenTools.largeFontPointSize
        visible: QGroundControl.videoManager.fullScreen && flyViewVideoMouseArea.containsMouse
        anchors.centerIn: parent

        onVisibleChanged: {
            if (visible) {
                labelAnimation.start()
            }
        }

        PropertyAnimation on opacity {
            id: labelAnimation
            duration: 10000
            from: 1.0
            to: 0.0
            easing.type: Easing.InExpo
        }
    }

    MouseArea {
        id: flyViewVideoMouseArea
        anchors.fill:       parent
        enabled:            pipState.state === pipState.fullState
        hoverEnabled: true
        onDoubleClicked:    QGroundControl.videoManager.fullScreen = !QGroundControl.videoManager.fullScreen
    }

    ProximityRadarVideoView{
        anchors.fill:   parent
        vehicle:        QGroundControl.multiVehicleManager.activeVehicle
    }

    ObstacleDistanceOverlayVideo {
        id: obstacleDistance
        showText: pipState.state === pipState.fullState
    }
}
