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
import QtQuick.Layouts 1.0
import Lomiri.Components 1.3

/**
 * Reusable settings checkbox row component
 * Provides consistent styling and layout for settings items
 */
RowLayout {
    id: settingsCheckbox
    
    // Public properties
    property string labelText: ""
    property bool checked: false
    property bool isEnabled: true
    property alias fontSize: label.font.pixelSize
    
    // Signals
    signal toggled(bool checked)
    
    // Layout
    spacing: units.gu(1)
    
    Text {
        id: label
        Layout.fillWidth: true
        elide: Text.ElideRight
        text: labelText
        color: isEnabled ? theme.palette.normal.backgroundText : LomiriColors.lightGrey
        font.pixelSize: units.gu(2)
    }
    
    CheckBox {
        id: checkbox
        Layout.alignment: Qt.AlignRight
        SlotsLayout.position: SlotsLayout.Trailing
        enabled: isEnabled
        checked: settingsCheckbox.checked
        
        onTriggered: {
            settingsCheckbox.toggled(checked)
        }
    }
    
    // Sync external changes
    onCheckedChanged: {
        if (checkbox.checked !== checked) {
            checkbox.checked = checked
        }
    }
}
