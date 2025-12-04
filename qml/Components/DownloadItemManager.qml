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
import io.thp.pyotherside 1.4

/**
 * DownloadItemManager - Manages download items model and operations
 * Handles adding, removing, and persisting download history
 */
Item {
    id: root
    
    property alias model: downloadItemsModel
    property int count: 0
    property var pythonInstance
    
    ListModel {
        id: downloadItemsModel
    }
    
    /**
     * Add video format data to model
     */
    function addVideo(formats) {
        console.log("[DownloadItemManager] Adding video: " + formats.title);
        
        downloadItemsModel.append({
            entryId: formats.entryId || '',
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
            selectedVideoCodec: '',
            selectedAudioCodec: '',

            vSizeModel: JSON.stringify(formats.filesizes || []),
            vIndex: count,
            timestamp: Date.now()
        });
        
        count++;
        
        if (downloadItemsModel.count > 1) {
            downloadItemsModel.move(0, 1, downloadItemsModel.count - 1);
        }
        
        saveHistory();
    }
    
    /**
     * Convert deformed index (reverse order)
     */
    function deformIndex(index) {
        return downloadItemsModel.count - index - 1;
    }
    
    /**
     * Update download progress
     */
    function updateProgress(downloadId, progress) {
        var index = deformIndex(downloadId);
        if (index >= 0 && index < downloadItemsModel.count) {
            downloadItemsModel.setProperty(index, "vVideoProgress", progress / 100);
        }
    }
    
    /**
     * Save history to storage
     */
    function saveHistory() {
        var datamodel = [];
        for (var i = 0; i < downloadItemsModel.count; ++i) {
            datamodel.push(downloadItemsModel.get(i));
        }
        
        console.log('[DownloadItemManager] Saving ' + datamodel.length + ' items to storage');
        
        pythonInstance.call('download_manager.save_list_model_data', [datamodel], function(result) {
            console.log('[DownloadItemManager] History saved: ' + result);
        });
    }
    
    /**
     * Load history from storage
     */
    function loadHistory(callback) {
        pythonInstance.call('download_manager.load_list_model_data', [], function(history) {
            console.log('[DownloadItemManager] Loaded ' + history.length + ' items from history');
            
            if (history && history.length > 0) {
                for (var i = 0; i < history.length; i++) {
                    var item = history[i];
                    downloadItemsModel.append(item);
                    count++;
                }
            }
            
            if (callback) {
                callback(history.length > 0);
            }
        });
    }
    
    /**
     * Clear all items
     */
    function clear() {
        downloadItemsModel.clear();
        count = 0;
        saveHistory();
    }
}
