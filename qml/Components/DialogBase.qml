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
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3

/**
 * Base dialog component with customizable buttons
 * Reduces boilerplate for simple dialogs
 */
Dialog {
    id: baseDialog
    
    property alias dialogTitle: baseDialog.title
    property alias dialogText: baseDialog.text
    property var buttons: ["OK"]
    property var buttonCallbacks: []
    
    signal buttonClicked(int index)
    
    Repeater {
        model: buttons
        Button {
            text: modelData
            onClicked: {
                if (buttonCallbacks[index]) {
                    buttonCallbacks[index]()
                }
                buttonClicked(index)
                PopupUtils.close(baseDialog)
            }
        }
    }
}
