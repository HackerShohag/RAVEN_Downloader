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

import QtQuick 2.7
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3

LomiriShape {
    property alias iconName: icon.name

    width: units.gu(4)
    height: units.gu(4)
    anchors {
        right: parent.right
        margins: units.gu(1)
        verticalCenter: parent.verticalCenter
    }

    Icon {
        id: icon
        anchors.fill: parent
        anchors.margins: units.gu(.5)
    }

    MouseArea {
        anchors.fill: parent
        enabled: true
        onClicked: {
            settingsPageLoader.active = true
            mainPage.active = false
        }

        onPressed: parent.color = "lightgrey";
        onReleased: parent.color = "white";
    }
}
