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
import Lomiri.Components 1.3
import Lomiri.Components.ListItems 1.3

import "Components"

Page { 
    id: settingsPageRoot

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
        anchors{
            top: settingsPageRoot.header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        contentWidth: rectRoot.width
        contentHeight: rectRoot.height
        flickableDirection: Flickable.VerticalFlick

        Rectangle {
            id: rectRoot
            width: root.width
            height: {childrenRect.height+units.gu(4)}
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
                checked: generalSettings.downloadSubtitle
                onToggled: {
                    generalSettings.downloadSubtitle = checked
                    generalSettings.downloadCaption = checked
                    generalSettings.embeddedSubtitle = checked
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
                    checked: generalSettings.downloadCaption
                    isEnabled: generalSettings.downloadSubtitle
                    onToggled: {
                        generalSettings.downloadCaption = checked
                    }
                }

                SettingsCheckbox {
                    id: embeddedSubtitleCheckbox
                    Layout.fillWidth: true
                    labelText: i18n.tr("Embed subtitles in files")
                    checked: generalSettings.embeddedSubtitle
                    isEnabled: generalSettings.downloadSubtitle
                    onToggled: {
                        generalSettings.embeddedSubtitle = checked
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
                checked: generalSettings.autoDownload
                onToggled: {
                    generalSettings.autoDownload = checked
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
                onSelectedIndexChanged: {
                    if (themeModel[selectedIndex] == "Ambiance theme")
                        generalSettings.theme = "Lomiri.Components.Themes.Ambiance"
                    if (themeModel[selectedIndex] == "Suru-dark theme")
                        generalSettings.theme = "Lomiri.Components.Themes.SuruDark"
                    else
                        generalSettings.theme = "Lomiri.Components.Themes.Ambiance"
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
