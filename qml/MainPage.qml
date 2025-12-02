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

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'raven.downloader.shohag'
    automaticOrientation: true

    width: units.gu(50)
    height: units.gu(75)

    property int margin: units.gu(1)
    property bool isExportPage: false
    property var contentHubPopup: null

    theme: ThemeSettings {
        id: appTheme
        name: "Lomiri.Components.Themes.Ambiance"
    }

    /**
     * Validation Dialog Components
     * 
     * These dialogs MUST be defined here in the MainView root context.
     * PopupUtils.open() requires a root object, and attempting to move these
     * to a separate QtObject component causes "Failed to get root object" errors.
     * 
     * Each dialog is a reusable Component that can be opened with PopupUtils.open()
     * throughout the application with custom property values.
     */
    Component {
        id: qProcessError
        WarningDialog {
            title: i18n.tr("Error Occurred!")
            text: i18n.tr("An unknown error occured.")
        }
    }
    
    Component {
        id: invalidPlayListURLWarning
        WarningDialog {
            title: i18n.tr("Invalid Playlist URL!")
            text: i18n.tr("Please provide a valid playlist url.")
        }
    }
    
    Component {
        id: playlistAsVideoWarning
        WarningDialog {
            title: i18n.tr("Playlist Detected!")
            text: i18n.tr("This is a playlist URL. Please select 'Playlist' mode to download all videos.")
        }
    }
    
    Component {
        id: invalidURLWarning
        WarningDialog {
            title: i18n.tr("Invalid URL!")
            text: i18n.tr("Please provide a valid video link.")
        }
    }
    
    Component {
        id: finishedPopup
        WarningDialog {
            property string playlistTitle: ""
            property int videoCount: 0
            
            title: i18n.tr("Download Complete!")
            text: i18n.tr(videoCount + " video(s) from \"" + playlistTitle + "\" playlist have been added.")
        }
    }
    
    Component {
        id: aboutDialog
        AboutPage {}
    }

    // Download Item Manager
    DownloadItemManager {
        id: downloadManager
        pythonInstance: python
    }

    // Playlist Processor
    PlaylistProcessor {
        id: playlistProcessor
        pythonInstance: python
        
        onVideoFormatsReady: function(formats) {
            downloadManager.addVideo(formats);
            if (downloadItemsContainer.visible === false) {
                mainPage.toggleBlankPage();
            }
        }
        
        onProcessingComplete: function(title, count) {
            pageLoadingOverlay.running = false;
            PopupUtils.open(finishedPopup, root, {
                playlistTitle: title,
                videoCount: count
            });
        }
        
        onError: function(error) {
            console.log("[MainPage] Playlist processing error: " + error);
        }
    }

    // Content Hub Export
    function openContentHubExport(filePath) {
        console.log("Opening ContentHub to save file:", filePath);
        contentHubPopup = PopupUtils.open(contentShareDialog, root, {
            downloadedFilePath: filePath
        });
    }

    // URL Submission Handler
    function urlHandler(url, isPlaylist) {
        pageLoadingOverlay.running = true;
        
        var validationFunc = isPlaylist ? 'is_valid_playlist' : 'is_valid_video_url';
        var invalidWarning = isPlaylist ? invalidPlayListURLWarning : invalidURLWarning;
        
        python.call('download_manager.' + validationFunc, [url], function(isValid) {
            if (!isValid) {
                pageLoadingOverlay.running = false;
                PopupUtils.open(invalidWarning, root);
                return;
            }
            
            python.call('download_manager.action_submit', [url, isPlaylist ? 1 : 0], function(result) {
                pageLoadingOverlay.running = false;
                
                if (result && result.error) {
                    if (result.error === 'playlist_as_video') {
                        PopupUtils.open(playlistAsVideoWarning, root);
                    } else {
                        PopupUtils.open(qProcessError, root, { text: result.error });
                    }
                } else if (result && result.type === 'playlist') {
                    playlistProcessor.processPlaylist(result.data);
                } else if (result && result.type === 'video') {
                    downloadManager.addVideo(result.data);
                    if (downloadItemsContainer.visible === false) {
                        mainPage.toggleBlankPage();
                    }
                }
            });
        });
    }

    // Python Event Handlers
    Connections {
        target: python
        
        function onReceived(event, data) {
            console.log('Event received: ' + event);
            
            switch(event) {
                case 'downloadFinished':
                    PopupUtils.open(exportPage, root, { url: data[1] });
                    break;
                case 'downloadProgress':
                    downloadManager.updateProgress(data[0], data[1]);
                    break;
                case 'generalMessage':
                    pageLoadingOverlay.running = false;
                    PopupUtils.open(qProcessError, root, { text: data });
                    break;
                default:
                    console.log('Unknown event: ' + event);
            }
        }
    }

    // Save history on quit
    Connections {
        target: Qt.application
        function onAboutToQuit() {
            console.log("Quiting " + root.applicationName);
            downloadManager.saveHistory();
        }
    }

    Settings {
        id: generalSettings
        objectName: "GeneralSettings"

        property alias theme: appTheme.name
        property bool downloadSubtitle: false
        property bool downloadCaption: false
        property bool embeddedSubtitle: false
        property bool autoDownload: false
    }

    Component {
        id: exportPage
        ExportPage {
            id: exportPageComponent
            contentType: ContentType.All
            handler: ContentHandler.Source
        }
    }

    ContentStore {
        id: contentStore
        scope: ContentScope.App
    }

    Component {
        id: contentShareDialog
        ContentHubDialog {
            downloadedFilePath: ""
            onCloseRequested: {
                if (contentHubPopup) {
                    PopupUtils.close(contentHubPopup);
                }
            }
        }
    }

    LoadingOverlay {
        id: pageLoadingOverlay
        running: false
    }

    Page {
        id: mainPage
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
            downloadManager.loadHistory(function(hasHistory) {
                if (hasHistory && downloadItemsContainer.visible === false) {
                    toggleBlankPage();
                } else if (!hasHistory) {
                    toggleBlankPage();
                }
            });
        }

        ColumnLayout {
            id: searchBarLayout
            anchors.topMargin: header.height
            anchors.fill: parent
            anchors.margins: root.margin
            anchors.bottom: bottomEdge.top

            Flickable {
                id: mainScroll
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentY: units.gu(1)
                contentHeight: inputPanel.height + downloadContainerHeading.height + 
                              (downloadManager.count * units.gu(13.5)) + units.gu(10)

                LayoutsCustom {
                    id: inputPanel
                    Layout.fillWidth: true
                    height: units.gu(20)
                    width: parent.width

                    ColumnLayout {
                        id: colLayout
                        anchors.fill: parent
                        anchors.margins: units.gu(1)
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
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
                }

                Column {
                    id: downloadItemsContainer
                    width: parent.width
                    anchors.top: inputPanel.bottom

                    Label {
                        id: downloadContainerHeading
                        text: i18n.tr("   Downloaded Files")
                        height: units.gu(3)
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
                            }
                            height: units.gu(13.5)

                            videoTitle: vTitle
                            thumbnail: vThumbnail
                            duration: vDuration
                            videoLink: vID
                            
                            entryId: model.entryId || ''
                            pythonInstance: python

                            vcodec: JSON.parse(vCodec)
                            resolutionModel: JSON.parse(vResolutions)
                            videoExts: JSON.parse(vVideoExts)
                            videoFormats: JSON.parse(vVideoFormats)
                            videoProgress: vVideoProgress
                            videoIndex: vVideoIndex
                            audioIndex: vAudioIndex
                            selectedVideoCodec: model.selectedVideoCodec || ''
                            selectedAudioCodec: model.selectedAudioCodec || ''

                            acodec: JSON.parse(aCodec)
                            audioExts: JSON.parse(vAudioExts)
                            audioFormats: JSON.parse(vAudioFormats)
                            audioBitrate: JSON.parse(vABR)
                            audioSizes: JSON.parse(vAudioSizes)

                            sizeModel: JSON.parse(vSizeModel)
                            indexID: vIndex
                        }
                    }
                }
                
                ColumnLayout {
                    id: blankDownloadPage
                    visible: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    anchors {
                        margins: units.gu(2)
                        top: inputPanel.bottom
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }

                    Label {
                        id: label
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignCenter
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
    
    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));

            importModule('download_manager', function() {
                console.log('download_manager module imported in MainPage');
            });
            
            importModule('storage_manager', function() {
                console.log('storage_manager module imported in MainPage');
            });
        }

        onError: {
            console.log('python error: ' + traceback);
        }
    }
}
