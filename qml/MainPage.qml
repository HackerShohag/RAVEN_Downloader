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

Window {
    width: 400
    height: 500
    visible: true
    title: qsTr("RAVEN Downloader")
    Item {
        id: buttons
        height: 70
        Rectangle{
            id: buttons1
            height: children.height
            width: children.width

            anchors {
                left: parent.left
                top: parent.top
                topMargin: 5
                leftMargin: 5
            }

            Image {
                id: icon1
                source: "icons/paste_button.png"
                height: 50
                width: 50
                anchors {
                    top: parent.top
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.info("image clicked!")
                }
            }
            Text {
                anchors.top: icon1.bottom
                anchors.left: parent.left
                text: qsTr("Paste Button")
            }
        }
    }

    RowLayout {
        id: urlContainer
        anchors {
            left: parent.left
            right: parent.right
            top: buttons.bottom
            topMargin: 5
            leftMargin: 5
            rightMargin: 5
        }
        TextField {
            id: urlField
            Layout.fillWidth: true

            placeholderText: qsTr("Enter your link")
            focus: true
        }
        Button {
            id: submitButton

            highlighted: true
            text: "Submit"
            onClicked: console.info("SubmitButton clicked!")
        }
    }
}
