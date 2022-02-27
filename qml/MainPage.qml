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
        id: urlContainer
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
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
            //onClicked:
        }
    }
}
