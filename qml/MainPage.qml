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

    property int    margin          : units.gu(1)
    property string playListTitle

    property string entry
    property bool   isPlaylist      : false
    property int    count           : 0
    property bool   isExportPage    : false

    theme: ThemeSettings {
        id: appTheme
        name: "Lomiri.Components.Themes.Ambiance"
    }

    function listModelToString(){
        var datamodel = []
        for (var i = 0; i < downloadItemsModel.count; ++i){
            datamodel.push(downloadItemsModel.get(i))
        }
        python.call('download_manager.save_list_model_data', [datamodel], function(result) {
            console.log('Download history saved: ' + result);
        });
    }

    function urlHandler(url, index) {
        pageBusyIndicator.running = true;
        
        var validationFunc = index ? 'is_valid_playlist' : 'is_valid_video_url';
        var invalidWarning = index ? invalidPlayListURLWarning : invalidURLWarning;
        
        python.call('download_manager.' + validationFunc, [url], function(isValid) {
            if (!isValid) {
                pageBusyIndicator.running = false;
                PopupUtils.open(invalidWarning);
                return;
            }
            
            if (downloadItemsContainer.visible === false)
                mainPage.toggleBlankPage();
                
            python.call('download_manager.action_submit', [url, index], function(result) {
                pageBusyIndicator.running = false;
                
                if (result && result.error) {
                    if (result.error === 'playlist_as_video') {
                        handleInvalidPlaylistUrl(result.url);
                    } else {
                        PopupUtils.open(qProcessError, root, { text: result.error });
                    }
                } else if (result && result.type === 'playlist') {
                    handlePlaylistInfoExtracted(result.data);
                } else if (result && result.type === 'video') {
                    handleFormatsUpdated(result.data);
                }
                // console.log('Result from submit: ' + JSON.stringify(result));
            });
            
            root.isPlaylist = index ? true : false;
        });
    }

    function deformIndex(index) {
        return downloadItemsModel.count - index - 1;
    }

    // Python event handlers
    property var mediaFormats: ({})
    
    function handleFormatsUpdated(formats) {
        console.log("Formats updating for: " + formats.title);
        mediaFormats = formats;
        
        if (downloadItemsContainer.visible === false)
            mainPage.toggleBlankPage();

        downloadItemsModel.append({
            vTitle: formats.title || '',
            vThumbnail: formats.thumbnail || '',
            vDuration: formats.duration || '',
            vID: formats.videoUrl || '',

            vCodec: JSON.stringify(formats.vcodeces || []),
            vResolutions: JSON.stringify(formats.notes || []),
            vVideoExts: JSON.stringify(formats.videoExtensions || []),
            vVideoFormats: JSON.stringify(formats.videoFormatIds || []),
            vVideoProgress: 0,

            aCodec: JSON.stringify(formats.acodeces || []),
            vAudioExts: JSON.stringify(formats.audioExtensions || []),
            vAudioFormats: JSON.stringify(formats.audioFormatIds || []),
            vABR: JSON.stringify(formats.audioBitrates || []),
            vAudioSizes: JSON.stringify(formats.audioSizes || []),

            vVideoIndex: 0,
            vAudioIndex: 0,

            vSizeModel: JSON.stringify(formats.filesizes || []),
            vIndex: count
        })
        count = count + 1;
        downloadItemsModel.move(0, 1, downloadItems.count-1);
        pageBusyIndicator.running = false;
    }
    
    function handlePlaylistInfoExtracted(playlistData) {
        console.log("Playlist: " + playlistData.title + " with " + playlistData.video_count + " videos");
        root.playListTitle = playlistData.title;
        root.entry = playlistData.video_count;
    }
    
    function handleFinished() {
        console.log("Processing finished");
        if (root.isPlaylist)
            PopupUtils.open(finishedPopup);
    }
    
    function handleDownloadFinished(downloadId, fileName) {
        console.log("Download finished: " + fileName);
        pObj = PopupUtils.open(exportPage, root, {
            url: fileName
        });
    }
    
    function handleDownloadProgress(downloadId, progress) {
        downloadItemsModel.setProperty(deformIndex(downloadId), "vVideoProgress", progress/100);
    }
    
    function handleInvalidPlaylistUrl(url) {
        pageBusyIndicator.running = false;
        PopupUtils.open(invalidPlayListURLWarning);
    }
    
    function handleGeneralMessage(message) {
        pageBusyIndicator.running = false;
        PopupUtils.open(qProcessError, root, { text: message });
    }

    Connections {
        target: python
        
        function onReceived(event, data) {
            console.log('Event received: ' + event);
            
            switch(event) {
                case 'formatsUpdated':
                    handleFormatsUpdated(data);
                    break;
                case 'playlistInfoExtracted':
                    handlePlaylistInfoExtracted(data);
                    break;
                case 'finished':
                    handleFinished();
                    break;
                case 'downloadFinished':
                    handleDownloadFinished(data[0], data[1]);
                    break;
                case 'downloadProgress':
                    handleDownloadProgress(data[0], data[1]);
                    break;
                case 'invalidPlaylistUrl':
                    handleInvalidPlaylistUrl(data);
                    break;
                case 'generalMessage':
                    handleGeneralMessage(data);
                    break;
                default:
                    console.log('Unknown event: ' + event);
            }
        }
    }

    Connections {
        target: Qt.application
        onAboutToQuit: {
            console.log("Quiting " + root.applicationName)
            listModelToString()
        }
    }

    Settings {
        id: generalSettings
        objectName: "GeneralSettings"

        property alias  theme                   : appTheme.name
        property bool   downloadSubtitle        : false
        property bool   downloadCaption         : false
        property bool   embeddedSubtitle        : false
        property bool   autoDownload            : false
    }

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
            text: i18n.tr("Please provide a link with valid list argument.")
        }
    }

    Component {
        id: exportPage
        ExportPage {
            id: exportPageComponent
            contentType: ContentType.All
            handler: ContentHandler.Source
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

    Rectangle {
        id: loadingOverlay
        anchors.fill: parent
        visible: pageBusyIndicator.running
        color: "#80000000"  // Semi-transparent black
        z: 1000  // Ensure it's above all other content
        
        MouseArea {
            anchors.fill: parent
            preventStealing: true
            hoverEnabled: true
            // Consume all mouse/touch events to prevent interaction with underlying UI
        }
        
        BusyIndicator {
            id: pageBusyIndicator
            anchors.centerIn: parent
            width: units.gu(10)
            height: units.gu(10)
            running: false
        }
    }

    Page {
        id: mainPage
        anchors.fill: parent
        StateSaver.properties: "title"
        StateSaver.enabled: true

        header: PageHeader {
            id: header
            title: i18n.tr("RAVEN Downloader")
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
            toggleBlankPage();
            python.call('download_manager.load_list_model_data', [], function(history) {
                console.log('Loaded download history');
                // TODO: Restore download history items to model
            });
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
                contentY: units.gu(1)
                // contentHeight: downloadItemsContainer.height + colLayout.height + downloadContainerHeading.height + root.margin + blankDownloadPage.height + units.gu(20)
                contentHeight: contentItem.childrenRect.height
                ScrollBar.vertical: ScrollBar { }

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
                            Keys.onReturnPressed: urlHandler(urlContainer.text, donwloadType.index)
                        }
                        CustomComboPopup {
                            id: donwloadType
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
                                urlHandler(urlContainer.text, donwloadType.index);
                            }
                        }
                    }
                }

                Column {
                    id: downloadItemsContainer

                    width: parent.width
                    anchors.top: inputPanel.bottom
                    spacing: units.gu(1)
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: units.gu(1)

                    Label {
                        id: downloadContainerHeading
                        text: i18n.tr("   Downloaded Files")
                        height: units.gu(3)
                        font.bold: true
                    }
                    ListModel {
                        id: downloadItemsModel
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
                            height: units.gu(15)

                            videoTitle: vTitle
                            thumbnail: vThumbnail
                            duration: vDuration
                            videoLink: vID

                            vcodec: JSON.parse(vCodec)
                            resolutionModel: JSON.parse(vResolutions)
                            videoExts: JSON.parse(vVideoExts)
                            videoFormats: JSON.parse(vVideoFormats)
                            videoProgress: vVideoProgress
                            videoIndex: vVideoIndex
                            audioIndex: vAudioIndex

//                            langs: vLangs
//                            langIds: vLangIds

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
                // empty page while no downloads
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
        }

        onError: {
            console.log('python error: ' + traceback);
        }
    }
}
