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

import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2

GroupBox {
    id: boderShadow
    property string buttonValue
    property int    serialNumber
    property bool   animationEnabled: false
    property int    minimumWidth: units.gu(10)
    property int    minimunHeight: units.gu(10)

    visible: true
    opacity: animationEnabled ? 0 : 1

    background: Rectangle {
        Layout.minimumWidth: minimumWidth
        y: boderShadow.topPadding - boderShadow.bottomPadding
        width: parent.width
        height: parent.height - boderShadow.topPadding + boderShadow.bottomPadding
        color: "transparent"
        border.color: "transparent"
        radius: units.gu(0)
    }

    NumberAnimation on y {
        running: animationEnabled
        from: -units.gu(5)
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
        anchors.margins: -units.gu(2)
        Rectangle {
            id: blurryShadowRect
            Layout.minimumWidth: minimumWidth
            anchors.centerIn: parent
            height: parent.height
            width: parent.width
            radius: units.gu(2)
            color: "grey"
            border.color: theme.palette.normal.background
            border.width: units.gu(1.75)
            visible: false
        }

        FastBlur {
            anchors.fill: parent
            visible: theme.name == "Lomiri.Components.Themes.Ambiance" ? true : false
            source: blurryShadowRect
            radius: units.gu(2)
        }

        Rectangle {
            Layout.minimumWidth: minimumWidth
            height: parent.height - units.gu(3)
            width: parent.width - units.gu(3)
            anchors.centerIn: parent
            color: theme.palette.normal.foreground
            radius: units.gu(1)
        }
    }
}
