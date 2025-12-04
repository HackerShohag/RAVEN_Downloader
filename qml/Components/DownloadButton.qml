/*
 * Copyright (C) 2025  Abdullah AL Shohag
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
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3

Button {
    id: downloadButton
    text: i18n.tr("Download")
    
    property var pythonInstance: null
    property string videoUrl: ""
    property var formatData: null
    property var progressBar: null
    property var loadingOverlay: null
    property var dialogs: null
    
    property int pollDownloadId: -1
    property var pollTimer: null
    
    signal downloadStarted()
    signal downloadFinished(string filePath, string fileName)
    signal downloadError(string error)
    
    onClicked: {
        if (!pythonInstance || !videoUrl || !formatData) {
            console.log('[DownloadButton] Missing required properties');
            return;
        }
        initiateDownload();
    }
    
    function initiateDownload() {
        if (loadingOverlay) loadingOverlay.running = true;
        console.log('[DownloadButton] Download initiated');
        
        downloadStarted();
        
        pythonInstance.call('download_manager.action_download', [videoUrl, formatData], function(result) {
            handleDownloadResponse(result);
        });
    }
    
    function handleDownloadResponse(result) {
        console.log('[DownloadButton] Response:', JSON.stringify(result));
        
        if (result && result.success === false && result.error) {
            if (loadingOverlay) loadingOverlay.running = false;
            if (dialogs && dialogs.downloadErrorDialog) {
                PopupUtils.open(dialogs.downloadErrorDialog, downloadButton.parent, { 
                    errorMessage: result.error 
                });
            }
            downloadError(result.error);
        } else if (result && result.download_id !== undefined) {
            pollDownloadId = result.download_id;
            startStatusPolling();
        } else {
            console.log('[DownloadButton] Unexpected response');
            if (loadingOverlay) loadingOverlay.running = false;
        }
    }
    
    function startStatusPolling() {
        if (pollTimer) {
            pollTimer.stop();
        }
        pollTimer = Qt.createQmlObject('import QtQuick 2.7; Timer {}', downloadButton);
        pollTimer.interval = 1000;
        pollTimer.repeat = true;
        pollTimer.triggered.connect(function() {
            checkDownloadStatus();
        });
        pollTimer.start();
    }
    
    function checkDownloadStatus() {
        pythonInstance.call('download_manager.get_download_progress', [pollDownloadId], function(status) {
            if (status) {
                handleDownloadStatus(status);
            }
        });
    }
    
    function handleDownloadStatus(status) {
        console.log('[DownloadButton] Status:', status.status, 'Progress:', status.progress);
        
        if ((status.status === 'downloading' || status.status === 'processing' || status.progress > 0) 
            && loadingOverlay && loadingOverlay.running) {
            console.log('[DownloadButton] Hiding loading overlay');
            loadingOverlay.running = false;
        }
        
        if (status.progress !== undefined && progressBar) {
            progressBar.value = status.progress / 100.0;
        }
        
        if (status.status === 'finished') {
            handleFinished(status);
        } else if (status.status === 'error') {
            handleError(status);
        }
    }
    
    function handleFinished(status) {
        if (pollTimer) pollTimer.stop();
        if (loadingOverlay) loadingOverlay.running = false;
        if (progressBar) progressBar.value = 1.0;
        
        var fileName = status.filename || 'Unknown';
        var filePath = status.filename || '';
        
        if (fileName.indexOf('/') !== -1) {
            fileName = fileName.substring(fileName.lastIndexOf('/') + 1);
        }
        
        if (dialogs && dialogs.downloadFinishedDialog) {
            PopupUtils.open(dialogs.downloadFinishedDialog, downloadButton.parent, {
                fileName: fileName,
                filePath: filePath
            });
        }
        
        downloadFinished(filePath, fileName);
    }
    
    function handleError(status) {
        if (pollTimer) pollTimer.stop();
        if (loadingOverlay) loadingOverlay.running = false;
        if (progressBar) progressBar.value = 0;
        
        var errorMsg = status.error || 'Download failed';
        if (dialogs && dialogs.downloadErrorDialog) {
            PopupUtils.open(dialogs.downloadErrorDialog, downloadButton.parent, { 
                errorMessage: errorMsg
            });
        }
        
        downloadError(errorMsg);
    }
}
