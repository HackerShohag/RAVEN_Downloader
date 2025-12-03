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
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3

ListItem {
    id: gridBox
    divider {
        colorFrom: "transparent"
        colorTo: "transparent"
    }
    // dragMode: true

    MediaItemDialogs {
        id: mediaDialogs
    }

    property alias  videoTitle          : titleBox.text
    property string thumbnail           : ""
    property string duration            : ""
    property string videoLink           : ""

    property var    vcodec              : null
    property var    resolutionModel     : null
    property var    videoExts           : null
    property var    videoFormats        : null

    property var    acodec              : null
    property var    audioExts           : null
    property var    audioFormats        : null
    property var    audioBitrate        : null
    property var    audioSizes          : null

    property var    langs               : null
    property var    langIds             : null

    property var    sizeModel           : null
    property alias  videoProgress       : videoProgressBar.value
    property int    indexID
    property string entryId             : ""
    property var    pythonInstance      : null  // Pass Python instance from MainPage

    property alias  videoIndex          : resolutionPopup.index
    property alias  audioIndex          : audioPopup.index
    property string selectedVideoCodec  : ""
    property string selectedAudioCodec  : ""

    property var    downloadUnavailable : resolutionModel === null && vcodec === null ? true : false
    property var    comboHeading        : [ i18n.tr("select audio"), i18n.tr("select language"), i18n.tr("select resolution") ]
    
    // Function to save entry metadata whenever something changes
    function saveEntryMetadata() {
        if (entryId === "") {
            console.log("[MediaItem] No entryId, skipping save");
            return;
        }
        
        // Get currently selected codecs
        var currentVideoCodec = (vcodec && videoIndex >= 0 && videoIndex < vcodec.length) ? vcodec[videoIndex] : '';
        var currentAudioCodec = (acodec && audioIndex >= 0 && audioIndex < acodec.length) ? acodec[audioIndex] : '';
        
        var entryData = {
            entryId: entryId,
            vTitle: videoTitle,
            vThumbnail: thumbnail,
            vDuration: duration,
            vID: videoLink,
            vCodec: JSON.stringify(vcodec || []),
            vResolutions: JSON.stringify(resolutionModel || []),
            vVideoExts: JSON.stringify(videoExts || []),
            vVideoFormats: JSON.stringify(videoFormats || []),
            vVideoProgress: videoProgress,
            aCodec: JSON.stringify(acodec || []),
            vAudioExts: JSON.stringify(audioExts || []),
            vAudioFormats: JSON.stringify(audioFormats || []),
            vABR: JSON.stringify(audioBitrate || []),
            vAudioSizes: JSON.stringify(audioSizes || []),
            vVideoIndex: parseInt(videoIndex) || 0,
            vAudioIndex: parseInt(audioIndex) || 0,
            selectedVideoCodec: currentVideoCodec,
            selectedAudioCodec: currentAudioCodec,
            vSizeModel: JSON.stringify(sizeModel || []),
            vIndex: parseInt(indexID) || 0,
            timestamp: Date.now()
        };
        
        // Save to storage via Python
        if (pythonInstance) {
            pythonInstance.call('storage_manager.save_single_entry', [entryData], function(result) {
                console.log('[MediaItem] Entry saved:', entryId, 'result:', JSON.stringify(result));
            });
        } else {
            console.log('[MediaItem] ERROR: Python instance not provided');
        }
    }

    function isDownloadValid(size, resolution) {
        return true
    }

    function getFormats() {
        var jsonObject = {
            "format" : audioFormats[audioPopup.index] + "+" + videoFormats[resolutionPopup.index],
            "indexID" : indexID
        }

        if (generalSettings.setDownloadLocation) jsonObject["downloadLocation"] = generalSettings.customDownloadLocation;
        if (generalSettings.downloadSubtitle) {
            jsonObject["subtitle"] = true;
            if (videoExts[resolutionPopup.index] == "mp4") jsonObject["strConvert"] = true;
            if (generalSettings.embeddedSubtitle) jsonObject["embedded"] = true;
        }
        if (generalSettings.downloadCaption)
            jsonObject["caption"] = true;
        return jsonObject;
    }

    Component.onCompleted: {
        // Restore previously selected codecs if available
        if (selectedVideoCodec !== '' && vcodec) {
            var videoIdx = vcodec.indexOf(selectedVideoCodec);
            if (videoIdx >= 0) {
                videoIndex = videoIdx;
                console.log('[MediaItem] Restored video codec selection:', selectedVideoCodec, 'at index', videoIdx);
            }
        }
        
        if (selectedAudioCodec !== '' && acodec) {
            var audioIdx = acodec.indexOf(selectedAudioCodec);
            if (audioIdx >= 0) {
                audioIndex = audioIdx;
                console.log('[MediaItem] Restored audio codec selection:', selectedAudioCodec, 'at index', audioIdx);
            }
        }
        
        if (generalSettings.autoDownload) {
            if (isDownloadValid(audioPopup.text, resolutionPopup.text))
            {
                var jsonObject = getFormats();
                jsonObject["format"] = "bestaudio+bestvideo";
                python.call('download_manager.action_download', [videoLink, jsonObject], function() {
                    console.log('Auto-download started');
                });
            }
            else
                PopupUtils.open(mediaDialogs.invalidDownloadWarning, gridBox)
            downloadItems.itemAt(indexID).videoIndex = downloadItems.itemAt(indexID).vcodec.length - 1;
            downloadItems.itemAt(indexID).audioIndex = downloadItems.itemAt(indexID).acodec.length - 1;
        }
    }

    height: gridLayout.height
    width: gridLayout.width
    // animationEnabled: true

    Layout.fillWidth: true
    Layout.minimumWidth: gridLayout.Layout.minimumWidth
    
    LoadingOverlay {
        id: itemLoadingOverlay
        running: false
        indicatorSize: units.gu(5)
    }

    GridLayout {
        id: gridLayout
        rows: 3
        flow: GridLayout.TopToBottom
        anchors.fill: parent

        Image {
            id: thumbnailContainer
            Layout.preferredWidth: units.gu(15)

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: thumbnailContainer.width
                    height: thumbnailContainer.height
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        radius: units.gu(1)
                    }
                }
            }

            BusyIndicator {
                anchors.fill: parent
                running: thumbnailContainer.status === Image.Loading
            }
            
            // Handle thumbnail loading with fallback
            property string thumbnailSource: ""
            
            Component.onCompleted: {
                // Use placeholder initially
                source = Qt.resolvedUrl("../../assets/placeholder-video.png");
                // Bind parent thumbnail property
                thumbnailSource = Qt.binding(function() { return gridBox.thumbnail || ""; });
            }
            
            onThumbnailSourceChanged: {
                if (thumbnailSource && thumbnailSource !== "") {
                    // Handle file:// URLs for local cached thumbnails
                    if (thumbnailSource.startsWith("/")) {
                        source = "file://" + thumbnailSource;
                    } else if (thumbnailSource.startsWith("qrc://")) {
                        source = thumbnailSource;
                    } else if (thumbnailSource.startsWith("file://")) {
                        source = thumbnailSource;
                    } else if (thumbnailSource.startsWith("http://") || thumbnailSource.startsWith("https://")) {
                        source = thumbnailSource;
                    } else {
                        // Default to placeholder
                        source = Qt.resolvedUrl("../../assets/placeholder-video.png");
                    }
                }
            }
            
            onStatusChanged: {
                if (status === Image.Error) {
                    console.log("Thumbnail load error, using placeholder");
                    source = Qt.resolvedUrl("../../assets/placeholder-video.png");
                }
            }

            Layout.rowSpan: 3
            Layout.fillHeight: true
            Layout.minimumWidth: units.gu(15)
            Layout.maximumWidth: units.gu(25)
        }

        RowLayout {
            Label {
                id: titleBox
                // font.bold: true
                color: theme.palette.normal.backgroundText
                elide: Label.ElideRight
                Layout.fillWidth: true
            }
        }
        RowLayout {
            Layout.fillWidth: true

            CustomProgressBar {
                id: videoProgressBar
                Layout.fillWidth: true
            }
            Label {
                text: Math.round(videoProgressBar.value * 100) + "%"
                color: theme.palette.normal.backgroundText
                // font.pixelSize: 18
                // font.bold: true
            }
        }
        RowLayout {
            Layout.fillWidth: true

            CustomComboPopup {
                id: audioPopup
                Layout.fillWidth: true
                Layout.minimumWidth: units.gu(8)
                heading: comboHeading[0]
                enabled: downloadUnavailable ? false : true
                multipleModel: true
                dropdownModel: audioExts
                dropdownModel2: acodec
                dropdownModel3: audioBitrate
                
                onIndexChanged: {
                    // Update selected codec and save metadata
                    if (acodec && index >= 0 && index < acodec.length) {
                        gridBox.selectedAudioCodec = acodec[index];
                    }
                    gridBox.saveEntryMetadata();
                }
            }

            CustomComboPopup {
                id: resolutionPopup
                Layout.fillWidth: true
                Layout.minimumWidth: units.gu(8)
                heading: comboHeading[2]
                enabled: downloadUnavailable ? false : true
                multipleModel: true
                dropdownModel: resolutionModel
                dropdownModel2: videoExts
                dropdownModel3: vcodec
                
                onIndexChanged: {
                    // Update selected codec and save metadata
                    if (vcodec && index >= 0 && index < vcodec.length) {
                        gridBox.selectedVideoCodec = vcodec[index];
                    }
                    gridBox.saveEntryMetadata();
                }
            }

            Button {
                id: downloadButton
                enabled: downloadUnavailable ? false : true
                text: i18n.tr("Download")
                
                property int pollDownloadId: -1
                property var pollTimer: null
                
                onClicked: {
                    // Show loading indicator
                    itemLoadingOverlay.running = true;
                    console.log('[MediaItem] Download button clicked - showing loading overlay');
                    
                    // Save metadata when download is initiated
                    gridBox.saveEntryMetadata();
                    
                    if (isDownloadValid(audioPopup.text, resolutionPopup.text)) {
                        python.call('download_manager.action_download', [videoLink, getFormats()], function(result) {
                            console.log('[MediaItem] Download response:', JSON.stringify(result));
                            
                            // Don't hide overlay here - let polling detect when download starts
                            
                            if (result && result.success === false && result.error) {
                                // Only hide on error
                                itemLoadingOverlay.running = false;
                                PopupUtils.open(mediaDialogs.downloadErrorDialog, gridBox, { 
                                    errorMessage: result.error 
                                });
                            } else if (result && result.download_id !== undefined) {
                                // Start polling for download status
                                // Overlay will be hidden when status becomes 'downloading'
                                pollDownloadId = result.download_id;
                                startStatusPolling();
                            } else {
                                // Hide overlay if unexpected response
                                console.log('[MediaItem] Unexpected response, hiding overlay');
                                itemLoadingOverlay.running = false;
                            }
                        });
                    } else {
                        // Hide loading if validation failed
                        itemLoadingOverlay.running = false;
                        PopupUtils.open(mediaDialogs.invalidDownloadWarning, gridBox);
                    }
                }
                
                function startStatusPolling() {
                    if (pollTimer) {
                        pollTimer.stop();
                    }
                    pollTimer = Qt.createQmlObject('import QtQuick 2.7; Timer {}', downloadButton);
                    pollTimer.interval = 1000; // Poll every second
                    pollTimer.repeat = true;
                    pollTimer.triggered.connect(function() {
                        checkDownloadStatus();
                    });
                    pollTimer.start();
                }
                
                function checkDownloadStatus() {
                    python.call('download_manager.get_download_progress', [pollDownloadId], function(status) {
                        if (status) {
                            console.log('[MediaItem] Download status:', status.status, 'progress:', status.progress);
                            
                            // Hide loading overlay once actual download starts (or any progress is reported)
                            if (status.status === 'downloading' || status.status === 'processing' || status.progress > 0) {
                                if (itemLoadingOverlay.running) {
                                    console.log('[MediaItem] Hiding loading overlay - download active');
                                    itemLoadingOverlay.running = false;
                                }
                            }
                            
                            // Update progress bar
                            if (status.progress !== undefined) {
                                videoProgressBar.value = status.progress / 100.0;
                                // Save progress update
                                gridBox.saveEntryMetadata();
                            }
                            
                            // Check final status
                            if (status.status === 'finished') {
                                pollTimer.stop();
                                itemLoadingOverlay.running = false;  // Ensure overlay is hidden
                                videoProgressBar.value = 1.0;
                                var fileName = status.filename || 'Unknown';
                                var filePath = status.filename || '';
                                
                                // Extract just the filename from the path
                                if (fileName.indexOf('/') !== -1) {
                                    fileName = fileName.substring(fileName.lastIndexOf('/') + 1);
                                }
                                
                                PopupUtils.open(mediaDialogs.downloadFinishedDialog, gridBox, {
                                    fileName: fileName,
                                    filePath: filePath
                                });
                            } else if (status.status === 'error') {
                                pollTimer.stop();
                                itemLoadingOverlay.running = false;  // Hide overlay on error
                                videoProgressBar.value = 0;
                                PopupUtils.open(mediaDialogs.downloadErrorDialog, gridBox, { 
                                    errorMessage: status.error || 'Download failed'
                                });
                            } else if (status.status === 'processing') {
                                // Show processing status in progress bar
                                videoProgressBar.value = status.progress / 100.0;
                            }
                        }
                    });
                }
            }
        }
    }
}
