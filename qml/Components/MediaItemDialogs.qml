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

/**
 * MediaItemDialogs - Reusable dialog components for MediaItem
 * Provides download-related dialogs to avoid duplication
 */
QtObject {
    id: dialogRoot
    
    /**
     * Dialog shown when download link is expired or invalid
     */
    readonly property Component invalidDownloadWarning: Component {
        Dialog {
            id: dialogue
            title: i18n.tr("Download Invalid!")
            text: i18n.tr("Please refresh download link.")
            Button {
                text: "OK"
                onClicked: PopupUtils.close(dialogue)
            }
        }
    }
    
    /**
     * Dialog shown when download completes successfully
     * Provides option to export file via ContentHub
     */
    readonly property Component downloadFinishedDialog: Component {
        Dialog {
            id: finishedDialog
            property string fileName: ""
            property string filePath: ""
            title: i18n.tr("Download Complete!")
            text: i18n.tr("File downloaded: ") + fileName
            
            Button {
                text: i18n.tr("Save to...")
                color: theme.palette.normal.positive
                onClicked: {
                    PopupUtils.close(finishedDialog);
                    // Trigger ContentHub export
                    if (root && root.openContentHubExport) {
                        root.openContentHubExport(filePath);
                    }
                }
            }
            
            Button {
                text: i18n.tr("Close")
                onClicked: PopupUtils.close(finishedDialog)
            }
        }
    }
    
    /**
     * Dialog shown when download fails
     * Displays error message from backend
     */
    readonly property Component downloadErrorDialog: Component {
        Dialog {
            id: errorDialog
            property string errorMessage: ""
            title: i18n.tr("Download Failed")
            text: errorMessage || i18n.tr("An error occurred while starting the download.")
            Button {
                text: "OK"
                onClicked: PopupUtils.close(errorDialog)
            }
        }
    }
}
