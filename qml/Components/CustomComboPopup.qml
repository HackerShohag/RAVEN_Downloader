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

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: dropdown

    property int popupHeightIndex
    property int index

    property var itemModelOne: null
    property var itemModelTwo: null
    property var itemModelThree: null

    text: "Codecs"

    onClicked: {
        popup.open()
    }

    Popup {
        id: popup

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0 }
        }

        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0 }
        }

        x: -110 - dropdown.x + window.width * 0.1
        y: window.header.y - 130 - 100 * dropdown.popupHeightIndex + window.height * 0.1
        anchors.centerIn: selectionDialog
        width: window.width * 0.8
        height: window.height * 0.8
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        Flickable {
            id: mainScroll
            anchors.fill: parent
            clip: true
            height: parent.height
            width: parent.width
            contentHeight: Math.max(height, columnLayout.implicitHeight)

            ColumnLayout {
                id: columnLayout
                anchors.fill: parent

                Repeater {
                    width: parent.width
                    model: itemModelOne.length
                    Button {
                        Layout.fillWidth: true
                        text: itemModelOne[index] + " - " + itemModelTwo[index] + " (" + itemModelThree[index] + ")"
                        onClicked: {
                            dropdown.text = itemModelOne[index]
                            popup.close()
                        }
                    }
                }
            }
        }
    }
}
