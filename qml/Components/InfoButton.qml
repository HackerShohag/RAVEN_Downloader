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

import QtQuick.Layouts 1.3
import Lomiri.Components 1.3

Button {
    id: infoButtonContainer
    
    property int buttonID: 0
    property var buttonIcons:  ["duration.png", "size.png"]

    Layout.maximumWidth: units.gu(15)
    Layout.alignment: Qt.AlignLeft

    // enabled: false
    color: "white"
    iconSource: "qrc:///assets/media/" + buttonIcons[buttonID]
    opacity: 1
}
