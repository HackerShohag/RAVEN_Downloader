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

import QtQuick
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects


Rectangle {
    id: itemContainer

    property int itemIndex


    property alias  videoTitle          : titleBox.text
    property alias  thumbnail           : thumbnailContainer.source
    property string duration
    property string videoLink

    property var    vcodec              : null
    property var    resolutionModel     : null
    property var    videoExts           : null
    property var    videoFormats        : null

    property var    acodec              : null
    property var    audioExts           : null
    property var    audioFormats        : null
    property var    audioBitrate        : null
    property var    audioSizes          : null

    property var    langs               : null
    property var    langIds             : null

    property var    sizeModel           : null
    property alias  videoProgress       : videoProgressBar.value
    property int    indexID

    property alias  videoIndex          : resolutionPopup.index
    property alias  audioIndex          : audioPopup.index

    property bool   downloadUnavailable : false
//    property var    downloadUnavailable : resolutionModel === null && vcodec === null ? true : false
    property var    comboHeading        : [ "select audio", "select language", "select resolution" ]

    anchors.margins: 5
    radius: 10

    color: "#f5f7f7"

    GridLayout {
        id: gridLayout
        rows: 3
        flow: GridLayout.TopToBottom
        anchors.fill: parent
        anchors.margins: 2


        Image {
            id: thumbnailContainer

            Layout.rowSpan: 3
            Layout.fillHeight: true
            Layout.minimumWidth: 50
            Layout.maximumWidth: 100

            width: parent.width / 3

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: thumbnailContainer.width
                    height: thumbnailContainer.height
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        radius: 10
                    }
                }
            }

            BusyIndicator {
                anchors.fill: parent
                padding: 2
                running: thumbnailContainer.status === Image.Loading
            }

            source: "qrc:///images/qt-logo.png"
        }

        RowLayout {
            Label {
                id: titleBox
                text: "Youtube Video Title 1"
                font.bold: true
                elide: Label.ElideRight
                Layout.fillWidth: true
            }
        }

        RowLayout {
            Layout.fillWidth: true

            CustomProgressBar {
                id: videoProgressBar
                Layout.fillWidth: true
                value: .3
            }
            Label {
                text: videoProgressBar.value * 100 + "%"
                // color: theme.palette.normal.backgroundText
                font.pixelSize: 18
                font.bold: true
            }
        }

        RowLayout {
            Layout.fillWidth: true

//            InfoButton {
//                id: durationButton
//                Layout.fillWidth: true
//                buttonID: 0
//                text: duration ? duration : "unknown"
//            }

//            Button {
//                id: sizeButton
//                Layout.preferredWidth: 30
//                Layout.minimumWidth: 30
//                Layout.fillWidth: true
////                color: LomiriColors.lightGrey
////                text: sizeModel && (resolutionPopup.text !== comboHeading[2]) ? sizeModel[resolutionPopup.index] + audioSizes[audioPopup.index] + "MiB" : "unknown"
//                text: "MiB"
////                enabled: sizeModel ? true : false
//                enabled: true
//            }

            CustomComboPopup {
                id: audioPopup
                Layout.fillWidth: true
                Layout.minimumWidth: 10
                popupHeightIndex: itemIndex
                text: comboHeading[0]
                enabled: downloadUnavailable ? false : true

//                multipleModel: true
//                dropdownModel: audioExts
//                dropdownModel2: acodec
//                dropdownModel3: audioBitrate
            }

//            CustomComboPopup {
//                id: languagePopup
//                Layout.fillWidth: true
//                Layout.minimumWidth: 10
//                visible: langs.length != 0
//                heading: comboHeading[1]
//                enabled: downloadUnavailable ? false : true
//                dropdownModel: langs
//            }

            CustomComboPopup {
                id: resolutionPopup
                Layout.fillWidth: true
                Layout.minimumWidth: 10
                popupHeightIndex: itemIndex
                text: comboHeading[2]
                enabled: downloadUnavailable ? false : true
//                multipleModel: true
//                dropdownModel: resolutionModel
//                dropdownModel2: videoExts
//                dropdownModel3: vcodec
            }

            Button {
                id: downloadButton
                enabled: downloadUnavailable ? false : true
                text: "Download"
                onClicked: {
                    isDownloadValid(audioPopup.text, resolutionPopup.text) ?
                                downloadManager.actionDownload(videoLink, getFormats()) :
                                PopupUtils.open(invalidDownloadWarning)
                }
            }
        }

    }
}
