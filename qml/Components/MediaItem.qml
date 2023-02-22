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
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import Lomiri.Components.ListItems 1.3

LayoutsCustom {
    id: gridBox

    property string videoTitle: "<unknown video title>"
    property alias thumbnail: thumbnailContainer.source
    property var sizeAndDuration: null
    property var mediaTypeModel: null
    property var resolutionModel: null

    property var downloadUnavailable: resolutionModel === null && mediaTypeModel === null ? true : false
    property var comboHeading: [ "select type", "select resolution" ]
    property var models: [mediaTypeModel, resolutionModel]

    function isDownloadValid(size, resolution) {
        console.log("SizeL; " + size);
        console.log("Res; " + resolution)
        return true
    }

    Component {
         id: invalidDownloadWarning
         Dialog {
             id: dialogue
             title: "Download Invalid!"
             text: "Please refresh download link."
             Button {
                 text: "OK"
                 onClicked: PopupUtils.close(dialogue)
             }
         }
    }

    height: gridLayout.height
    width: gridLayout.width

    Layout.fillWidth: true
    Layout.minimumWidth: gridLayout.Layout.minimumWidth

    background: Rectangle {
        y: gridBox.topPadding - gridBox.bottomPadding
        width: parent.width
        height: parent.height - gridBox.topPadding + gridBox.bottomPadding
        color: "transparent"
        border.color: "transparent"
        radius: units.gu(1)
    }


    GridLayout {
        id: gridLayout
        rows: 3
        flow: GridLayout.TopToBottom
        anchors.fill: parent
        anchors.margins: units.gu(3)

        Image {
            id: thumbnailContainer
            Layout.preferredWidth: units.gu(10)
            fillMode: Image.PreserveAspectCrop

            source: "qrc:///assets/placeholder-video.png"
            Layout.rowSpan: 3
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.minimumHeight: units.gu(6)
            Layout.minimumWidth: units.gu(10)

        }

        RowLayout {
            Label {
                text: videoTitle
                font.bold: true
                Layout.fillWidth: true
            }
        }
        RowLayout {
            Layout.fillWidth: true
             CustomProgressBar {
                 id: progressBar
                 Layout.fillWidth: true
                 value: 0.2
             }
             Label {
                 text: progressBar.value * 100 + "%"
                 font.pixelSize: 18
                 font.bold: true
             }
        }
        RowLayout {
            Layout.fillWidth: true
            Repeater {
                model: 2
                InfoButton {
                    Layout.fillWidth: true
                    buttonID: modelData
                    buttonValue: sizeAndDuration ? sizeAndDuration[modelData] : "unknown"
                }
            }

            Repeater {
                id: comboMenuRepeater
                model: 2
                CustomComboButton {
                    Layout.fillWidth: true
                    text: comboHeading[modelData]
                    enabled: downloadUnavailable ? false : true
                    dropdownModel: models[modelData]
                }
            }

            Button {
                id: downloadButton
                enabled: downloadUnavailable ? false : true
                text: i18n.tr("Download")
                onClicked: isDownloadValid(comboMenuRepeater.itemAt(0).text, comboMenuRepeater.itemAt(1).text) ? PopupUtils.open(invalidDownloadWarning) : (downloadButton.text = "Gotcha")
            }
        }
    }
}
