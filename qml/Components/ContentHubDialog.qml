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
import Lomiri.Content 1.1

/**
 * Reusable ContentHub dialog for exporting/sharing files
 * Handles the full ContentHub transfer flow with proper state management
 */
Page {
    id: contentHubDialog
    
    property string downloadedFilePath: ""
    property var activeTransfer
    
    signal closeRequested()
    
    header: PageHeader {
        id: dialogHeader
        title: i18n.tr("Save Downloaded File")
        
        leadingActionBar.actions: [
            Action {
                iconName: "back"
                onTriggered: {
                    if (contentHubDialog.activeTransfer) {
                        contentHubDialog.activeTransfer.state = ContentTransfer.Aborted
                    }
                    closeRequested()
                }
            }
        ]
    }
    
    ContentPeerPicker {
        id: peerPicker
        anchors {
            fill: parent
            topMargin: dialogHeader.height
        }
        visible: parent.visible
        showTitle: false
        contentType: ContentType.All
        handler: ContentHandler.Destination
        
        onPeerSelected: {
            contentHubDialog.activeTransfer = peer.request()
            if (contentHubDialog.activeTransfer) {
                contentHubDialog.activeTransfer.stateChanged.connect(function() {
                    if (contentHubDialog.activeTransfer.state === ContentTransfer.InProgress) {
                        var item = contentItemComponent.createObject(null, {
                            "url": "file://" + contentHubDialog.downloadedFilePath
                        })
                        contentHubDialog.activeTransfer.items = [item]
                        contentHubDialog.activeTransfer.state = ContentTransfer.Charged
                        console.log("ContentHub: File transfer charged")
                    } else if (contentHubDialog.activeTransfer.state === ContentTransfer.Charged) {
                        console.log("ContentHub: File transfer complete")
                    }
                })
                contentHubDialog.activeTransfer.state = ContentTransfer.Requested
            }
        }
        
        onCancelPressed: {
            if (contentHubDialog.activeTransfer) {
                contentHubDialog.activeTransfer.state = ContentTransfer.Aborted
            }
            console.log("ContentHub: Transfer cancelled")
        }
    }
    
    Component {
        id: contentItemComponent
        ContentItem {
            property alias url: contentItemInstance.url
            id: contentItemInstance
        }
    }
}
