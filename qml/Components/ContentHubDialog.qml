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
import Lomiri.Content 1.1
import "../js/utils.js" as Utils

Page {
    id: sharePage
    
    property string downloadedFilePath: ""
    property var activeTransfer
    property var pageStack
    
    header: PageHeader {
        id: shareHeader
        title: i18n.tr("Share Downloaded File")
        
        leadingActionBar.actions: [
            Action {
                iconName: "back"
                text: i18n.tr("Cancel")
                onTriggered: {
                    if (sharePage.activeTransfer) {
                        sharePage.activeTransfer.state = ContentTransfer.Aborted
                    }
                    if (sharePage.pageStack) {
                        sharePage.pageStack.pop()
                    }
                }
            }
        ]
    }
    
    ContentPeerPicker {
        id: peerPicker
        anchors {
            top: shareHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        showTitle: false
        contentType: ContentType.All
        handler: ContentHandler.Destination
        
        onPeerSelected: {
            sharePage.activeTransfer = peer.request()
            
            if (sharePage.activeTransfer) {
                sharePage.activeTransfer.stateChanged.connect(function() {
                    if (sharePage.activeTransfer.state === ContentTransfer.Charged) {
                        console.log("[ContentHub] Transfer charged, closing page")
                        if (sharePage.pageStack) {
                            sharePage.pageStack.pop()
                        }
                    }
                })
                
                var item = Utils.createContentItem(
                    contentItemComponent, 
                    sharePage.downloadedFilePath
                )
                
                sharePage.activeTransfer.items = [item]
                sharePage.activeTransfer.state = ContentTransfer.Charged
                
                console.log("[ContentHub] File shared:", sharePage.downloadedFilePath)
            }
        }
        
        onCancelPressed: {
            if (sharePage.activeTransfer) {
                sharePage.activeTransfer.state = ContentTransfer.Aborted
            }
            if (sharePage.pageStack) {
                sharePage.pageStack.pop()
            }
        }
    }
    
    Component {
        id: contentItemComponent
        ContentItem {}
    }
}
