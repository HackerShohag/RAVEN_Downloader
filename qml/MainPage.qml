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
import Qt.labs.platform 1.0
import io.thp.pyotherside 1.4

import Lomiri.Content 1.1
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3

import "Components"
import "js/utils.js" as Utils

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'raven.downloader.shohag'
    automaticOrientation: true

    width: units.gu(50)
    height: units.gu(75)

    property int margin: units.gu(1)

    theme: ThemeSettings {
        id: appTheme
        name: generalSettings.themeName
    }
    
    Connections {
        target: generalSettings
        function onThemeNameChanged() {
            appTheme.name = generalSettings.themeName
        }
    }
    
    MainPageDialogs {
        id: mainDialogs
    }
    
    Component {
        id: aboutDialog
        AboutPage {}
    }

    DownloadItemManager {
        id: downloadManager
        pythonInstance: python
    }

    PlaylistProcessor {
        id: playlistProcessor
        pythonInstance: python
        
        onVideoFormatsReady: function(formats) {
            downloadManager.addVideo(formats);
            if (pageStack.currentPage && pageStack.currentPage.objectName === 'mainPageItem') {
                pageStack.currentPage.showDownloadItems();
            }
        }
        
        onProcessingComplete: function(title, count) {
            pageLoadingOverlay.running = false;
            PopupUtils.open(mainDialogs.playlistFinished, root, {
                playlistTitle: title,
                videoCount: count
            });
        }
        
        onError: function(error) {
            console.log("[MainPage] Playlist processing error:", error);
        }
    }
    
    Settings {
        id: generalSettings
        category: "GeneralSettings"

        property string themeName: "Lomiri.Components.Themes.Ambiance"
        property bool downloadSubtitle: false
        property bool downloadCaption: false
        property bool embeddedSubtitle: false
        property bool autoDownload: false
    }
    
    ContentStore {
        id: contentStore
        scope: ContentScope.App
    }
    
    Component {
        id: contentSharePage
        ContentHubDialog {
            downloadedFilePath: ""
            pageStack: root.pageStack
        }
    }
    
    Component {
        id: exportPage
        ExportPage {
            contentType: ContentType.All
            handler: ContentHandler.Source
        }
    }

    function openContentHubExport(filePath) {
        console.log("[MainPage] Opening ContentHub for:", filePath);
        pageStack.push(contentSharePage, {
            downloadedFilePath: filePath
        });
    }
    
    function urlHandler(url, isPlaylist) {
        pageLoadingOverlay.running = true;
        
        var validationFunc = isPlaylist ? 'is_valid_playlist' : 'is_valid_video_url';
        var invalidWarning = isPlaylist ? mainDialogs.invalidPlaylistURL : mainDialogs.invalidURL;
        
        python.call('download_manager.' + validationFunc, [url], function(isValid) {
            if (!isValid) {
                pageLoadingOverlay.running = false;
                PopupUtils.open(invalidWarning, root);
                return;
            }
            
            python.call('download_manager.action_submit', [url, isPlaylist ? 1 : 0], function(result) {
                pageLoadingOverlay.running = false;
                
                if (result && result.error) {
                    handleSubmitError(result.error);
                } else if (result && result.type === 'playlist') {
                    playlistProcessor.processPlaylist(result.data);
                } else if (result && result.type === 'video') {
                    downloadManager.addVideo(result.data);
                    if (pageStack.currentPage && pageStack.currentPage.objectName === 'mainPageItem') {
                        pageStack.currentPage.showDownloadItems();
                    }
                }
            });
        });
    }
    
    function handleSubmitError(error) {
        if (error === 'playlist_as_video') {
            PopupUtils.open(mainDialogs.playlistAsVideo, root);
        } else {
            PopupUtils.open(mainDialogs.processError, root, { text: error });
        }
    }

    Connections {
        target: python
        
        function onReceived(event, data) {
            console.log('[MainPage] Event received:', event);
            
            switch(event) {
                case 'downloadFinished':
                    PopupUtils.open(exportPage, root, { url: data[1] });
                    break;
                case 'downloadProgress':
                    downloadManager.updateProgress(data[0], data[1]);
                    break;
                case 'generalMessage':
                    pageLoadingOverlay.running = false;
                    PopupUtils.open(mainDialogs.processError, root, { text: data });
                    break;
                default:
                    console.log('[MainPage] Unknown event:', event);
            }
        }
    }

    Connections {
        target: Qt.application
        function onAboutToQuit() {
            console.log("[MainPage] Saving history on quit");
            downloadManager.saveHistory();
        }
    }
    
    LoadingOverlay {
        id: pageLoadingOverlay
        running: false
    }
    
    PageStack {
        id: pageStack
        anchors.fill: parent

        Component.onCompleted: {
            push(mainPageComponent);
        }
    }

    Component {
        id: mainPageComponent
        
        Page {
            id: mainPage
            objectName: 'mainPageItem'
            anchors.fill: parent
            StateSaver.properties: "title"
            StateSaver.enabled: true

            header: PageHeader {
                id: header
                title: i18n.tr("RAVEN Downloader")
                
                trailingActionBar.actions: [
                    Action {
                        iconName: "info"
                        text: i18n.tr("About")
                        onTriggered: PopupUtils.open(aboutDialog, root)
                    }
                ]
            }

            function showDownloadItems() {
                if (!downloadItemsContainer.visible) {
                    blankDownloadPage.visible = false;
                    downloadItemsContainer.visible = true;
                }
            }
            
            function hideDownloadItems() {
                downloadItemsContainer.visible = false;
                blankDownloadPage.visible = true;
            }

            Component.onCompleted: {
                historyLoadingOverlay.running = true;
                
                downloadManager.loadHistory(function(hasHistory) {
                    historyLoadingOverlay.running = false;
                    
                    if (hasHistory) {
                        showDownloadItems();
                    } else {
                        hideDownloadItems();
                    }
                });
            }

            ColumnLayout {
                id: searchBarLayout
                anchors.topMargin: header.height
                anchors.fill: parent
                anchors.bottom: bottomEdge.top

                Flickable {
                    id: mainScroll
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: mainPage.height - header.height - bottomEdge.height - units.gu(2)
                    contentY: units.gu(1)
                    contentHeight: inputPanel.height + downloadContainerHeading.height + 
                                  (downloadManager.count ? downloadManager.count * units.gu(10) : units.gu(10)) + units.gu(12)

                    ColumnLayout {
                        id: inputPanel
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: units.gu(1)
                        }
                        
                        TextField {
                            id: urlContainer
                            Layout.fillWidth: true
                            placeholderText: i18n.tr("Put YouTube video or playlist URL here")
                            Keys.onReturnPressed: urlHandler(urlContainer.text, downloadType.index === 1)
                        }
                        
                        CustomComboPopup {
                            id: downloadType
                            Layout.fillWidth: true
                            heading: i18n.tr("Select download type")
                            defaultValue: true
                            dropdownModel: [i18n.tr("single video"), i18n.tr("playlist")]
                        }

                        Button {
                            id: submitButton
                            Layout.fillWidth: true
                            text: i18n.tr("Submit")
                            onClicked: {
                                urlHandler(urlContainer.text, downloadType.index === 1);
                            }
                        }
                    }

                    Column {
                        id: downloadItemsContainer
                        width: parent.width
                        anchors.top: inputPanel.bottom
                        anchors.topMargin: units.gu(1)
                        spacing: units.gu(1)

                        Label {
                            id: downloadContainerHeading
                            anchors {
                                left: parent.left
                                right: parent.right
                                leftMargin: units.gu(1)
                            }
                            text: i18n.tr("Downloaded Files")
                        }
                        
                        Item {
                            id: historyLoadingContainer
                            width: parent.width
                            height: units.gu(20)
                            visible: historyLoadingOverlay.running
                            
                            LoadingOverlay {
                                id: historyLoadingOverlay
                                running: false
                                indicatorSize: units.gu(5)
                                color: "transparent"
                            }
                        }

                        Repeater {
                            id: downloadItems
                            anchors {
                                top: downloadContainerHeading.bottom
                                bottom: parent.bottom
                                right: parent.right
                                left: parent.left
                            }

                            model: downloadManager.model
                            delegate: MediaItem {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    margins: units.gu(1)
                                }
                                height: units.gu(10)

                                videoTitle: vTitle
                                thumbnail: vThumbnail
                                duration: vDuration
                                videoLink: vID
                                
                                entryId: model.entryId || ''
                                pythonInstance: python

                                vcodec: Utils.safeParseJSON(vCodec)
                                resolutionModel: Utils.safeParseJSON(vResolutions)
                                videoExts: Utils.safeParseJSON(vVideoExts)
                                videoFormats: Utils.safeParseJSON(vVideoFormats)
                                videoProgress: vVideoProgress
                                videoIndex: vVideoIndex
                                audioIndex: vAudioIndex
                                selectedVideoCodec: model.selectedVideoCodec || ''
                                selectedAudioCodec: model.selectedAudioCodec || ''

                                acodec: Utils.safeParseJSON(aCodec)
                                audioExts: Utils.safeParseJSON(vAudioExts)
                                audioFormats: Utils.safeParseJSON(vAudioFormats)
                                audioBitrate: Utils.safeParseJSON(vABR)
                                audioSizes: Utils.safeParseJSON(vAudioSizes)

                                sizeModel: Utils.safeParseJSON(vSizeModel)
                                indexID: vIndex
                            }
                        }
                    }
                    
                    ColumnLayout {
                        id: blankDownloadPage
                        visible: false
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        height: units.gu(20)
                        anchors {
                            margins: units.gu(2)
                            leftMargin: units.gu(1)
                            top: inputPanel.bottom
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }

                        Label {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            text: i18n.tr("No downloads yet.")
                            font.pixelSize: units.gu(2)
                        }
                    }
                }
            }

            CustomBottomEdge {
                id: bottomEdge
                enabled: true
                height: root.height
                hint.text: i18n.tr("Swipe for Settings")
                hint.visible: enabled
            }
        }
    }

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));

            importModule('download_manager', function() {
                console.log('[MainPage] download_manager module imported');
            });
            
            importModule('storage_manager', function() {
                console.log('[MainPage] storage_manager module imported');
            });
        }

        onError: {
            console.log('[MainPage] Python error:', traceback);
        }
    }
}
