import QtQuick                      2.11
import QtQuick.Controls             2.12
import QtQuick.Controls.Styles      1.4

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QtGraphicalEffects           1.0

Button {
    id:             control
    hoverEnabled:   true
    topPadding:     _verticalPadding
    bottomPadding:  _verticalPadding
    leftPadding:    _horizontalPadding
    rightPadding:   _horizontalPadding
    focusPolicy:    Qt.ClickFocus

    property string statusActivity    // use this flag to change the indicator's status. 

    property string statusNormal:   "Normal"
    property string statusError:    "Error"
    property string statusDisabled: "Disabled"

    property bool   onMouseHighlight:       pressed | hovered | checked
    property bool   showOnMouseHighlight

    property bool   primary:        false                               ///< primary button for a group of buttons
    property real   pointSize:      ScreenTools.defaultFontPointSize    ///< Point size for button text
    property bool   showBorder:     qgcPal.globalTheme === QGCPalette.Light
    property bool   iconLeft:       false
    property real   backRadius:     0
    property real   heightFactor:   0.5
    property string iconSource

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
        color:          qgcPal.button
        states: [
            State{
                name: "on_mouse"; when: onMouseHighlight && showOnMouseHighlight
                PropertyChanges {
                    target: backRect; 
                    color:  onMouseHighlight ? 
                        qgcPal.buttonHighlight : (primary ? qgcPal.primaryButton : qgcPal.button)
                }
            },
            State {
                name: "Normal"; when: statusActivity == statusNormal
                PropertyChanges {target: backRect; color: "green"}//qgcPal.buttonHighlight}
            },
            State {
                name: "Error"; when: statusActivity == statusError
                PropertyChanges {target: backRect; color: "red"}
            },
            State {
                name: "Disabled"; when: statusActivity == statusDisabled
                PropertyChanges {target: backRect; color: qgcPal.button}
            }
        ]
    }

    contentItem: Item {
        implicitWidth:  _text.implicitWidth + icon.width
        implicitHeight: _text.implicitHeight
        baselineOffset: _text.y + _text.baselineOffset

        QGCColoredImage {
            id:                     icon
            source:                 control.iconSource
            height:                 source === "" ? 0 : _text.height *2
            width:                  height
            color:                  _text.color
            fillMode:               Image.PreserveAspectFit
            sourceSize.height:      height
            anchors {
                horizontalCenter:   parent.horizontalCenter 
                verticalCenter:     parent.verticalCenter
            }
        }

        Text {
            id:                     _text
            anchors {
                horizontalCenter:   parent.horizontalCenter
                verticalCenter:     parent.verticalCenter
            }
            antialiasing:           true
            text:                   control.text
            font.pointSize:         pointSize
            font.family:            ScreenTools.normalFontFamily
            color:                  qgcPal.buttonText

            visible:                !iconSource

            wrapMode:               Text.WordWrap
            horizontalAlignment:    Text.AlignHCenter
            verticalAlignment:      Text.AlignVCenter

            states: [
                State {
                    name: "on_mouse"; when: onMouseHighlight && showOnMouseHighlight
                    PropertyChanges {
                        target: _text; 
                        color:  onMouseHighlight ? 
                            qgcPal.buttonHighlightText : (primary ? qgcPal.primaryButtonText : qgcPal.buttonText)
                    }
                },
                State {
                    name: "Normal"; when: statusActivity == statusNormal
                    PropertyChanges {target:_text; color: qgcPal.buttonHighlightText}
                },
                State {
                    name: "Error"; when: statusActivity == statusError
                    PropertyChanges {target:_text; color: qgcPal.primaryButtonText}
                },
                State {
                    name: "Disabled"; when: statusActivity == statusDisabled
                    PropertyChanges {target:_text; color: qgcPal.buttonText}
                }
            ]
        }

        Text {
            id:                     _text_bottom_if_with_icon
            anchors {
                bottom:             parent.bottom
                bottomMargin:       parent.bottomMargin
                horizontalCenter:   parent.horizontalCenter
            }
            antialiasing:           true
            text:                   control.text
            font.pointSize:         pointSize
            font.family:            ScreenTools.normalFontFamily
            color:                  qgcPal.buttonText

            visible:                iconSource

            wrapMode:               Text.WordWrap
            horizontalAlignment:    Text.AlignHCenter
            verticalAlignment:      Text.AlignVCenter

            states: [
                State {
                    name: "on_mouse"; when: onMouseHighlight && showOnMouseHighlight
                    PropertyChanges {
                        target: _text_bottom_if_with_icon; 
                        color:  onMouseHighlight ? 
                            qgcPal.buttonHighlightText : (primary ? qgcPal.primaryButtonText : qgcPal.buttonText)
                    }
                },
                State {
                    name: "Normal"; when: statusActivity == statusNormal
                    PropertyChanges {target:_text_bottom_if_with_icon; color: qgcPal.buttonHighlightText}
                },
                State {
                    name: "Error"; when: statusActivity == statusError
                    PropertyChanges {target:_text_bottom_if_with_icon; color: qgcPal.primaryButtonText}
                },
                State {
                    name: "Disabled"; when: statusActivity == statusDisabled
                    PropertyChanges {target:_text_bottom_if_with_icon; color: qgcPal.buttonText}
                }
            ]
        }
    }
}