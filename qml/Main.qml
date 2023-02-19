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
        id: mainPage
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr('RAVEN Downloader')
        }


        Component.onCompleted: {
            width = searchBarLayout.implicitWidth + 2 * margin
            height = searchBarLayout.implicitHeight + 2 * margin
        }


        ColumnLayout {
            id: searchBarLayout
            anchors.fill: parent
            anchors.margins: root.margin

            Flickable {
                id: mainScroll
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: downloadItems.height
                ScrollBar.vertical: ScrollBar { }

                GroupBox {
                    id: rowBox
                    width: parent.width
                    bottomPadding: units.gu(1)
                    Layout.minimumWidth: rowLayout.Layout.minimumWidth + 30
                    Layout.fillWidth: true

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

                Column {
                    id: downloadItems
                    width: parent.width
                    anchors.top: rowBox.bottom
                    spacing: units.gu(1)
                    anchors.left: parent.left
                    anchors.right: parent.right
                    Repeater {
                        id: passwordsView_breadcrumb
                        anchors.left: parent.left
                        anchors.right: parent.right
                        model: 10
                        delegate: MediaItem {}
                    }
                }
            }
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