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

import QtQml 2.2
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import Lomiri.Components.Pickers 1.3
import Lomiri.Components.ListItems 1.3
import Lomiri.Content 1.1

import "Components"

Page {
    header: PageHeader {
        id: settingsPageHeader
        title: i18n.tr("Settings")
    }

    Flickable {
        id: mainScroll
        anchors.top: settingsPageHeader.bottom
        contentWidth: parent.width
        contentHeight: parent.height
        ScrollBar.vertical: ScrollBar { }

        Column {
            //            spacing: units.gu(2)
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                left: parent.left
            }

            ListItem {
                objectName: "setDesktopMode"

                ListItemLayout {
                    title.text: i18n.tr("Select download location")
                    CheckBox {
                        id: setDesktopModeCheckbox
                        SlotsLayout.position: SlotsLayout.Trailing
                        onTriggered: settingsObject.setDesktopMode = checked
                    }
                }

                Binding {
                    target: setDesktopModeCheckbox
                    property: "checked"
                    //                    value: settingsObject.setDesktopMode
                }
            }
            ListItem {
                objectName: "setDesktopMode"
                ListItemLayout {
                    title.text: i18n.tr("/home/phablet/Downloads")
                    enabled: setDesktopModeCheckbox.checked
                    CheckBox {
                        id: setDesktopModeCheckbox2
                        SlotsLayout.position: SlotsLayout.Trailing
                        onTriggered: settingsObject.setDesktopMode = checked
                    }
                }

                Binding {
                    target: setDesktopModeCheckbox2
                    property: "checked"
                    //                    value: settingsObject.setDesktopMode
                }
            }

            ContentPeer {
                id: sourceSingle
                contentType: ContentType.All
                handler: ContentHandler.Source
                selectionType: ContentTransfer.Single
            }
        }
    }
}
