/*
 * Copyright 2014-2016 Canonical Ltd.
 *
 * This file is part of morph-browser.
 *
 * morph-browser is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * morph-browser is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

//import QtQuick 2.4
//import Lomiri.Components 1.3

//ProgressBar {
//    height: units.dp(3)
//    showProgressPercentage: false
//    minimumValue: 0
//    maximumValue: 100
//}

import QtQuick 2.7
import QtQuick.Controls 2.2

ProgressBar {
        id: control
        value: 0.5

        background: Rectangle {
            implicitWidth: 200
            implicitHeight: 20
            color: "#4c4c4c"
            radius: 8
        }

        contentItem: Item {
            implicitWidth: 200
            implicitHeight: 20

            Rectangle {
                width: control.visualPosition * parent.width
                height: parent.height
                radius: 8
                color: "#21be9b"
            }
        }
    }
