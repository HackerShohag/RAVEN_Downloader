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
 * PlaylistProcessor - Handles playlist video extraction and processing
 * Processes each video in a playlist sequentially
 */
Item {
    id: root
    
    // Properties
    property var pythonInstance
    property var onVideoFormatsReady: null
    property var onProcessingComplete: null
    property var onError: null
    
    property string playlistTitle: ""
    property int totalVideos: 0
    property int processedVideos: 0
    property bool isProcessing: false
    
    // Internal state
    property var _currentEntries: []
    property int _currentIndex: 0
    
    /**
     * Start processing playlist
     */
    function processPlaylist(playlistData) {
        if (!playlistData || !playlistData.entries || playlistData.entries.length === 0) {
            console.log("[PlaylistProcessor] No entries to process");
            return;
        }
        
        playlistTitle = playlistData.title || "Unknown Playlist";
        totalVideos = playlistData.video_count || playlistData.entries.length;
        processedVideos = 0;
        isProcessing = true;
        
        _currentEntries = playlistData.entries;
        _currentIndex = 0;
        
        console.log("[PlaylistProcessor] Processing " + totalVideos + " videos from: " + playlistTitle);
        
        _processNext();
    }
    
    /**
     * Process next video in queue
     */
    function _processNext() {
        if (_currentIndex >= _currentEntries.length) {
            _onComplete();
            return;
        }
        
        var entry = _currentEntries[_currentIndex];
        var videoUrl = entry.url || ('https://www.youtube.com/watch?v=' + entry.id);
        
        processedVideos = _currentIndex + 1;
        console.log("[PlaylistProcessor] Processing video " + processedVideos + "/" + totalVideos + ": " + (entry.title || videoUrl));
        
        // Get full video info
        pythonInstance.call('download_manager.action_submit', [videoUrl, 0], function(result) {
            if (result && result.type === 'video') {
                if (onVideoFormatsReady) {
                    onVideoFormatsReady(result.data);
                }
            } else if (result && result.error) {
                console.log("[PlaylistProcessor] Error processing video: " + result.error);
                if (onError) {
                    onError(result.error);
                }
            }
            
            _currentIndex++;
            _processNext();
        });
    }
    
    /**
     * Processing complete callback
     */
    function _onComplete() {
        console.log("[PlaylistProcessor] Finished processing all videos");
        isProcessing = false;
        
        if (onProcessingComplete) {
            onProcessingComplete(playlistTitle, totalVideos);
        }
    }
    
    /**
     * Cancel processing
     */
    function cancel() {
        console.log("[PlaylistProcessor] Cancelling playlist processing");
        isProcessing = false;
        _currentEntries = [];
        _currentIndex = 0;
    }
}
