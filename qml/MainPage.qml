/*
 * Copyright (C) 2022 Team RAVEN
 *
 * Authors:
 *  Abdullah AL Shohag <HackerShohag@outlook.com>
 *  Mehedi Hasan Maruf <meek.er.007@protonmail.com>
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

import QtQuick
import QtQml
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts

ApplicationWindow {
    id: mainWindow
    width: 400
    height: 500
    visible: true
    title: qsTr("RAVEN Downloader")

    property var allLinks

    function paste() {
        console.log("Not defined yet")
    }
    function toggleToHistory() {
        console.log("Not defined yet too")
    }
    function toggleToSettings() {
        console.log("Not defined yet too too")
    }
    function toggleToHelp() {
        console.log("Not defined yet too too too")
    }
    function toggleToAbout() {
        console.log("Not defined yet too too too yet")
    }
    function getLinks(url){
        allLinks = downloadeng.getDownloadLinks(url)
        console.log(allLinks)
    }

    Item {
        id: header
        anchors.topMargin: 5

        height: childrenRect.height
        width: parent.width

        RowLayout {
            id: headerButtons

            height: 40
            width: parent.width
            
            HeaderButton {
                id: historyButton

                buttonWidth: parent.width / 4
                source: "icons/history_button.svg"
                name: "History"
                buttonFunction: mainWindow.toggleToHistory
            }
            HeaderButton {
                id: preferenceButton

                buttonWidth: parent.width / 4
                source: "icons/preference_button.png"
                name: "Preferences"
                buttonFunction: mainWindow.toggleToSettings
            }
            HeaderButton {
                id: settingsButton

                buttonWidth: parent.width / 4
                source: "icons/help_button.svg"
                name: "Help"
                buttonFunction: mainWindow.toggleToHelp
            }
            HeaderButton {
                id: aboutButton

                buttonWidth: parent.width / 4 - 8
                source: "icons/about_button.svg"
                name: "Credits"
                buttonFunction: mainWindow.toggleToAbout
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
            
            //Paste button section
            Rectangle {
                id: pasteButton
                width: 25
                height: 25
                color: "transparent"
                Image {
                    id: pasteImage
                    anchors.fill: parent
                    source: "icons/paste_button.svg"
                    fillMode: Image.PreserveAspectFit
                }
                MouseArea{
                    id: pasteButtonClickArea
                    anchors.fill: parent
                    width: 20
                    height: 20
                    opacity: 50
                    onClicked: mainWindow.paste()
                }
            }
            
            TextField {
                id: urlField
                Layout.fillWidth: true
                font.family: "Tahoma"
                font.italic: true

                placeholderText: qsTr("Enter your link")
                focus: true
            }
            Button {
                id: submitButton

                highlighted: true
                text: "Submit"
                onClicked: mainWindow.getLinks(urlField.text)
            }
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
//                source: "icons/paste_button.svg"
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
}
