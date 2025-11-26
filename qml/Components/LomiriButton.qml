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

LomiriShape {
    signal clicked
    property string colorBut    : theme.palette.normal.base
    property string colorButText: theme.palette.selected.baseText
    property string radiusBorder:  "medium"
    property var    aspectBorder:  LomiriShape.DropShadow
    property alias  iconName    : icon.name
    property bool   iconOffset  : false
    property alias  text        : label.text

    backgroundColor : colorBut
    radius: radiusBorder
    aspect: aspectBorder
    height: units.gu(5)

    anchors.margins : units.gu(0.25);
    Icon {
        id: icon
        anchors{
            left: parent.left
            leftMargin: units.gu(1.5)
            top: parent.top
            topMargin: units.gu(1)
            bottom: parent.bottom
            bottomMargin: units.gu(1)
        }
        color: colorButText
        name : ""
        width: {
            if (icon.name==""){
                units.gu(0)
            } else {
                icon.height
            }
        }
        height: parent.height
    }

    Text {
        id: label
        font.pixelSize: units.gu(2)
        anchors{
            left: {if (iconOffset) {icon.right} else {parent.left}}
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        color: colorButText
        horizontalAlignment: Label.AlignHCenter
        verticalAlignment: Label.AlignVCenter
    }
    property int animopa
    Rectangle {
        color: theme.palette.normal.background
        anchors.fill: parent
        opacity: animopa/40
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: parent.clicked()
    }
    NumberAnimation on animopa {
        id: anim1w
        alwaysRunToEnd: true
        running: mouseArea.pressed
        from: 0; to: 20;
        onRunningChanged: {
        if (!running) {
            anim2w.start()
        }
        }
    }
    NumberAnimation on animopa {
        id: anim2w
        alwaysRunToEnd: true
        from: 20; to: 0;
    }
}

