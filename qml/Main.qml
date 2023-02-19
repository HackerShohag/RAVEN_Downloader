/*
 * Copyright (C) 2022  Abdullah AL Shohag
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * raven.downloader is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQml 2.2
import QtQuick 2.7
import QtQuick.Window 2.2
import Ubuntu.Components 1.3
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import "Components"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'raven.downloader.shohag'
    automaticOrientation: true

    width: units.gu(100)
    height: units.gu(100)

    property int margin: units.gu(1)

    Page {
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr('RAVEN Downloader')
        }


        Component.onCompleted: {
            width = mainLayout.implicitWidth + 2 * margin
            height = mainLayout.implicitHeight + 2 * margin
        }


        ColumnLayout {
            id: mainLayout
            anchors.fill: parent
            anchors.margins: root.margin
            GroupBox {
                id: rowBox
                Layout.fillWidth: true
                Layout.minimumWidth: rowLayout.Layout.minimumWidth + 30

                background: Rectangle {
                    y: rowBox.topPadding - rowBox.bottomPadding
                    width: parent.width
                    height: parent.height - rowBox.topPadding + rowBox.bottomPadding
                    color: "transparent"
                    border.color: "#21be2b"
                    radius: units.gu(1)
                }

                RowLayout {
                    id: rowLayout
                    anchors.fill: parent
                    TextField {
                        placeholderText: i18n.tr("Put YouTube video or playlist URL here")
                        Layout.fillWidth: true
                    }
                    Button {
                        id: submitButton
                        highlighted: true
                        text: i18n.tr("Submit")
                        // onClicked: root.getLinksQML(urlField.text)
                    }
                }
            }

            MediaItem{
                
            }

            // TextArea {
            //     id: t3
            //     text: "This fills the whole cell"
            //     Layout.minimumHeight: units.gu(10)
            //     Layout.fillHeight: true
            //     Layout.fillWidth: true
            // }
            // GroupBox {
            //     id: stackBox
            //     title: "Stack layout"
            //     implicitWidth: 200
            //     implicitHeight: 60
            //     Layout.minimumHeight: units.
            //     Layout.fillWidth: true
            //     Layout.fillHeight: true
            //     StackLayout {
            //         id: stackLayout
            //         anchors.fill: parent

            //         function advance() { currentIndex = (currentIndex + 1) % count }

            //         Repeater {
            //             id: stackRepeater
            //             model: 5
            //             Rectangle {
            //                 // required property int index
            //                 color: Qt.hsla((0.5 + index) / stackRepeater.count, 0.3, 0.7, 1)
            //                 Button {
            //                     anchors.centerIn: parent
            //                     text: "Page " + (index + 1)
            //                     onClicked: { stackLayout.advance() }
            //                 }
            //             }
            //         }
            //     }
            // }
        }
        BottomEdge {
            id: bottomEdge
            height: parent.height - units.gu(20)
            hint.text: "My bottom edge"
            contentComponent: Rectangle {
                width: bottomEdge.width
                height: bottomEdge.height
                color: bottomEdge.activeRegion ?
                         bottomEdge.activeRegion.color : UbuntuColors.green
            }
            regions: [
                BottomEdgeRegion {
                    from: 0.4
                    to: 0.6
                    property color color: UbuntuColors.red
                },
                BottomEdgeRegion {
                    from: 0.6
                    to: 1.0
                    property color color: UbuntuColors.silk
                }
            ]
        }
    }
}