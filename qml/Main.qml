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
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtGraphicalEffects 1.0
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import Lomiri.Content 1.1

import "Components"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'raven.downloader.shohag'
    automaticOrientation: true

    width: units.gu(100)
    height: units.gu(100)

    property int margin: units.gu(1)
    property string playListTitle

    property string entry
    property bool isPlaylist
    property int count: 0
    property var stringModel
    property bool separator: false

//    theme: ThemeSettings {
//        name: "Ubuntu.Components.Themes.SuruDark"
//    }

    Settings {
        id: generalSettings
        objectName: "GeneralSettings"

        property string myName

        property alias x: root.x
        property alias y: root.y
        property alias width: root.width
        property alias height: root.height

        property alias model: downloadItemsModel

        property bool setDownloadLocation: false
        property string customDownloadLocation: null
        property bool downloadSubtitle: false
        property bool downloadCaption: false
        property bool embeddedSubtitle: false
        property bool autoDownload: false
    }

    function listModelToString(){
        var datamodel = []
        for (var i = 0; i < downloadItemsModel.count; ++i){
            datamodel.push(downloadItemsModel.get(i))
        }
        var keysList = JSON.stringify(datamodel)
        keysList.replace("[","").replace("]","")
        console.log(keysList);
        downloadManager.saveListModelData(keysList);
    }

    function urlHandler(url, index) {
        if (index) {
            root.isPlaylist = true;
            if (!(downloadManager.isValidPlayListUrl(url))) {
                PopupUtils.open(invalidPlayListURLWarning);
                return ;
            }
            if (downloadItemsContainer.visible === false)
                mainPage.toggleBlankPage();
            downloadManager.actionSubmit(url, index);
            return ;
        }
        root.isPlaylist = false;
        if (downloadManager.isValidUrl(url)) {
            downloadManager.actionSubmit(url, index);
            return ;
        }
        PopupUtils.open(invalidURLWarning);
    }

    function objectToList(object) {
        stringModel = [];
        for (var i = 0; i < object.count; ++i){
            stringModel.push(object.get(i))
        }
        return stringModel;
    }

    function deformIndex(index) {
        return downloadItemsModel.count - index - 1;
    }

    Connections {
        target: downloadManager
        onFormatsUpdated: {
            if (downloadItemsContainer.visible === false)
                mainPage.toggleBlankPage();
//            console.log("formatsUpdated(): acodec: " + downloadManager.mediaFormats.acodeces)
//            console.log("formatsUpdated(): audio_ids: " + downloadManager.mediaFormats.audioFormatIds)
//            console.log("formatsUpdated(): languages: " + downloadManager.mediaFormats.languages)
            console.log("formatsUpdated(): audioSizes: " + downloadManager.mediaFormats.audioSizes)

            downloadItemsModel.append({
                                          vTitle: downloadManager.mediaFormats.title,
                                          vThumbnail: downloadManager.mediaFormats.thumbnail,
                                          vDuration: downloadManager.mediaFormats.duration,
                                          vID: downloadManager.mediaFormats.videoUrl,

                                          vCodec: downloadManager.mediaFormats.vcodeces,
                                          vResolutions: downloadManager.mediaFormats.notes,
                                          vVideoExts: downloadManager.mediaFormats.videoExtensions,
                                          vVideoFormats: downloadManager.mediaFormats.videoFormatIds,
                                          vVideoProgress: 0,

                                          aCodec: downloadManager.mediaFormats.acodeces,
                                          vAudioExts: downloadManager.mediaFormats.audioExtensions,
                                          vAudioFormats: downloadManager.mediaFormats.audioFormatIds,
                                          vABR: downloadManager.mediaFormats.audioBitrates,
                                          vAudioSizes: downloadManager.mediaFormats.audioSizes,
                                          vAudioProgress: 0,

//                                          vLangs: downloadManager.mediaFormats.languages,
//                                          vLangIds: downloadManager.mediaFormats.languageIds,

                                          videoIndex: null,
                                          audioIndex: null,

                                          vSizeModel: downloadManager.mediaFormats.filesizes,
                                          vIndex: count
                                      })
            count = count + 1;
            downloadItemsModel.move(0, 1, downloadItems.count-1)
        }

        onFinished: {
            console.log("playlistTitle: " + playlistTitle + " " + entries);
            root.playListTitle = playlistTitle;
            root.entry = entries;
            if (root.isPlaylist)
                PopupUtils.open(finishedPopup);
        }

        onListModelDataLoaded: {
            var jsonObject = JSON.parse(value);
            for (var i = 0; i < jsonObject.length; i++) {
//                console.log(jsonObject[i]);
                downloadItemsModel.append({
                                              vTitle: jsonObject[i].vTitle,
                                              vThumbnail: jsonObject[i].vThumbnail,
                                              vDuration: jsonObject[i].vDuration,
                                              vID: jsonObject[i].vID,

                                              vCodec: objectToList(jsonObject[i].vCodec),
                                              vResolutions: objectToList(jsonObject[i].vResolutions),
                                              vVideoExts: objectToList(jsonObject[i].vVideoExts),
                                              vVideoFormats: objectToList(jsonObject[i].vVideoFormats),
                                              vVideoProgress: objectToList(jsonObject[i].vVideoProgress),

                                              aCodec: objectToList(jsonObject[i].aCodec),
                                              vAudioExts: objectToList(jsonObject[i].vAudioExts),
                                              vAudioFormats: objectToList(jsonObject[i].vAudioFormats),
                                              vABR: objectToList(jsonObject[i].vABR),
                                              vAudioProgress: objectToList(jsonObject[i].vAudioProgress),
                                              vAudioSizes: objectToList(jsonObject[i].vAudioSizes),

                                              vLangs: objectToList(jsonObject[i].vLangs),
                                              vLangIds: objectToList(jsonObject[i].vLangIds),

                                              vSizeModel: objectToList(jsonObject[i].vSizeModel),
                                              vIndex: objectToList(jsonObject[i].vIndex)
                                          })
            }
        }
        onDownloadProgress: {
            downloadItemsModel.setProperty(deformIndex(indexID), "vVideoProgress", value/100);
        }

        onInvalidPlaylistUrl: {
            PopupUtils.open(invalidPlayListURLWarning);
        }
    }

    Component {
        id: invalidPlayListURLWarning
        WarningDialog {
            title: i18n.tr("Invalid Playlist URL!")
            text: i18n.tr("Please provide a link with valid list argument.")
        }
    }

    Component {
        id: finishedPopup
        WarningDialog {
            title: i18n.tr("Download Complete!")
            text: i18n.tr(root.entry + " video(s) from \"" + root.playListTitle + "\" playlist have been added.")
        }
    }

    Component {
        id: invalidURLWarning
        WarningDialog {
            title: i18n.tr("Invalid URL!")
            text: i18n.tr("Please provide a valid video link.")
        }
    }

    Page {
        id: mainPage
        anchors.fill: parent
        StateSaver.properties: "title"
        StateSaver.enabled: true

        header: PageHeader {
            id: header
            title: 'RAVEN Downloader'
        }

        function toggleBlankPage() {
            if (downloadItemsContainer.visible === false) {
                blankDownloadPage.visible = false;
                downloadItemsContainer.visible = true;
            } else {
                downloadItemsContainer.visible = false;
                blankDownloadPage.visible = true;
            }
        }

        Component.onCompleted: {
            width = searchBarLayout.implicitWidth + 2 * margin
            height = searchBarLayout.implicitHeight + 2 * margin
            var isLoaded = downloadManager.loadListModelData();
            if (isLoaded) toggleBlankPage();
            console.log("sizes: " + downloadManager.mediaFormats.sizes)
        }

        Component.onDestruction: {
            listModelToString();
            console.log('Destruction');
        }

        ColumnLayout {
            id: searchBarLayout
            anchors.topMargin: header.height /*+ root.margin*/
            anchors.fill: parent
            anchors.margins: root.margin
            anchors.bottom: bottomEdge.top

            Flickable {
                id: mainScroll
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: downloadItemsContainer.height + rowLayout.height + downloadContainerHeading.height + root.margin + units.gu(3)
                ScrollBar.vertical: ScrollBar { }

                LayoutsCustom {
                    id: inputPanel
                    Layout.fillWidth: true

                    height:  units.gu(14)
                    width: parent.width

                    RowLayout {
                        id: rowLayout
                        anchors.fill: parent
                        anchors.margins: units.gu(3)
                        width: parent.width
                        TextField {
                            id: urlContainer
                            Layout.fillWidth: true
                            placeholderText: i18n.tr("Put YouTube video or playlist URL here")
                            Keys.onReturnPressed: urlHandler(urlContainer.text, donwloadType.index)
                        }
                        CustomComboPopup {
                            id: donwloadType
                            heading: i18n.tr("Select download type")
                            defaultValue: true
                            dropdownModel: [i18n.tr("single video"), i18n.tr("playlist")]
                        }

                        Button {
                            id: submitButton
                            text: i18n.tr("Submit")
                            onClicked: {
                                urlHandler(urlContainer.text, donwloadType.index);
                                listModelToString();
                            }
                        }
                    }
                }

                Column {
                    id: downloadItemsContainer

                    width: parent.width
                    anchors.top: inputPanel.bottom
                    spacing: -units.gu(3)
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: units.gu(1)

                    Label {
                        id: downloadContainerHeading
                        text: i18n.tr("        Downloaded Files")
                        height: units.gu(5)
                        font.bold: true
                    }
                    ListModel {
                        id: downloadItemsModel
                        dynamicRoles: true
                    }

                    Repeater {
                        id: downloadItems
                        anchors {
                            top: downloadContainerHeading.bottom
                            bottom: parent.bottom
                            right: parent.right
                            left: parent.left
                        }

                        model: downloadItemsModel
                        delegate: MediaItem {
                            anchors {
                                left: parent.left
                                right: parent.right
                            }
                            height: units.gu(20)

                            videoTitle: vTitle
                            thumbnail: vThumbnail
                            duration: vDuration
                            videoLink: "https://youtu.be/" + vID

                            vcodec: vCodec
                            resolutionModel: vResolutions
                            videoExts: vVideoExts
                            videoFormats: vVideoFormats
                            videoProgress: vVideoProgress

//                            langs: vLangs
//                            langIds: vLangIds

                            acodec: aCodec
                            audioExts: vAudioExts
                            audioFormats: vAudioFormats
                            audioBitrate: vABR
                            audioSizes: vAudioSizes

                            sizeModel: vSizeModel
                            indexID: vIndex
                        }
                    }
                }
            }
        }

        // empty page while no downloads
        ColumnLayout {
            id: blankDownloadPage
            visible: false
            spacing: units.gu(2)
            anchors {
                margins: units.gu(2)
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            Item {
                Layout.fillHeight: true
            }

            Label {
                id: label
                Layout.alignment: Qt.AlignHCenter
                text: i18n.tr('No Downloads!')
                font.pixelSize: units.gu(3)
            }

            Item {
                Layout.fillHeight: true
            }
        }

        CustomBottomEdge {
            id: bottomEdge
            enabled: true
            height: root.height
            hint.text: i18n.tr("Swipe for Settings")
            hint.visible: enabled

            settingsObject: generalSettings
        }
    }
}
