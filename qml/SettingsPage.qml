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
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.2
import Qt.labs.settings 1.0
import Lomiri.Components 1.3
import Lomiri.Components.ListItems 1.3

import "Components"

Page { 
    id: settingsPageRoot
    
    // Local Settings object - needed because SettingsPage is loaded via BottomEdge contentUrl
    // and doesn't have access to MainPage's generalSettings
    Settings {
        id: localSettings
        category: "GeneralSettings"
        
        property string themeName: "Lomiri.Components.Themes.Ambiance"
        property bool downloadSubtitle: false
        property bool downloadCaption: false
        property bool embeddedSubtitle: false
        property bool autoDownload: false
    }

    property var downloadLocationModel: [
        "Downloads (/home/phablet/Downloads)",
        "Documents (/home/phablet/Documents)",
        "Videos (/home/phablet/Videos)"
    ]

    property var themeModel: [
        i18n.tr("System theme"),
        i18n.tr("Ambiance theme"),
        i18n.tr("Suru-dark theme")
    ]

    function getDownloadLocation (data) {
        return data.split(" ")[1].replace("(", "").replace(")", "");
    }

    function getIndexFromModel(data) {
        for (var i = 0; i < downloadLocationModel.length; i++) {
            if (downloadLocationModel[i].includes(data))
                return i;
        }
    }

    header: PageHeader {
        title: i18n.tr("Settings")
    }

    Flickable {
        clip: true
        anchors {
            top: settingsPageRoot.header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        contentWidth: rectRoot.width
        contentHeight: rectRoot.height
        flickableDirection: Flickable.VerticalFlick
        ScrollBar.vertical: ScrollBar { visible: false }

        Rectangle {
            id: rectRoot
            width: settingsPageRoot.width > 0 ? settingsPageRoot.width : units.gu(50)
            height: childrenRect.height + units.gu(4)
            color: "transparent"

//            RowLayout {
//                id: donwloadLocationContainer
//                anchors{
//                    top: parent.top
//                    left: parent.left
//                    right: parent.right
//                    margins: units.gu(2)
//                }
//                Text {
//                    id: donwloadLocationLabel
//                    elide: Text.ElideRight
//                    Layout.fillWidth: true
//                    text: i18n.tr("Select download location")
//                    color: theme.palette.normal.backgroundText
//                    font.pixelSize: units.gu(2)
//                }
//                CheckBox {
//                    id: setDownloadLocationCheckbox
//                    Layout.alignment: Qt.AlignRight
//                    SlotsLayout.position: SlotsLayout.Trailing
//                    onTriggered: {
//                        generalSettings.setDownloadLocation = checked
//                        locationSelector.expanded = false
//                    }
//                }
//                Binding {
//                    target: setDownloadLocationCheckbox
//                    property: "checked"
//                    value: generalSettings.setDownloadLocation
//                }
//            }

//            OptionSelector {
//                id: locationSelector
//                model: downloadLocationModel
//                enabled: setDownloadLocationCheckbox.checked
//                anchors{
//                    top: donwloadLocationContainer.bottom
//                    topMargin: units.gu(1)
//                    left: parent.left
//                    leftMargin: units.gu(2)
//                    right: parent.right
//                    rightMargin: units.gu(2)
//                }
//                onSelectedIndexChanged: generalSettings.customDownloadLocation = getDownloadLocation(downloadLocationModel[locationSelector.selectedIndex]);
//            }
//            Binding {
//                target: locationSelector
//                property: "selectedIndex"
//                value: getIndexFromModel(generalSettings.customDownloadLocation)
//            }

            SettingsCheckbox {
                id: subtitleCheckboxContainer
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }
                labelText: i18n.tr("Download available subtitles")
                checked: localSettings.downloadSubtitle
                onToggled: {
                    localSettings.downloadSubtitle = checked
                    localSettings.downloadCaption = checked
                    localSettings.embeddedSubtitle = checked
                }
            }

            ColumnLayout {
                id: subCapContainer
                anchors {
                    top: subtitleCheckboxContainer.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: units.gu(1)
                    leftMargin: units.gu(3)
                    rightMargin: units.gu(2)
                    bottomMargin: units.gu(1)
                }

                SettingsCheckbox {
                    id: captionCheckbox
                    Layout.fillWidth: true
                    labelText: i18n.tr("Download captions (If subtitle unavailable)")
                    checked: localSettings.downloadCaption
                    isEnabled: localSettings.downloadSubtitle
                    onToggled: {
                        localSettings.downloadCaption = checked
                    }
                }

                SettingsCheckbox {
                    id: embeddedSubtitleCheckbox
                    Layout.fillWidth: true
                    labelText: i18n.tr("Embed subtitles in files")
                    checked: localSettings.embeddedSubtitle
                    isEnabled: localSettings.downloadSubtitle
                    onToggled: {
                        localSettings.embeddedSubtitle = checked
                    }
                }
            }

            SettingsCheckbox {
                id: autoDownloadCheckbox
                anchors {
                    top: subCapContainer.bottom
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }
                labelText: i18n.tr("Auto Download (best format)")
                checked: localSettings.autoDownload
                onToggled: {
                    localSettings.autoDownload = checked
                }
            }

            ThinDivider {
                id: divider
                anchors {
                    margins: units.gu(2)
                    topMargin: units.gu(3)
                    top: autoDownloadCheckbox.bottom
                    right: parent.right
                    left: parent.left
                }
            }

            OptionSelector {
                id: themeSelector
                model: themeModel
                anchors {
                    top: divider.bottom
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }
                
                // Set initial index based on current theme
                Component.onCompleted: {
                    if (localSettings.themeName === "Lomiri.Components.Themes.SuruDark") {
                        selectedIndex = 2
                    } else if (localSettings.themeName === "Lomiri.Components.Themes.Ambiance") {
                        selectedIndex = 1
                    } else {
                        selectedIndex = 0 // System theme
                    }
                }
                
                onSelectedIndexChanged: {
                    // Use switch or proper if-else-if chain to avoid logic bugs
                    if (selectedIndex === 0) {
                        // System theme - use default Ambiance
                        localSettings.themeName = "Lomiri.Components.Themes.Ambiance"
                    } else if (selectedIndex === 1) {
                        // Ambiance theme
                        localSettings.themeName = "Lomiri.Components.Themes.Ambiance"
                    } else if (selectedIndex === 2) {
                        // Suru-dark theme
                        localSettings.themeName = "Lomiri.Components.Themes.SuruDark"
                    }
                }
            }

            LomiriButton {
                id: historyClearButton
                anchors{
                    top: themeSelector.bottom
                    topMargin: units.gu(2)
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                }
                iconName: "delete"
                text: i18n.tr("Clear All History")
                colorBut: LomiriColors.red
                colorButText: "white"
                onClicked: {
                    downloadItemsModel.clear();
                    mainPage.toggleBlankPage();
                }
            }
        }
    }
}
