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
    id: root
    spacing:    ScreenTools.defaultFontPixelWidth * 0.5
    property var activeVehicle
    
    property string statusNormal:   "Normal"
    property string statusError:    "Error"
    property string statusDisabled: "Disabled"


    property var    _vehicleInAir:      activeVehicle ? activeVehicle.flying || activeVehicle.landing : false
    property bool   _vtolInFWDFlight:   activeVehicle ? activeVehicle.vtolInFwdFlight : false
    property bool   _armed:             activeVehicle ? activeVehicle.armed : false
    property real   _margins:           ScreenTools.defaultFontPixelWidth
    property real   _spacing:           ScreenTools.defaultFontPixelWidth / 2
    property bool   _healthAndArmingChecksSupported: activeVehicle ? activeVehicle.healthAndArmingCheckReport.supported : false

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
                    text:               !activeVehicle? qsTr("Sensor Status (No aircraft connected)") : qsTr("Sensor Status")
                    visible:            !_healthAndArmingChecksSupported
                }

                GridLayout {
                    rowSpacing:     _spacing
                    columnSpacing:  _spacing
                    rows:           activeVehicle.sysStatusSensorInfo.sensorNames.length
                    flow:           GridLayout.TopToBottom
                    visible:        !_healthAndArmingChecksSupported

                    Repeater {
                        model: activeVehicle.sysStatusSensorInfo.sensorNames

                        QGCLabel {
                            text: modelData
                        }
                    }

                    Repeater {
                        model: activeVehicle.sysStatusSensorInfo.sensorStatus

                        QGCLabel {
                            text:       modelData
                        }
                    }

                    Repeater {
                        model: activeVehicle.sysStatusSensorInfo.sensorStatus
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
                    visible:            _healthAndArmingChecksSupported && activeVehicle.healthAndArmingCheckReport.problemsForCurrentMode.count > 0
                }
                // List health and arming checks
                QGCListView {
                    visible:            _healthAndArmingChecksSupported
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    spacing:            ScreenTools.defaultFontPixelWidth
                    width:              mainWindow.width * 0.66666
                    height:             contentHeight
                    model:              activeVehicle ? activeVehicle.healthAndArmingCheckReport.problemsForCurrentMode : null
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