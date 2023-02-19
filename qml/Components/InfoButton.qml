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
    id: infoButtonParent
    Layout.fillWidth: true
    Layout.minimumWidth: units.gu(10)

    background: Rectangle {
        y: infoButtonParent.topPadding - infoButtonParent.bottomPadding
        width: parent.width
        height: parent.height - infoButtonParent.topPadding + infoButtonParent.bottomPadding
        color: "transparent"
        border.color: "#21be2b"
        radius: units.gu(1)
    }

    property int buttonID: 0
    property string buttonValue: null

    property var buttonNames:  ["duration.png", "size.png", "type.png", "resolution.png"]

    height: parent.height
    // radius: units.gu(.3)

    RowLayout {
        Image {
            source: "qrc:///icons/media/" + buttonNames[buttonID]
            fillMode: Image.Stretch
            height: units.gu(1)
            width: units.gu(1)
        }
        Text {
            text: buttonValue
        }
    }
}