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
    RowLayout {
        id: buttons
        height: 70
        spacing: 20
        Layout.topMargin: 5
        Layout.leftMargin: 5
        Layout.rightMargin: 5
        HeaderButton {
            source: "icons/paste_button.svg"
            name: "Paste Link"
        }
        HeaderButton {
            source: "icons/history_button.png"
            name: "History"
        }
        HeaderButton {
            source: "icons/help_button.png"
            name: "Need Help?"
        }
        HeaderButton {
            source: "icons/about_button.png"
            name: "Credits"
        }
    }

    RowLayout {
        id: urlContainer
        anchors {
            left: parent.left
            right: parent.right
            top: buttons.bottom
            topMargin: 10
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
