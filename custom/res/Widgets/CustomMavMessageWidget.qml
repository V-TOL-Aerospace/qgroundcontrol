import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

//-------------------------------------------------------------------------
//-- Message Indicator
Rectangle {
    id:             _root

    radius:         ScreenTools.defaultFontPixelHeight / 2
    color:          qgcPal.window
    border.color:   qgcPal.text

    property bool   showIndicator: true

    property var    activeVehicle:          QGroundControl.multiVehicleManager.activeVehicle
    property bool   _isMessageImportant:    activeVehicle ? !activeVehicle.messageTypeNormal && !activeVehicle.messageTypeNone : false

    function getMessageColor() {
        if (activeVehicle) {
            if (activeVehicle.messageTypeNone)
                return qgcPal.colorGrey
            if (activeVehicle.messageTypeNormal)
                return qgcPal.colorBlue;
            if (activeVehicle.messageTypeWarning)
                return qgcPal.colorOrange;
            if (activeVehicle.messageTypeError)
                return qgcPal.colorRed;
            // Cannot be so make make it obnoxious to show error
            console.warn("MessageIndicator.qml:getMessageColor Invalid vehicle message type", activeVehicle.messageTypeNone)
            return "purple";
        }
        //-- It can only get here when closing (vehicle gone while window active)
        return qgcPal.colorGrey
    }

    
    function formatMessage(message) {
        message = message.replace(new RegExp("<#E>", "g"), "color: " + qgcPal.warningText + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        message = message.replace(new RegExp("<#I>", "g"), "color: " + qgcPal.warningText + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        message = message.replace(new RegExp("<#N>", "g"), "color: " + qgcPal.text + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        return message;
    }

    Connections {
        target: activeVehicle
        onNewFormattedMessage :{
            messageText.append(formatMessage(formattedMessage))
            //-- Hack to scroll down
            messageFlick.flick(0,-500)
        }
    }

    QGCLabel {
        anchors.centerIn:   parent
        text:               qsTr("No Messages")
        visible:            messageText.length === 0
    }

    Component.onCompleted: {
        if (activeVehicle) {
            messageText.text = activeVehicle ? formatMessage(activeVehicle.formattedMessages) : undefined
            //-- Hack to scroll to last message
            for (var i = 0; i <= activeVehicle.messageCount; i++)
                messageFlick.flick(0,-5000)
            activeVehicle.resetAllMessages()
        } else { messageText.text = "" }
    }

    //-- Clear Messages
    // QGCColoredImage {
    //     anchors.bottom:     parent.bottom
    //     anchors.right:      parent.right
    //     anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.5
    //     height:             ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 1.5 : ScreenTools.defaultFontPixelHeight
    //     width:              height
    //     sourceSize.height:   height
    //     source:             "/res/TrashDelete.svg"
    //     fillMode:           Image.PreserveAspectFit
    //     mipmap:             true
    //     smooth:             true
    //     color:              qgcPal.text
    //     visible:            messageText.length !== 0
    //     MouseArea {
    //         anchors.fill:   parent
    //         onClicked: {
    //             if (activeVehicle) {
    //                 activeVehicle.clearMessages()
    //                 // mainWindow.hideIndicatorPopup()
    //             }
    //         }
    //     }
    // }

    FactPanelController {
        id: controller
    }

    QGCFlickable {
        id:                 messageFlick
        anchors.margins:    ScreenTools.defaultFontPixelHeight
        anchors.fill:       parent
        contentHeight:      messageText.height
        contentWidth:       messageText.width
        pixelAligned:       true

        TextEdit {
            id:                 messageText
            readOnly:           true
            textFormat:         TextEdit.RichText
            selectByMouse:      true
            color:              qgcPal.text
            selectionColor:     qgcPal.text
            selectedTextColor:  qgcPal.window
            property var fact:  null
            onLinkActivated: {
                if (link.startsWith('param://')) {
                    var paramName = link.substr(8);
                    fact = controller.getParameterFact(-1, paramName, true)
                    if (fact != null) {
                        paramEditorDialogComponent.createObject(mainWindow).open()
                    }
                } else {
                    Qt.openUrlExternally(link);
                }
            }
        }
        Component {
            id: paramEditorDialogComponent

            ParameterEditorDialog {
                title:          qsTr("Edit Parameter")
                fact:           messageText.fact
                destroyOnClose: true
            }
        }
    }
}
