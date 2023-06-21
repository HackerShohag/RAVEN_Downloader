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
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Controls

GroupBox {
    id: boderShadow
    property string buttonValue
    property int    serialNumber
    property bool   animationEnabled: false
    property int    minimumWidth: 10
    property int    minimunHeight: 10

    visible: true
    opacity: animationEnabled ? 0 : 1

    background: Rectangle {
        Layout.minimumWidth: minimumWidth
        y: boderShadow.topPadding - boderShadow.bottomPadding
        width: parent.width
        height: parent.height - boderShadow.topPadding + boderShadow.bottomPadding
        color: "transparent"
        border.color: "transparent"
        radius: 0
    }

    NumberAnimation on y {
        running: animationEnabled
        from: -5
    }

    OpacityAnimator {
        target: boderShadow
        running: animationEnabled
        from: 0
        to: 1
        duration: 1000
    }

    Item {
        anchors.fill: parent
        layer.enabled: true
        anchors.margins: -2
        Rectangle {
            id: blurryShadowRect
            Layout.minimumWidth: minimumWidth
            anchors.centerIn: parent
            height: parent.height
            width: parent.width
            radius: 2
            color: "grey"
            border.color: "black"
            border.width: 1.75
            visible: false
        }

        FastBlur {
            anchors.fill: parent
            visible: true
            source: blurryShadowRect
            radius: 2
        }

        Rectangle {
            Layout.minimumWidth: minimumWidth
            height: parent.height - 3
            width: parent.width - 3
            anchors.centerIn: parent
            color: "white"
            radius: 1
        }
    }
}
