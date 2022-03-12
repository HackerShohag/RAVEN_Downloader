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

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'raven.downloader.shohag'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    Page {
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr('RAVEN Downloader')
        }

        ColumnLayout {
            spacing: units.gu(2)
            anchors {
                margins: units.gu(2)
                top: header.bottom
                left: parent.left
                right: parent.right
                //bottom: parent.bottom
            }

        RowLayout {
            id: headerButtons

            height: 70
            width: parent.width
            
            HeaderButton {
                id: historyButton

                //buttonWidth: parent.width / 4
                source: "qrc:/icons/history_button.svg"
                name: "History"
                buttonFunction: root.toggleToHistory
            }
        }

        RowLayout {
            id: urlContainer
            anchors {
                left: parent.left
                right: parent.right
                top: headerButtons.bottom
                topMargin: 10
                leftMargin: 5
                rightMargin: 5
            }
            
            TextField {
                id: urlField
                Layout.fillWidth: true
                font.family: "Tahoma"
                font.italic: true

                placeholderText: qsTr("Enter your link")
                focus: true
                Keys.onReturnPressed: root.getLinksQML(urlField.text)

            }
            Button {
                id: submitButton

                highlighted: true
                text: "Submit"
                onClicked: root.getLinksQML(urlField.text)
            }
        }

    //    Rectangle {
    //        anchors {
    //            top: header.bottom
    //            margins: 5
    //        }
    //        height: parent.height - header.height
    //        width: parent.width
    //        color: "red"

    //        Flickable {
    //            id: flickable
    //            width: parent.width
    //            height: parent.height
    //            contentWidth: parent.width
    //            contentHeight: image.height

    //            Image {
    //                id: image
    //                source: "qrc:/icons/paste_button.svg"
    //            }
    //        }

    //        Rectangle {
    //            id: scrollbar
    //            anchors.right: flickable.right
    //            y: flickable.visibleArea.yPosition * flickable.height
    //            width: 10
    //            height: flickable.visibleArea.heightRatio * flickable.height
    //            color: "black"
    //        }
    //    }

            Button {
                Layout.alignment: Qt.AlignHCenter
                text: i18n.tr('Press here!')
                onClicked: console.log(YoutubeDL.getUrl('https://www.youtube.com/watch?v=YuIIjLr6vUA'))
            }

        }
    }
}
