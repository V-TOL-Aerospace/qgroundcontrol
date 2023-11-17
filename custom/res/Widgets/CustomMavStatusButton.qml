import QtQuick              2.11
import QtQuick.Controls     2.12
import QtQuick.Layouts      1.11

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0
import QGroundControl.FactSystem            1.0

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
    property string iconSource      // use this flag to include image source directory 

    property string statusNormal:   "Normal"
    property string statusError:    "Error"
    property string statusDisabled: "Disabled"

    property string statusActivity          // use this flag to change the indicator's status
    property bool   onMouseHighlight:       pressed | hovered | checked
    property bool   showOnMouseHighlight

    property int _horizontalPadding:    ScreenTools.defaultFontPixelWidth
    property int _verticalPadding:      Math.round(ScreenTools.defaultFontPixelHeight * heightFactor)

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property var    _vehicleInAir:      _activeVehicle ? _activeVehicle.flying || _activeVehicle.landing : false
    property bool   _vtolInFWDFlight:   _activeVehicle ? _activeVehicle.vtolInFwdFlight : false
    property bool   _armed:             _activeVehicle ? _activeVehicle.armed : false
    property real   _margins:           ScreenTools.defaultFontPixelWidth
    property real   _spacing:           ScreenTools.defaultFontPixelWidth / 2
    property bool   _healthAndArmingChecksSupported: _activeVehicle ? _activeVehicle.healthAndArmingCheckReport.supported : false

    property var activeVehicle 

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    background: Rectangle {
        id:             backRect
        implicitWidth:  ScreenTools.implicitButtonWidth
        implicitHeight: ScreenTools.implicitButtonHeight
        radius:         backRadius
        border {
            width:      showBorder ? 1 : 0
            color:      qgcPal.buttonText
        }
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

    Component {
        id: sensorStatusInfoComponent

        Rectangle {
            width:          flickable.width + (_margins * 2)
            height:         flickable.height + (_margins * 2)
            radius:         ScreenTools.defaultFontPixelHeight * 0.5
            color:          qgcPal.window
            border.color:   qgcPal.text

            QGCFlickable {
                id:                 flickable
                anchors.margins:    _margins
                anchors.top:        parent.top
                anchors.left:       parent.left
                width:              mainLayout.width
                height:             contentHeight // mainWindow.contentItem.height - (indicatorPopup.padding * 2) - (_margins * 2)
                flickableDirection: Flickable.VerticalFlick
                contentHeight:      mainLayout.height
                contentWidth:       mainLayout.width

                ColumnLayout {
                    id:         mainLayout
                    spacing:    _spacing

                    QGCLabel {
                        Layout.alignment:   Qt.AlignHCenter
                        text:               !_activeVehicle? qsTr("Sensor Status (No aircraft connected)") : qsTr("Sensor Status")
                        visible:            !_healthAndArmingChecksSupported
                    }

                    GridLayout {
                        rowSpacing:     _spacing
                        columnSpacing:  _spacing
                        rows:           _activeVehicle.sysStatusSensorInfo.sensorNames.length
                        flow:           GridLayout.TopToBottom
                        visible:        !_healthAndArmingChecksSupported

                        Repeater {
                            model: _activeVehicle.sysStatusSensorInfo.sensorNames

                            QGCLabel {
                                text: modelData
                            }
                        }

                        Repeater {
                            model: _activeVehicle.sysStatusSensorInfo.sensorStatus

                            QGCLabel {
                                text:       modelData
                            }
                        }

                        Repeater {
                            model: _activeVehicle.sysStatusSensorInfo.sensorStatus
                            Rectangle {
                                id:     modelDataStatus_background
                                width:  height //ScreenTools.defaultFontPixelWidth
                                height: ScreenTools.defaultFontPixelHeight
                                color:  "green" // qgcPal.window
                                property string reference_text: modelData
                                states: [
                                    State {
                                        name: "Normal"; when: reference_text == statusNormal
                                        PropertyChanges {target: modelDataStatus_background; color: "green"}//qgcPal.buttonHighlight}
                                    },
                                    State {
                                        name: "Error"; when: reference_text == statusError
                                        PropertyChanges {target: modelDataStatus_background; color: "red"}
                                    },
                                    State {
                                        name: "Disabled"; when: reference_text == statusDisabled
                                        PropertyChanges {target: modelDataStatus_background; color: qgcPal.button}
                                    }
                                ]
                            }
                        }
                    }


                    QGCLabel {
                        text:               qsTr("Arming Check Report:")
                        visible:            _healthAndArmingChecksSupported && _activeVehicle.healthAndArmingCheckReport.problemsForCurrentMode.count > 0
                    }
                    // List health and arming checks
                    QGCListView {
                        visible:            _healthAndArmingChecksSupported
                        anchors.margins:    ScreenTools.defaultFontPixelHeight
                        spacing:            ScreenTools.defaultFontPixelWidth
                        width:              mainWindow.width * 0.66666
                        height:             contentHeight
                        model:              _activeVehicle ? _activeVehicle.healthAndArmingCheckReport.problemsForCurrentMode : null
                        delegate:           listdelegate
                    }

                    FactPanelController {
                        id: controller
                    }

                    Component {
                        id: listdelegate

                        Column {
                            width:      parent ? parent.width : 0
                            Row {
                                width:  parent.width
                                QGCLabel {
                                    id:           message
                                    text:         object.message
                                    wrapMode:     Text.WordWrap
                                    textFormat:   TextEdit.RichText
                                    width:        parent.width - arrowDownIndicator.width
                                    color:        object.severity == 'error' ? qgcPal.colorRed : object.severity == 'warning' ? qgcPal.colorOrange : qgcPal.text
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            if (object.description != "")
                                                object.expanded = !object.expanded
                                        }
                                    }
                                }

                                QGCColoredImage {
                                    id:                     arrowDownIndicator
                                    height:                 1.5 * ScreenTools.defaultFontPixelWidth
                                    width:                  height
                                    source:                 "/qmlimages/arrow-down.png"
                                    color:                  qgcPal.text
                                    visible:                object.description != ""
                                    MouseArea {
                                        anchors.fill:       parent
                                        onClicked:          object.expanded = !object.expanded
                                    }
                                }
                            }
                            Rectangle {
                                property var margin:      ScreenTools.defaultFontPixelWidth
                                id:                       descriptionRect
                                width:                    parent.width
                                height:                   description.height + margin
                                color:                    qgcPal.windowShade
                                visible:                  false
                                Connections {
                                    target:               object
                                    function onExpandedChanged() {
                                        if (object.expanded) {
                                            description.height = description.preferredHeight
                                        } else {
                                            description.height = 0
                                        }
                                    }
                                }

                                Behavior on height {
                                    NumberAnimation {
                                        id: animation
                                        duration: 150
                                        onRunningChanged: {
                                            descriptionRect.visible = animation.running || object.expanded
                                        }
                                    }
                                }
                                QGCLabel {
                                    id:                 description
                                    anchors.centerIn:   parent
                                    width:              parent.width - parent.margin * 2
                                    height:             0
                                    text:               object.description
                                    textFormat:         TextEdit.RichText
                                    wrapMode:           Text.WordWrap
                                    clip:               true
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
                                        fact:           description.fact
                                        destroyOnClose: true
                                    }
                                }
                            }
                        }
                    }

                }
            }
        }
    }

    Component {
        id: vtolTransitionComponent

        Rectangle {
            width:          mainLayout.width   + (_margins * 2)
            height:         mainLayout.height  + (_margins * 2)
            radius:         ScreenTools.defaultFontPixelHeight * 0.5
            color:          qgcPal.window
            border.color:   qgcPal.text

            QGCButton {
                id:                 mainLayout
                anchors.margins:    _margins
                anchors.top:        parent.top
                anchors.left:       parent.left
                text:               _vtolInFWDFlight ? qsTr("Transition to Multi-Rotor") : qsTr("Transition to Fixed Wing")

                onClicked: {
                    if (_vtolInFWDFlight) {
                        mainWindow.vtolTransitionToMRFlightRequest()
                    } else {
                        mainWindow.vtolTransitionToFwdFlightRequest()
                    }
                    mainWindow.hideIndicatorPopup()
                }
            }
        }
    }

    Text {
        id:                     _text
        anchors {
            verticalCenter:         parent.verticalCenter
            horizontalCenter:       parent.horizontalCenter
        }
        antialiasing:               true
        text:                       qsTr("SENSORS")
        font.pointSize:             pointSize
        font.family:                ScreenTools.normalFontFamily
        color:                      qgcPal.buttonText
        enabled:                    activeVehicle

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
                PropertyChanges {target: _text; color: qgcPal.buttonHighlightText}
            },
            State {
                name: "Error"; when: statusActivity == statusError
                PropertyChanges {target: _text; color: qgcPal.primaryButtonText}
            },
            State {
                name: "Disabled"; when: statusActivity == statusDisabled
                PropertyChanges {target: _text; color: qgcPal.buttonText}
            }
        ]
    }

    QGCMouseArea {
        anchors.fill:   parent
        onClicked:      mainWindow.showIndicatorPopup(control, sensorStatusInfoComponent)
    }
}