/*
 * Copyright (C) 2025  Abdullah AL Shohag
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
import QtQuick.Controls 2.2
import Lomiri.Components 1.3

/**
 * Reusable loading overlay with busy indicator
 * Blocks user interaction while showing loading state
 */
Rectangle {
    id: overlay
    
    property alias running: busyIndicator.running
    property alias indicatorSize: busyIndicator.width
    
    anchors.fill: parent
    visible: running
    color: "#80000000"
    z: 1000
    
    MouseArea {
        anchors.fill: parent
        preventStealing: true
        hoverEnabled: true
    }
    
    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        width: units.gu(10)
        height: units.gu(10)
        running: false
    }
}
