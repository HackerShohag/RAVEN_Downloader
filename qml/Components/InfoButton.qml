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
import QtGraphicalEffects 1.0


GroupBox {
    id: infoButtonContainer
    
    property int buttonID: 0
    property string buttonValue: null

//    Layout.topMargin: units.gu(1)
    Layout.minimumWidth: units.gu(10)

    background: Rectangle {
        Layout.fillWidth: true
        y: infoButtonContainer.topPadding - infoButtonContainer.bottomPadding + units.gu(.8)
//        width: infoButtonValues.width + units.gu(2)
        height: parent.height - infoButtonContainer.topPadding + infoButtonContainer.bottomPadding - units.gu(1)
        color: "transparent"
        border.color: "#21be2b"
        radius: units.gu(1)
    }

    property var buttonNames:  ["duration_12x12.png", "size_12x12.png", "type.png", "resolution.png"]

    height: parent.height


    RowLayout {
        id: infoButtonValues
//        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
        Layout.fillWidth: true
        Image {
            source: "qrc:///assets/media/" + buttonNames[buttonID]
            fillMode: Image.Stretch
            height: units.gu(2)
            width: units.gu(3)
        }
        Text {
            Layout.fillWidth: true
            text: buttonValue
        }
    }
}
