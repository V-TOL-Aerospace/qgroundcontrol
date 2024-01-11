/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick              2.3
import QtQuick.Controls     2.2
import QtGraphicalEffects   1.0

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0

import Custom.Widgets               1.0

Button {
    id:             control
    width:          contentLayoutItem.contentWidth + (contentMargins * 2)
    // height:         width
    hoverEnabled:   true
    enabled:        isBlankButton ? false : toolStripAction.enabled
    visible:        toolStripAction.visible
    imageSource:    isBlankButton ? "" : (toolStripAction.showAlternateIcon ? modelData.alternateIconSource : modelData.iconSource)
    text:           isBlankButton ? qsTr(" ") : toolStripAction.text
    checked:        toolStripAction.checked
    checkable:      toolStripAction.dropPanelComponent || modelData.checkable

    property bool   _showHighlight:     pressed | hovered | checked
    property bool   showBorder:         qgcPal.globalTheme === QGCPalette.Light

    property var    toolStripAction:    undefined
    property var    dropPanel:          undefined
    property alias  radius:             buttonBkRect.radius
    property alias  fontPointSize:      innerText.font.pointSize
    property alias  imageSource:        innerImage.source
    property alias  contentWidth:       innerText.contentWidth
    property bool   iconTrueColor:      toolStripAction.iconTrueColor!=null ? toolStripAction.iconTrueColor : false
    property var    iconColor:          toolStripAction.iconColor
    property var    buttonColor:        toolStripAction.buttonColor
    property bool   isBlankButton:      toolStripAction.isBlankButton!=null ? toolStripAction.isBlankButton : false
    
    // Should be an enum but that get's into the whole problem of creating a singleton which isn't worth the effort
    readonly property int dropLeft:     1
    readonly property int dropRight:    2
    readonly property int dropUp:       3
    readonly property int dropDown:     4

    property int    dropDirection

    property real imageScale:       0.6
    property real contentMargins:   innerText.height * 0.1

    property color _currentContentColor:  (checked || pressed) ? qgcPal.buttonHighlightText : qgcPal.buttonText

    signal dropped(int index)

    onCheckedChanged: toolStripAction.checked = checked

    onClicked: {
        dropPanel.hide()
        if (!toolStripAction.dropPanelComponent) {
            toolStripAction.triggered(this)
        } else if (checked) {
            if (control.dropDirection == dropRight) {
                var panelEdgeTopPoint = mapToItem(_root, width, 0)
                dropPanel.show(panelEdgeTopPoint, toolStripAction.dropPanelComponent, this)
            }
            else if (control.dropDirection == dropLeft) {
                var panelEdgeTopPoint = mapToItem(_root, -1.5*width - contentLayoutItem.width, 0)
                dropPanel.show(panelEdgeTopPoint, toolStripAction.dropPanelComponent, this)
            }
            checked = true
            control.dropped(index)
        }
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: control.enabled }

    contentItem: Item {
        id:                 contentLayoutItem
        anchors.fill:       parent
        anchors.margins:    contentMargins

        Column {
            anchors.centerIn:   parent
            spacing:        contentMargins * 2

            QGCColoredImage {
                id:                         innerImage
                height:                     contentLayoutItem.height * imageScale
                width:                      contentLayoutItem.width  * imageScale
                smooth:                     true
                mipmap:                     true
                // color:                      _currentContentColor
                color:                      iconTrueColor ? "transparent" : 
                                                (iconColor ? iconColor : _currentContentColor)
                fillMode:                   Image.PreserveAspectFit
                antialiasing:               true
                sourceSize.height:          height
                sourceSize.width:           width
                anchors.horizontalCenter:   parent.horizontalCenter
            }

            QGCLabel {
                id:                         innerText
                text:                       control.text
                color:                      _currentContentColor
                anchors.horizontalCenter:   parent.horizontalCenter
            }
        }
    }

    background: Rectangle {
        id:             buttonBkRect
        implicitWidth:  ScreenTools.implicitButtonWidth
        implicitHeight: ScreenTools.implicitButtonHeight
        border.width:   showBorder ? 1 : 0
        border.color:   qgcPal.buttonText
        color:          buttonColor ? buttonColor : 
                        (control.checked || control.pressed) ?
                            qgcPal.buttonHighlight :
                            (control.hovered ? qgcPal.toolStripHoverColor : qgcPal.toolbarBackground)
        anchors.fill:   parent
    }
}
