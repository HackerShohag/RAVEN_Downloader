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
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3
import Ubuntu.Components.Popups 1.3

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
//            Rectangle {
//                id: backButtonContainer
//                Layout.alignment: Qt.AlignLeft
//                visible: isExportPage
//
//                height: units.gu(5)
//                width: units.gu(5)
//                radius: units.gu(1)
//                Icon {
//                    id: backButtonIcon
//                    Layout.fillWidth: true
//                    anchors.centerIn: parent
//                    visible: isExportPage
//                    width: units.gu(3)
//                    height: units.gu(3)
//                    name: 'back'
//                    color: "red"
//                    keyColor: "blue"
//                }
//
//
//                MouseArea {
//                    anchors.fill: parent
//                    visible: isExportPage
//                    onClicked: {
//                            PopupUtils.close(exportPageComponent)
//                        picker.backPressed();
//                        isExportPage = false;
//                        console.log("Back pressed")
//                    }
//
//                    onPressed: backButtonContainer.color = "lightgrey"
//                    onReleased: backButtonContainer.color = "white"
//                }
//            }

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
            //peer.selectionType = ContentTransfer.Single
            picker.activeTransfer = peer.request()
            picker.activeTransfer.stateChanged.connect(function() {
				if (picker.activeTransfer.state === ContentTransfer.InProgress) {
					console.log("In progress");
					//picker.activeTransfer.items = picker.activeTransfer.items[0].url = url;
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
