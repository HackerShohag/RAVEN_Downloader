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

function safeParseJSON(jsonString, fallback) {
    if (!jsonString) return fallback || [];
    
    try {
        return JSON.parse(jsonString);
    } catch (e) {
        console.log("[Utils] JSON parse error:", e);
        return fallback || [];
    }
}

function fileUrlToPath(fileUrl) {
    if (!fileUrl) return "";
    return fileUrl.toString().replace("file://", "");
}

function pathToFileUrl(path) {
    if (!path) return "";
    if (path.startsWith("file://")) return path;
    return "file://" + path;
}

function extractFileName(filePath) {
    if (!filePath) return "Unknown";
    
    var fileName = filePath;
    if (fileName.indexOf('/') !== -1) {
        fileName = fileName.substring(fileName.lastIndexOf('/') + 1);
    }
    return fileName;
}

function isValidUrl(url) {
    if (!url) return false;
    return url.startsWith('http://') || url.startsWith('https://');
}

function formatDuration(seconds) {
    if (!seconds || seconds <= 0) return "00:00";
    
    var hours = Math.floor(seconds / 3600);
    var minutes = Math.floor((seconds % 3600) / 60);
    var secs = Math.floor(seconds % 60);
    
    if (hours > 0) {
        return String(hours).padStart(2, '0') + ':' + 
               String(minutes).padStart(2, '0') + ':' + 
               String(secs).padStart(2, '0');
    }
    return String(minutes).padStart(2, '0') + ':' + String(secs).padStart(2, '0');
}

var debounceTimers = {};
function debounce(key, callback, delay) {
    if (debounceTimers[key]) {
        debounceTimers[key].stop();
    }
    
    debounceTimers[key] = Qt.createQmlObject(
        'import QtQuick 2.7; Timer {}',
        Qt.application,
        "DynamicTimer"
    );
    debounceTimers[key].interval = delay || 300;
    debounceTimers[key].repeat = false;
    debounceTimers[key].triggered.connect(callback);
    debounceTimers[key].start();
}

function createContentItem(component, filePath) {
    return component.createObject(null, {
        "url": pathToFileUrl(filePath)
    });
}

function createContentItems(component, filePaths) {
    var items = [];
    for (var i = 0; i < filePaths.length; i++) {
        items.push(createContentItem(component, filePaths[i]));
    }
    return items;
}
