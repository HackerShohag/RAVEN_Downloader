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
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import Lomiri.Components 1.3

Image {
    id: thumbnailImage
    
    property string thumbnailUrl: ""
    property string placeholderPath: "../../assets/placeholder-video.png"
    property real cornerRadius: units.gu(1)
    
    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Item {
            width: thumbnailImage.width
            height: thumbnailImage.height
            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                radius: thumbnailImage.cornerRadius
            }
        }
    }
    
    Component.onCompleted: {
        source = Qt.resolvedUrl(placeholderPath);
        if (thumbnailUrl && thumbnailUrl !== "") {
            loadThumbnail(thumbnailUrl);
        }
    }
    
    onThumbnailUrlChanged: {
        if (thumbnailUrl && thumbnailUrl !== "") {
            loadThumbnail(thumbnailUrl);
        } else {
            source = Qt.resolvedUrl(placeholderPath);
        }
    }
    
    onStatusChanged: {
        if (status === Image.Error) {
            source = Qt.resolvedUrl(placeholderPath);
        }
    }
    
    function loadThumbnail(url) {
        if (url.startsWith("/")) {
            source = "file://" + url;
        } else if (url.startsWith("qrc://") || 
                   url.startsWith("file://") ||
                   url.startsWith("http://") || 
                   url.startsWith("https://")) {
            source = url;
        } else {
            console.log("[ThumbnailImage] Invalid URL format, using placeholder");
            source = Qt.resolvedUrl(placeholderPath);
        }
    }
}
