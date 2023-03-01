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
import QtQuick.Controls 2.2
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3

Button {
    id: dropdown

    property var dropdownModel
    property string heading
    property int index
    property bool defaultValue: false

    color: "white"
    text: defaultValue ? dropdownModel[0] : heading
    onClicked: PopupUtils.open(invalidURLWarning)

    Component {
        id: invalidURLWarning
        Dialog {
            id: dialogue
            title: heading
            Keys.onPressed: PopupUtils.close(dialogue)
            Repeater {
                model: dropdownModel ? dropdownModel.length : 0
                Button {
                    text: dropdownModel[modelData]
                    onClicked: {
                        dropdown.text = text;
                        dropdown.index = modelData
                        onClicked: PopupUtils.close(dialogue)
                    }
                }
            }
        }
    }
}
