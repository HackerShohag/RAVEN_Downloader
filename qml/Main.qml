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
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtGraphicalEffects 1.0
import Lomiri.Components 1.3

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

        function toggleBlankPage() {
            if (downloadItems.modelData === 0) {
                searchBarLayout.visible = false;
                blankDownloadPage.visible = true;
                return ;
            }
            searchBarLayout.visible = true;
            blankDownloadPage.visible = false;
        }

        Component.onCompleted: {
            width = searchBarLayout.implicitWidth + 2 * margin
            height = searchBarLayout.implicitHeight + 2 * margin
            toggleBlankPage()
        }


        ColumnLayout {
            id: searchBarLayout
            visible: false
            anchors.topMargin: header.height /*+ root.margin*/
            anchors.fill: parent
            anchors.margins: root.margin

            Flickable {
                id: mainScroll
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: downloadItemsContainer.height + rowLayout.height + downloadContainerHeading.height + root.margin + units.gu(2)
                ScrollBar.vertical: ScrollBar { }

                LayoutsCustom {
                    id: inputPanel
                    anchors {
                        top: parent.top
                        right: parent.right
                    }
                    Layout.fillWidth: true

                    height: rowLayout.height + units.gu(11)
                    width: parent.width

                    RowLayout {
                        id: rowLayout
                        anchors.fill: parent
                        anchors.margins: units.gu(3)
                        width: parent.width
                        TextField {
                            placeholderText: i18n.tr("Put YouTube video or playlist URL here")
                            Layout.fillWidth: true
                        }
                        Button {
                            id: submitButton
                            text: i18n.tr("Submit")
                            onClicked: downloadItems.model += 1
                        }
                    }
                }

                Column {
                    id: downloadItemsContainer

                    width: parent.width
                    anchors.top: inputPanel.bottom
                    spacing: -units.gu(3)
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: units.gu(1)

                    Label {
                        id: downloadContainerHeading
                        text: i18n.tr("        Downloaded Files")
                        height: units.gu(5)
                        font.bold: true
                    }

                    Repeater {
                        id: downloadItems
                        anchors.left: parent.left
                        anchors.right: parent.right
                        model: 0
                        delegate: MediaItem {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: units.gu(20)
                            videoTitle: "Youtube video name " + modelData
                            sizeAndDuration: ["0:21:09", "128MB"]
                            mediaTypeModel: ["MP4"]
                            resolutionModel: ["720p"]
                        }
                    }
                }
            }
        }


        // empty page while no downloads


        ColumnLayout {
            id: blankDownloadPage
            visible: true
            spacing: units.gu(2)
            anchors {
                margins: units.gu(2)
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            Item {
                Layout.fillHeight: true
            }

            Label {
                id: label
                Layout.alignment: Qt.AlignHCenter
                text: i18n.tr('Press the button below and check the logs!')
            }

            Button {
                Layout.alignment: Qt.AlignHCenter
                text: i18n.tr('Press here!')
            }

            Item {
                Layout.fillHeight: true
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
                         bottomEdge.activeRegion.color : LomiriColors.green
            }
            regions: [
                BottomEdgeRegion {
                    from: 0.4
                    to: 0.6
                    property color color: LomiriColors.red
                },
                BottomEdgeRegion {
                    from: 0.6
                    to: 1.0
                    property color color: LomiriColors.silk
                }
            ]
        }
    }
}
