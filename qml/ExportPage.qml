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

import QtQuick 2.4
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import Lomiri.Content 1.3
import Lomiri.Components.Popups 1.3

Page {
    id: picker

    property var activeTransfer

    property string url
    property var handler
    property var contentType
    property bool isExportPage: false

    property var popupObject:  null
	
    signal cancel()
    signal imported(string fileUrl)
    signal backPressed()

    header: PageHeader {
        title: i18n.tr("Install/Save with")
        contents: RowLayout {
            anchors.fill: parent

            Label {
                anchors.centerIn: parent
                text: header.title
                textSize: Label.Large
            }
        }
    }

    ContentPeerPicker {
        anchors { fill: parent; topMargin: picker.header.height }
        visible: parent.visible
        showTitle: false
        contentType: ContentType.All
        handler: ContentHandler.Destination

        onPeerSelected: {
            picker.activeTransfer = peer.request()
            picker.activeTransfer.stateChanged.connect(function() {
				if (picker.activeTransfer.state === ContentTransfer.InProgress) {
					console.log("In progress");
					picker.activeTransfer.items = [ resultComponent.createObject(parent, {"url": url}) ];
					picker.activeTransfer.state = ContentTransfer.Charged;
					pageStack.pop()

				}

            })
        }
       

        onCancelPressed: {
            pageStack.pop()
        }
    }

    ContentTransferHint {
        id: transferHint
        anchors.fill: parent
        activeTransfer: picker.activeTransfer
    }
    Component {
        id: resultComponent
        ContentItem {}
	}
}
