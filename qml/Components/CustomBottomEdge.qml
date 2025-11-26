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

import QtQuick 2.4
import Lomiri.Components 1.3

BottomEdge {
    id: bottomEdge

    height: parent ? parent.height : 0
    hint.text: i18n.tr("Swipe for Settings")
    contentUrl: Qt.resolvedUrl("../SettingsPage.qml")

    preloadContent: false

    Timer {
        interval: 1
        repeat: false
        running: true
        onTriggered: bottomEdge.preloadContent = true
    }

    Binding {
        target: bottomEdge.contentItem
        property: "width"
        value: bottomEdge.width
    }

    Binding {
        target: bottomEdge.contentItem
        property: "height"
        value: bottomEdge.height
    }
}
