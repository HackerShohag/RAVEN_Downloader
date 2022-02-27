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

import QtQuick 2.0

Rectangle{
    property alias source: buttonIcon.source
    property alias name: buttonText.text

    id: pasteButton
    height: buttons.height
    width: buttonText.width
    color: 'white'
    radius: 5
    anchors.topMargin: 5
    anchors.leftMargin: 5
    anchors.bottomMargin: 5

        Image {
            id: buttonIcon
            height: 50
            width: 50
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
            anchors.top: buttonIcon.bottom
            id: buttonText
        }

    MouseArea {
        anchors.fill: parent
        hoverEnabled : true
        onClicked: {
            console.info( name + " clicked!")
            pasteButton.color = "white"
        }
        onPressed: {
            pasteButton.color = "grey"
        }
        onEntered: {
            pasteButton.border.width = 1
            pasteButton.border.color = 'grey'
        }
        onExited: {
            pasteButton.border.width = 0
            pasteButton.border.color = 'white'
        }
    }
}
