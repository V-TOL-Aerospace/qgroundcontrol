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

import QtQuick                      2.11
import QtQuick.Controls             2.4

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QtGraphicalEffects           1.0

import QtQuick                  2.3
import QtQuick.Controls         2.12
import QtQuick.Controls.Styles  1.4

import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0

Button {
    id:             control
    hoverEnabled:   true
    topPadding:     _verticalPadding
    bottomPadding:  _verticalPadding
    leftPadding:    _horizontalPadding
    rightPadding:   _horizontalPadding
    focusPolicy:    Qt.ClickFocus

    property bool   primary:        false                               ///< primary button for a group of buttons
    property real   pointSize:      ScreenTools.defaultFontPointSize    ///< Point size for button text
    property bool   showBorder:     qgcPal.globalTheme === QGCPalette.Light
    property bool   iconLeft:       false
    property real   backRadius:     0
    property real   heightFactor:   0.5
    property string iconSource

    property alias wrapMode:            text.wrapMode
    property alias horizontalAlignment: text.horizontalAlignment

    property bool   _showHighlight:     pressed | hovered | checked

    property int _horizontalPadding:    ScreenTools.defaultFontPixelWidth
    property int _verticalPadding:      Math.round(ScreenTools.defaultFontPixelHeight * heightFactor)

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    background: Rectangle {
        id:             backRect
        implicitWidth:  ScreenTools.implicitButtonWidth
        implicitHeight: ScreenTools.implicitButtonHeight
        radius:         backRadius
        border.width:   showBorder ? 1 : 0
        border.color:   qgcPal.buttonText
        color:          _showHighlight ?
                            qgcPal.buttonHighlight :
                            (primary ? qgcPal.primaryButton : qgcPal.button)
    }

    contentItem: Item {
        implicitWidth:  text.implicitWidth + icon.width
        implicitHeight: text.implicitHeight
        baselineOffset: text.y + text.baselineOffset

        QGCColoredImage {
            id:                     icon
            source:                 control.iconSource
            height:                 source === "" ? 0 : text.height *2
            width:                  height
            color:                  text.color
            fillMode:               Image.PreserveAspectFit
            sourceSize.height:      height
            anchors.horizontalCenter: parent.horizontalCenter
            // anchors.left:           control.iconLeft ? parent.left : undefined
            // anchors.leftMargin:     control.iconLeft ? ScreenTools.defaultFontPixelWidth : undefined
            // anchors.right:          !control.iconLeft ? parent.right : undefined
            // anchors.rightMargin:    !control.iconLeft ? ScreenTools.defaultFontPixelWidth : undefined
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id:                     text
            // anchors.centerIn:       parent
            anchors.bottom:             parent.bottom
            anchors.bottomMargin:       parent.bottomMargin
            anchors.horizontalCenter:   parent.horizontalCenter
            antialiasing:           true
            text:                   control.text
            font.pointSize:         pointSize
            font.family:            ScreenTools.normalFontFamily
            color:                  _showHighlight ?
                                        qgcPal.buttonHighlightText :
                                        (primary ? qgcPal.primaryButtonText : qgcPal.buttonText)
        }
    }
}


// Button {
//     id:                             _rootButton
//     width:                          parent.height * 1.25
//     height:                         parent.height
//     flat:                           true
//     contentItem: Item {
//         id:                         _content
//         anchors.fill:               _rootButton
//         Row {
//             id:                     _edge
//             spacing:                ScreenTools.defaultFontPixelWidth * 0.25
//             anchors.left:           parent.left
//             anchors.leftMargin:     ScreenTools.defaultFontPixelWidth
//             anchors.verticalCenter: parent.verticalCenter
//             Repeater {
//                 model: [1,2,3]
//                 Rectangle {
//                     height:         ScreenTools.defaultFontPixelHeight
//                     width:          ScreenTools.defaultFontPixelWidth * 0.25
//                     color:          qgcPal.text
//                     opacity:        0.75
//                 }
//             }
//         }
//         Image {
//             id:                     _icon
//             height:                 _rootButton.height * 0.75
//             width:                  height
//             smooth:                 true
//             mipmap:                 true
//             antialiasing:           true
//             fillMode:               Image.PreserveAspectFit
//             source:                 qgcPal.globalTheme === QGCPalette.Light ? "/res/QGCLogoBlack" : "/res/QGCLogoWhite"
//             sourceSize.height:      height
//             anchors.left:           _edge.right
//             anchors.leftMargin:     ScreenTools.defaultFontPixelWidth
//             anchors.verticalCenter: parent.verticalCenter
//         }
//     }
//     background: Item {
//         anchors.fill: parent
//     }
// }
