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
import Lomiri.Components.Popups 1.3

import "Components"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'raven.downloader.shohag'
    automaticOrientation: true

    width: units.gu(100)
    height: units.gu(100)

    property int margin: units.gu(1)

    function urlHandler(url, index) {
        if (index) {
            if (!(downloadManager.isValidPlayListUrl(url))) {
                PopupUtils.open(invalidPlayListURLWarning);
                return ;
            }
            if (downloadItemsContainer.visible === false)
                mainPage.toggleBlankPage();
            downloadManager.actionSubmit(url, index);
            return ;
        }

        if (downloadManager.isValidUrl(url)) {
            if (downloadItemsContainer.visible === false)
                mainPage.toggleBlankPage();
            downloadManager.actionSubmit(url, index);
            return ;
        }
        PopupUtils.open(invalidURLWarning);
    }

    Connections {
        target: downloadManager
        onFormatsUpdated: {
            console.log("emitted signal formatsUpdated()")
            downloadItemsModel.append({
                                          vTitle: downloadManager.mediaFormats.title,
                                          vThumbnail: downloadManager.mediaFormats.thumbnail,
                                          vLinks: downloadManager.mediaFormats.urls,
                                          vDuration: downloadManager.mediaFormats.duration,
                                          vSizeModel: downloadManager.mediaFormats.filesizes,
                                          vMediaType: downloadManager.mediaFormats.vcodeces,
                                          vResolution: downloadManager.mediaFormats.notes
                                      })

        }
        onInvalidPlaylistUrl: {
            PopupUtils.open(invalidPlayListURLWarning);
        }
    }

    Component {
        id: invalidPlayListURLWarning
        Dialog {
            id: dialogue
            title: i18n.tr("Invalid Playlist URL!")
            text: i18n.tr("Please provide a link with valid list argument.")
            Keys.onPressed: PopupUtils.close(dialogue)
            Button {
                text: i18n.tr("OK")
                onClicked: PopupUtils.close(dialogue)
            }
        }
    }

    Component {
        id: invalidURLWarning
        Dialog {
            id: dialogue
            title: i18n.tr("Invalid URL!")
            text: i18n.tr("Please provide a valid video link.")
            Keys.onPressed: PopupUtils.close(dialogue)
            Button {
                text: i18n.tr("OK")
                onClicked: PopupUtils.close(dialogue)
            }
        }
    }

    Page {
        id: mainPage
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: 'RAVEN Downloader'
        }

        function toggleBlankPage() {
            if (downloadItemsContainer.visible === false) {
                blankDownloadPage.visible = false;
                downloadItemsContainer.visible = true;
            } else {
                downloadItemsContainer.visible = false;
                blankDownloadPage.visible = true;
            }
        }

        Component.onCompleted: {
            width = searchBarLayout.implicitWidth + 2 * margin
            height = searchBarLayout.implicitHeight + 2 * margin
            toggleBlankPage();
        }


        ColumnLayout {
            id: searchBarLayout
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
                    Layout.fillWidth: true

                    height:  units.gu(14)
                    width: parent.width

                    RowLayout {
                        id: rowLayout
                        anchors.fill: parent
                        anchors.margins: units.gu(3)
                        width: parent.width
                        TextField {
                            id: urlContainer
                            Layout.fillWidth: true
                            placeholderText: i18n.tr("Put YouTube video or playlist URL here")
                            Keys.onReturnPressed: urlHandler(urlContainer.text, donwloadType.index)
                        }
                        CustomComboPopup {
                            id: donwloadType
                            heading: i18n.tr("Select download type")
                            defaultValue: true
                            dropdownModel: [i18n.tr("single video"), i18n.tr("playlist")]
                        }

                        Button {
                            id: submitButton
                            text: i18n.tr("Submit")
                            onClicked: urlHandler(urlContainer.text, donwloadType.index)
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
                    ListModel {
                        id: downloadItemsModel
                        dynamicRoles: true
                    }

                    ListView {
                        id: downloadItems
                        anchors {
                            top: downloadContainerHeading.bottom
                            bottom: parent.bottom
                            right: parent.right
                            left: parent.left
                        }

                        model: downloadItemsModel
                        delegate: MediaItem {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: units.gu(20)
                            videoTitle: vTitle
                            thumbnail: vThumbnail
                            downloadLinks: vLinks
                            duration: vDuration
                            sizeModel: vSizeModel
                            mediaTypeModel: vMediaType
                            resolutionModel: vResolution
                        }
                    }
                }
            }
        }

        // empty page while no downloads
        ColumnLayout {
            id: blankDownloadPage
            visible: false
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
                text: i18n.tr('No Downloads!')
                font.pixelSize: units.gu(3)
            }

            Item {
                Layout.fillHeight: true
            }
        }


        BottomEdge {
            id: bottomEdge
            height: parent.height - units.gu(20)
            hint.text: i18n.tr("Spwipe")
            contentComponent: Rectangle {
                width: bottomEdge.width
                height: bottomEdge.height
//                color: bottomEdge.activeRegion ? bottomEdge.activeRegion.color : LomiriColors.green
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
