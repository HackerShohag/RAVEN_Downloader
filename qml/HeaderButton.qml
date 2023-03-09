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
import QtQuick.Layouts

Rectangle{
    id: button

    property alias source: buttonIcon.source
    property alias name: buttonText.text
    property alias buttonWidth: button.width
    property var buttonFunction: null

    height: parent.height
    Layout.topMargin: 3
    Layout.leftMargin: 2
    Layout.rightMargin: 2
    color: clickArea.pressed ? 'grey' : 'white'
    radius: 5

    Image {
        id: buttonIcon

        fillMode: Image.Stretch
        height: 20
        width: 20
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Text {
        id: buttonText
        anchors.top: buttonIcon.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        hoverEnabled : true
        onClicked: {
            console.info( name + " clicked!")
            buttonFunction()
        }
        onEntered: {
            button.border.width = 1
        }
        onExited: {
            button.border.width = 0
        }
    }
}
