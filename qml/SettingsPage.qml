/*  ImgItem.qml */
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import Qt.labs.settings 1.0
import Lomiri.Components 1.3
import Lomiri.Components.Themes 1.3
import Ubuntu.Components.ListItems 1.3
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

    Component.onCompleted: {
        console.log("General Settings: " + generalSettings.customDownloadLocation + ", index: " + getIndexFromModel(generalSettings.customDownloadLocation))
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
            color: theme.palette.normal.background

            RowLayout {
                id: donwloadLocationConatainer
                anchors{
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }
                Text {
                    id: donwloadLocationLabel
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    text: i18n.tr("Select download location")
                    color: theme.palette.normal.backgroundText
                    font.pixelSize: units.gu(2)
                }
                CheckBox {
                    id: setDownloadLocationCheckbox
                    Layout.alignment: Qt.AlignRight
                    SlotsLayout.position: SlotsLayout.Trailing
                    onTriggered: {
                        generalSettings.setDownloadLocation = checked
                        locationSelector.expanded = false
                    }
                }
                Binding {
                    target: setDownloadLocationCheckbox
                    property: "checked"
                    value: generalSettings.setDownloadLocation
                }
            }

            OptionSelector {
                id: locationSelector
                model: downloadLocationModel
                enabled: setDownloadLocationCheckbox.checked
                anchors{
                    top: donwloadLocationConatainer.bottom
                    topMargin: units.gu(1)
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                }
                onSelectedIndexChanged: generalSettings.customDownloadLocation = getDownloadLocation(downloadLocationModel[locationSelector.selectedIndex]);
            }
            Binding {
                target: locationSelector
                property: "selectedIndex"
                value: getIndexFromModel(generalSettings.customDownloadLocation)
            }

            RowLayout {
                id: subtitleCheckboxConatainer
                anchors{
                    top: locationSelector.bottom
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }
                Text {
                    id: subtitleCheckboxLabel
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: i18n.tr("Download available subtitles")
                    color: theme.palette.normal.backgroundText
                    font.pixelSize: units.gu(2)
                }
                CheckBox {
                    id: subtitleCheckbox
                    Layout.alignment: Qt.AlignRight
                    SlotsLayout.position: SlotsLayout.Trailing
                    onTriggered: generalSettings.downloadSubtitle = checked
                }
                Binding {
                    target: subtitleCheckbox
                    property: "checked"
                    value: generalSettings.downloadSubtitle
                }
            }

            RowLayout {
                id: captionConatainer
                anchors{
                    top: subtitleCheckboxConatainer.bottom
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }
                enabled: subtitleCheckbox.checked
                Text {
                    id: captionLabel
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: i18n.tr("Download autogenerated captions (if subtitle isn't available)")
                    color: enabled ? theme.palette.normal.backgroundText : LomiriColors.lightGrey
                    font.pixelSize: units.gu(2)
                }
                CheckBox {
                    id: captionCheckBox
                    Layout.alignment: Qt.AlignRight
                    SlotsLayout.position: SlotsLayout.Trailing
                    onTriggered: generalSettings.downloadCaption = checked
                }
                Binding {
                    target: captionCheckBox
                    property: "checked"
                    value: generalSettings.downloadCaption
                }
            }

            RowLayout {
                id: embeddedSubtitleConatainer
                anchors{
                    top: captionConatainer.bottom
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }
                enabled: subtitleCheckbox.checked
                Text {
                    id: embeddedSubtitleLabel
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: i18n.tr("Embed subtitles/captions in files")
                    color: enabled ? theme.palette.normal.backgroundText : LomiriColors.lightGrey
                    font.pixelSize: units.gu(2)
                }
                CheckBox {
                    id: embeddedSubtitle
                    Layout.alignment: Qt.AlignRight
                    SlotsLayout.position: SlotsLayout.Trailing
                    onTriggered: generalSettings.embeddedSubtitle = checked
                }
                Binding {
                    target: embeddedSubtitle
                    property: "checked"
                    value: generalSettings.embeddedSubtitle
                }
            }

            RowLayout {
                id: autoDownloadConatainer
                anchors{
                    top: embeddedSubtitleConatainer.bottom
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }
                Text {
                    id: autoDownloadLabel
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    text: i18n.tr("Auto Download (this will download the best format)")
                    color: theme.palette.normal.backgroundText
                    font.pixelSize: units.gu(2)
                }
                CheckBox {
                    id: setAutoDownloadCheckbox
                    Layout.alignment: Qt.AlignRight
                    SlotsLayout.position: SlotsLayout.Trailing
                    onTriggered: generalSettings.autoDownload = checked
                }
                Binding {
                    target: setAutoDownloadCheckbox
                    property: "checked"
                    value: generalSettings.autoDownload
                }
            }

            ThinDivider {
                id: divider
                anchors {
                    margins: units.gu(2)
                    topMargin: units.gu(3)
                    top: autoDownloadConatainer.bottom
                    right: parent.right
                    left: parent.left
                }
            }

            OptionSelector {
                id: themeSelector
                model: themeModel
                selectedIndex: 0

                text: i18n.tr("Select app theme")

                anchors{
                    top: divider.bottom
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
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
                    root.transmissionremove()
                }

            }
        }
    }
}
