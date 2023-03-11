/*
 * Copyright (C) 2022 Team RAVEN
 *
 * Authors:
 *  Abdullah AL Shohag <HackerShohag@outlook.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.1
import QtGraphicalEffects 1.0
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import Lomiri.Components.ListItems 1.3
import Lomiri.DownloadManager 1.2

LayoutsCustom {
    id: gridBox

    property alias videoTitle: titleBox.text
    property alias thumbnail: thumbnailContainer.source
    property string duration
    property string videoLink: null

    property var vcodec: null
    property var resolutionModel: null
    property var videoExts: null
    property var videoFormats: null

    property var acodec: null
    property var audioExts: null
    property var audioFormats: null
    property var audioBitrate: null

    property var sizeModel: null
    property alias progress: progressBar.value
    property int indexID

    property var downloadUnavailable: resolutionModel === null && vcodec === null ? true : false
    property var comboHeading: [ i18n.tr("select audio"), i18n.tr("select resolution") ]

    function isDownloadValid(size, resolution) {
        console.log("Size: " + size);
        console.log("Res: " + resolution)
        return true
    }

    Component {
        id: invalidDownloadWarning
        Dialog {
            id: dialogue
            title: i18n.tr("Download Invalid!")
            text: i18n.tr("Please refresh download link.")
            Button {
                text: "OK"
                onClicked: PopupUtils.close(dialogue)
            }
        }
    }

    height: gridLayout.height
    width: gridLayout.width
    animationEnabled: true

    Layout.fillWidth: true
    Layout.minimumWidth: gridLayout.Layout.minimumWidth

    GridLayout {
        id: gridLayout
        rows: 3
        flow: GridLayout.TopToBottom
        anchors.fill: parent
        anchors.margins: units.gu(3)

        Image {
            id: thumbnailContainer
            Layout.preferredWidth: units.gu(10)

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: thumbnailContainer.width
                    height: thumbnailContainer.height
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        radius: units.gu(1)
                    }
                }
            }

            BusyIndicator {
                anchors.fill: parent
                padding: units.gu(2)
                running: thumbnailContainer.status === Image.Loading
            }

            source: "qrc:///assets/placeholder-video.png"
            Layout.rowSpan: 3
            Layout.fillHeight: true
            Layout.minimumWidth: units.gu(20)
            Layout.maximumWidth: units.gu(25)
        }

        RowLayout {
            Label {
                id: titleBox
                font.bold: true
                elide: Label.ElideRight
                Layout.fillWidth: true
            }
        }
        RowLayout {
            Layout.fillWidth: true
            CustomProgressBar {
                id: progressBar
                Layout.fillWidth: true
            }
            Label {
                text: progressBar.value * 100 + "%"
                font.pixelSize: 18
                font.bold: true
            }
        }
        RowLayout {
            Layout.fillWidth: true

            InfoButton {
                id: durationButton
                Layout.fillWidth: true
                buttonID: 0
                text: duration ? duration : i18n.tr("unknown")
            }

            InfoButton {
                id: sizeButton
                Layout.fillWidth: true
                buttonID: 1
                text: sizeModel && (resolutionPopup.text !== comboHeading[1]) ? sizeModel[resolutionPopup.index] : i18n.tr("unknown")
                enabled: sizeModel ? true : false
            }

            CustomComboPopup {
                id: audioPopup
                Layout.fillWidth: true
                heading: comboHeading[0]
                enabled: downloadUnavailable ? false : true
                multipleModel: true
                dropdownModel: audioExts
                dropdownModel2: acodec
                dropdownModel3: audioBitrate
            }

            CustomComboPopup {
                id: resolutionPopup
                Layout.fillWidth: true
                heading: comboHeading[1]
                enabled: downloadUnavailable ? false : true
                multipleModel: true
                dropdownModel: resolutionModel
                dropdownModel2: videoExts
                dropdownModel3: vcodec
            }

            Button {
                id: downloadButton
                enabled: downloadUnavailable ? false : true
                text: i18n.tr("Download")
                onClicked: isDownloadValid(audioPopup.text, resolutionPopup.text) ? downloadManager.actionDownload(videoLink, audioFormats[audioPopup.index] + "+" + videoFormats[resolutionPopup.index], indexID) : PopupUtils.open(invalidDownloadWarning)
            }
            SingleDownload {
                id: single
                onFinished: console.log()
            }
        }
    }
}
