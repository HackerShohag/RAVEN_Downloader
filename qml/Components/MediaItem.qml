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
    height: gridLayout.height
    width: gridLayout.width
    Layout.fillWidth: true
    Layout.minimumWidth: gridLayout.Layout.minimumWidth
    
    MediaItemDialogs {
        id: mediaDialogs
    }

    property alias  videoTitle          : titleBox.text
    property string thumbnail           : ""
    property string duration            : ""
    property string videoLink           : ""
    property int    indexID
    property string entryId             : ""

    property var    vcodec              : null
    property var    resolutionModel     : null
    property var    videoExts           : null
    property var    videoFormats        : null
    property alias  videoIndex          : resolutionPopup.index
    property string selectedVideoCodec  : ""

    property var    acodec              : null
    property var    audioExts           : null
    property var    audioFormats        : null
    property var    audioBitrate        : null
    property var    audioSizes          : null
    property alias  audioIndex          : audioPopup.index
    property string selectedAudioCodec  : ""

    property var    langs               : null
    property var    langIds             : null
    property var    sizeModel           : null
    property alias  videoProgress       : videoProgressBar.value
    property var    pythonInstance      : null

    property bool   downloadUnavailable : resolutionModel === null && vcodec === null
    property var    comboHeading        : [
        i18n.tr("select audio"), 
        i18n.tr("select language"), 
        i18n.tr("select resolution")
    ]

    Component.onCompleted: {
        restoreCodecSelections();
        
        if (generalSettings.autoDownload) {
            initiateAutoDownload();
        }
    }

    function restoreCodecSelections() {
        if (selectedVideoCodec !== '' && vcodec) {
            var videoIdx = vcodec.indexOf(selectedVideoCodec);
            if (videoIdx >= 0) {
                videoIndex = videoIdx;
                console.log('[MediaItem] Restored video codec:', selectedVideoCodec, 'at index', videoIdx);
            }
        }
        
        if (selectedAudioCodec !== '' && acodec) {
            var audioIdx = acodec.indexOf(selectedAudioCodec);
            if (audioIdx >= 0) {
                audioIndex = audioIdx;
                console.log('[MediaItem] Restored audio codec:', selectedAudioCodec, 'at index', audioIdx);
            }
        }
    }

    function updateCodecSelection(isVideo, codec) {
        if (isVideo) {
            gridBox.selectedVideoCodec = codec;
        } else {
            gridBox.selectedAudioCodec = codec;
        }
        gridBox.saveEntryMetadata();
    }

    function saveEntryMetadata() {
        if (entryId === "") {
            console.log("[MediaItem] No entryId, skipping save");
            return;
        }
        
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
        
        if (pythonInstance) {
            pythonInstance.call('storage_manager.save_single_entry', [entryData], function(result) {
                console.log('[MediaItem] Entry saved:', entryId);
            });
        } else {
            console.log('[MediaItem] ERROR: Python instance not provided');
        }
    }

    function getFormats() {
        var jsonObject = {
            "format": audioFormats[audioPopup.index] + "+" + videoFormats[resolutionPopup.index],
            "indexID": indexID
        };

        if (generalSettings.setDownloadLocation) {
            jsonObject["downloadLocation"] = generalSettings.customDownloadLocation;
        }
        
        if (generalSettings.downloadSubtitle) {
            jsonObject["subtitle"] = true;
            if (videoExts[resolutionPopup.index] == "mp4") {
                jsonObject["strConvert"] = true;
            }
            if (generalSettings.embeddedSubtitle) {
                jsonObject["embedded"] = true;
            }
        }
        
        if (generalSettings.downloadCaption) {
            jsonObject["caption"] = true;
        }
        
        return jsonObject;
    }

    function initiateAutoDownload() {
        var jsonObject = getFormats();
        jsonObject["format"] = "bestaudio+bestvideo";
        
        python.call('download_manager.action_download', [videoLink, jsonObject], function() {
            console.log('[MediaItem] Auto-download started');
        });
        
        if (downloadItems.itemAt(indexID)) {
            downloadItems.itemAt(indexID).videoIndex = downloadItems.itemAt(indexID).vcodec.length - 1;
            downloadItems.itemAt(indexID).audioIndex = downloadItems.itemAt(indexID).acodec.length - 1;
        }
    }

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

        ThumbnailImage {
            id: thumbnailContainer
            Layout.preferredWidth: units.gu(15)
            Layout.rowSpan: 3
            Layout.fillHeight: true
            Layout.minimumWidth: units.gu(15)
            Layout.maximumWidth: units.gu(25)
            
            thumbnailUrl: gridBox.thumbnail
        }

        RowLayout {
            Label {
                id: titleBox
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
            }
        }

        RowLayout {
            Layout.fillWidth: true

            CustomComboPopup {
                id: audioPopup
                Layout.fillWidth: true
                Layout.minimumWidth: units.gu(8)
                heading: comboHeading[0]
                enabled: !downloadUnavailable
                multipleModel: true
                dropdownModel: audioExts
                dropdownModel2: acodec
                dropdownModel3: audioBitrate
                
                onIndexChanged: {
                    if (acodec && index >= 0 && index < acodec.length) {
                        updateCodecSelection(false, acodec[index]);
                    }
                }
            }

            CustomComboPopup {
                id: resolutionPopup
                Layout.fillWidth: true
                Layout.minimumWidth: units.gu(8)
                heading: comboHeading[2]
                enabled: !downloadUnavailable
                multipleModel: true
                dropdownModel: resolutionModel
                dropdownModel2: videoExts
                dropdownModel3: vcodec
                
                onIndexChanged: {
                    if (vcodec && index >= 0 && index < vcodec.length) {
                        updateCodecSelection(true, vcodec[index]);
                    }
                }
            }

            DownloadButton {
                id: downloadButton
                enabled: !downloadUnavailable
                pythonInstance: gridBox.pythonInstance
                videoUrl: gridBox.videoLink
                formatData: gridBox.getFormats()
                progressBar: videoProgressBar
                loadingOverlay: itemLoadingOverlay
                dialogs: mediaDialogs
                
                onDownloadStarted: {
                    gridBox.saveEntryMetadata();
                }
                
                onDownloadFinished: {
                    gridBox.saveEntryMetadata();
                }
            }
        }
    }
}
