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

GroupBox {
    id: gridBox
    Layout.fillWidth: true
    Layout.minimumWidth: gridLayout.Layout.minimumWidth

    background: Rectangle {
        y: gridBox.topPadding - gridBox.bottomPadding
        width: parent.width
        height: parent.height - gridBox.topPadding + gridBox.bottomPadding
        color: "transparent"
        border.color: "#21be2b"
        radius: units.gu(1)
    }


    GridLayout {
        id: gridLayout
        rows: 3
        columns: 3
        flow: GridLayout.TopToBottom
        anchors.fill: parent

        Image {
            Layout.preferredWidth: units.gu(5)
            height: units.gu(3)
            fillMode: Image.Stretch
            
            source: "qrc:///assets/placeholder-video.png"
            Layout.rowSpan: 3
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.minimumHeight: units.gu(6)
            Layout.minimumWidth: units.gu(10)

        }

        RowLayout {
            Label {
                text: "Name of the YouTube video"
                font.pixelSize: 18
                font.bold: true
            }

        }
        RowLayout {
            ProgressBar {
                id: progressBar
                Layout.fillWidth: true
                value: 0.5
            }
            Label {
                text: progressBar.value * 100 + "%"
                font.pixelSize: 18
                font.bold: true
            }
        }
        RowLayout {
            InfoButton {
                buttonID: 0
                buttonValue: "3:01"
                Layout.fillWidth: true
            }
            InfoButton {
                buttonID: 1
                buttonValue: "56MB"
                Layout.fillWidth: true
            }
            ComboBox {
                width: 1
                model: [ "MP4", "MKV", "MP3" ]
            }
            ComboBox {
                width: 0
                model: [ "720p", "1080p", "1440p" ]
            }
            Button {
                highlighted: true
                text: i18n.tr("Download")
            }
        }
    }
}