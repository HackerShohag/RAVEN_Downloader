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

/**
 * ValidationDialogs - Centralized warning and error dialogs
 * Provides all validation-related popups in one place
 */
QtObject {
    id: root
    
    // Dialog components
    readonly property Component qProcessError: Component {
        WarningDialog {
            title: i18n.tr("Error Occurred!")
            text: i18n.tr("An unknown error occured.")
        }
    }
    
    readonly property Component invalidPlayListURLWarning: Component {
        WarningDialog {
            title: i18n.tr("Invalid Playlist URL!")
            text: i18n.tr("Please provide a valid playlist link with list argument.")
        }
    }
    
    readonly property Component playlistAsVideoWarning: Component {
        WarningDialog {
            title: i18n.tr("Playlist Detected!")
            text: i18n.tr("This is a playlist URL. Please select 'Playlist' mode to download all videos.")
        }
    }
    
    readonly property Component invalidURLWarning: Component {
        WarningDialog {
            title: i18n.tr("Invalid URL!")
            text: i18n.tr("Please provide a valid video link.")
        }
    }
    
    readonly property Component finishedPopup: Component {
        WarningDialog {
            property string playlistTitle: ""
            property int videoCount: 0
            
            title: i18n.tr("Download Complete!")
            text: i18n.tr(videoCount + " video(s) from \"" + playlistTitle + "\" playlist have been added.")
        }
    }
}
