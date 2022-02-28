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

import QtQuick 2.4
import QtQml
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts

ApplicationWindow {
    width: 400
    height: 500
    visible: true
    title: qsTr("RAVEN Downloader")
    RowLayout {
            id: buttonsUser
            height: 10
            spacing: 5
            Layout.topMargin: 5
            Layout.leftMargin: 5
            Layout.rightMargin: 5
            anchors {
            right: parent.right
            rightMargin: 5
            }
        HeaderButton {
            source: "icons/history_button.svg"
            name: "History"
        }
        HeaderButton {
            source: "icons/help_button.svg"
            name: "Need Help?"
        }
        HeaderButton {
            source: "icons/about_button.svg"
            name: "Credits"
        }
     }

    RowLayout {
        id: urlContainer
        visible: true
        anchors {
            left: parent.left
            right: parent.right
            top: buttonsUser.bottom
            topMargin: 50
            leftMargin: 5
            rightMargin: 5
        }

        //Paste button section
        Item {
                id: addButton
                width: 25
                height: 25
                signal clicked
                Image {
                    id: pasteImage
                    anchors.fill: parent
                    source: "icons/paste_button.svg"
                    fillMode: Image.PreserveAspectFit
                    Button {
                        width: 20
                        height: 20
                        opacity: 0
                        onClicked: console.info("Paste Button clicked!")
                    }
               }
        }
        TextField {
            id: urlField
            Layout.fillWidth: true
            placeholderText: qsTr("Enter your link")
            focus: true
            font.family: "Tahoma"
            font.italic: true
        }
        Button {
            id: submitButton
            highlighted: true
            text: "Download"
            onClicked: console.info("SubmitButton clicked!")
        }
    }
}
