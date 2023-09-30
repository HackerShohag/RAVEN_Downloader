// Copyright (C) 2022 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "Components"

ApplicationWindow {
    id: window
    width: 360
    height: 520
    visible: true
    title: "shohag.raven.downloader"

    property string playListTitle

    property string entry
    property bool   isPlaylist
    property int    count           : 0

    Connections {
        target: downloadManager
        onFormatsUpdated: {
//            if (downloadItemsContainer.visible === false)
//                mainPage.toggleBlankPage();

            downloadItemsModel.append({
                                          vTitle: downloadManager.mediaFormats.title,
                                          vThumbnail: downloadManager.mediaFormats.thumbnail,
                                          vDuration: downloadManager.mediaFormats.duration,
                                          vID: downloadManager.mediaFormats.videoUrl,

                                          vCodec: downloadManager.mediaFormats.vcodeces,
                                          vResolutions: downloadManager.mediaFormats.notes,
                                          vVideoExts: downloadManager.mediaFormats.videoExtensions,
                                          vVideoFormats: downloadManager.mediaFormats.videoFormatIds,
                                          vVideoProgress: hasIndex ? videoProgress : 0,

                                          aCodec: downloadManager.mediaFormats.acodeces,
                                          vAudioExts: downloadManager.mediaFormats.audioExtensions,
                                          vAudioFormats: downloadManager.mediaFormats.audioFormatIds,
                                          vABR: downloadManager.mediaFormats.audioBitrates,
                                          vAudioSizes: downloadManager.mediaFormats.audioSizes,

                                          vVideoIndex: hasIndex ? videoIndex : null,
                                          vAudioIndex: hasIndex ? audioIndex : null,

                                          vSizeModel: downloadManager.mediaFormats.filesizes,
                                          vIndex: count
                                      })
            count = count + 1;
            downloadItemsModel.move(0, 1, downloadItems.count-1)
        }

        onFinished: {
            console.log("playlistTitle: " + playlistTitle + " " + entries);
            window.playListTitle = playlistTitle;
            window.entry = entries;
            if (window.isPlaylist)
                PopupUtils.open(finishedPopup);
        }

        onDownloadProgress: downloadItemsModel.setProperty(deformIndex(indexID), "vVideoProgress", value/100);

        onInvalidPlaylistUrl: PopupUtils.open(invalidPlayListURLWarning);

        onGeneralMessage: PopupUtils.open(qProcessError, window, { text: message });
    }

    function urlHandler(url, index) {
        if (index) {
            window.isPlaylist = true;
            if (!(downloadManager.isValidPlayListUrl(url))) {
                invalidDownloadWarning.open();
                return ;
            }
            if (downloadItemsContainer.visible === false)
                mainPage.toggleBlankPage();
            downloadManager.actionSubmit(url, index);
            return ;
        }
        window.isPlaylist = false;
        if (downloadManager.isValidUrl(url)) {
            downloadManager.actionSubmit(url, index);
            return ;
        }
        invalidDownloadWarning.open();
    }

    function help() {
        let displayingControl = listView.currentIndex !== -1
        let currentControlName = displayingControl
            ? listView.model.get(listView.currentIndex).title.toLowerCase() : ""
        let url = "https://doc.qt.io/qt-6/"
            + (displayingControl
               ? "qml-qtquick-controls2-" + currentControlName + ".html"
               : "qtquick-controls2-qmlmodule.html");
        Qt.openUrlExternally(url)
    }

    required property var builtInStyles

    Settings {
        id: settings
        property string style
    }

    Shortcut {
        sequences: ["Esc", "Back"]
        enabled: false
        onActivated: navigateBackAction.trigger()
    }

    Shortcut {
        sequence: StandardKey.HelpContents
        onActivated: help()
    }

    Action {
        id: navigateBackAction
        icon.name: "drawer"
        onTriggered: {
            if (stackView.depth > 1) {
                stackView.pop()
                listView.currentIndex = -1
            } else {
                drawer.open()
            }
        }
    }

    Shortcut {
        sequence: "Menu"
        onActivated: optionsMenuAction.trigger()
    }

    Action {
        id: optionsMenuAction
        icon.name: "menu"
        onTriggered: optionsMenu.open()
    }

    BusyIndicator {
        anchors.fill: parent
        padding: 10
        running: false
    }

    header: ToolBar {
        RowLayout {
            spacing: 20
            anchors.fill: parent

            ToolButton {
                action: navigateBackAction
            }

            Label {
                id: titleLabel
                text: listView.currentItem ? listView.currentItem.text : "Raven Downloader"
                font.pixelSize: 20
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }

            ToolButton {
                action: optionsMenuAction

                Menu {
                    id: optionsMenu
                    x: parent.width - width
                    transformOrigin: Menu.TopRight

                    Action {
                        text: "Settings"
                        onTriggered: settingsDialog.open()
                    }
                    Action {
                        text: "Help"
                        onTriggered: help()
                    }
                    Action {
                        text: "About"
                        onTriggered: aboutDialog.open() /*aboutDialog.open()*/
                    }
                }
            }
        }
    }

    Drawer {
        id: drawer
        width: Math.min(window.width, window.height) / 3 * 2
        height: window.height
        interactive: stackView.depth === 1

        ListView {
            id: listView

            focus: true
            currentIndex: -1
            anchors.fill: parent

            delegate: ItemDelegate {
                width: listView.width
                text: model.title
                highlighted: ListView.isCurrentItem
                onClicked: {
                    listView.currentIndex = index
                    stackView.push(model.source)
                    drawer.close()
                }
            }

            model: ListModel {
                ListElement { title: "BusyIndicator"; source: "qrc:/pages/BusyIndicatorPage.qml" }
            }

            ScrollIndicator.vertical: ScrollIndicator { }
        }
    }

    Rectangle {
        id: mainPageContainer
        anchors {
            margins: 5
            fill: parent
        }

        //        color: "red"

        Flickable {
            id: mainScroll

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            contentY: 0
            contentX: 0
            contentHeight: urlFieldContainer.height + entriesLabel.height + mediaItemContainer.height
            ScrollBar.vertical: ScrollBar { }

            RowLayout {
                id: urlFieldContainer
                anchors.left: parent.left
                anchors.right: parent.right

                TextField {
                    id: urlContainer
                    placeholderText: "Put youtube video or playlist url here"
                    Layout.minimumWidth: 50
                    Layout.fillWidth: true
                }

                ComboBox {
                    id: donwloadType
                    model: ["single", "playlist"]
                }

                Button {
                    id: submitButton
                    text: "Submit"
                    onClicked: {
                        console.log("Submit Clicked")
                        urlHandler(urlContainer.text, donwloadType.index)
                    }
                }
            }

            Label {
                id: entriesLabel
                anchors.top: urlFieldContainer.bottom
                anchors.topMargin: 5

                text: "Downloaded Files"
            }

            ColumnLayout {
                id: mediaItemContainer
                anchors {
                    top: entriesLabel.bottom
                    right: parent.right
                    left: parent.left
                }

                ListModel {
                    id: downloadItemsModel
                    dynamicRoles: true
                }

                Repeater {
                    id: downloadItems
                    Layout.fillWidth: true
                    model: downloadItemsModel
                    delegate: MediaItem {
                        Layout.fillWidth: true
                        height: 100
                        width: parent.width

                        itemIndex: index
                        videoTitle: vTitle
                        thumbnail: vThumbnail
                        duration: vDuration
                        videoLink: vID

                        vcodec: vCodec
                        resolutionModel: vResolutions
                        videoExts: vVideoExts
                        videoFormats: vVideoFormats
                        videoProgress: 0.2
                        videoIndex: vVideoIndex
                        audioIndex: vAudioIndex

                        acodec: aCodec
                        audioExts: vAudioExts
                        audioFormats: vAudioFormats
                        audioBitrate: vABR
                        audioSizes: vAudioSizes

                        sizeModel: vSizeModel
                        indexID: vIndex

                    }
                }
            }
        }
    }

    Dialog {
        id: settingsDialog
        x: Math.round((window.width - width) / 2)
        y: Math.round(window.height / 6)
        width: Math.round(Math.min(window.width, window.height) / 3 * 2)
        modal: true
        focus: true
        title: "Settings"

        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: {
            settings.style = styleBox.displayText
            settingsDialog.close()
        }
        onRejected: {
            styleBox.currentIndex = styleBox.styleIndex
            settingsDialog.close()
        }

        contentItem: ColumnLayout {
            id: settingsColumn
            spacing: 20

            RowLayout {
                spacing: 10

                Label {
                    text: "Style:"
                }

                ComboBox {
                    id: styleBox
                    property int styleIndex: -1
                    model: window.builtInStyles
                    Component.onCompleted: {
                        styleIndex = find(settings.style, Qt.MatchFixedString)
                        if (styleIndex !== -1)
                            currentIndex = styleIndex
                    }
                    Layout.fillWidth: true
                }
            }

            Label {
                text: "Restart required"
                color: "#e41e25"
                opacity: styleBox.currentIndex !== styleBox.styleIndex ? 1.0 : 0.0
                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    Dialog {
        id: aboutDialog
        modal: true
        focus: true
        title: "About"
        x: (window.width - width) / 2
        y: window.height / 6
        width: Math.min(window.width, window.height) / 3 * 2
        contentHeight: aboutColumn.height

        Column {
            id: aboutColumn
            spacing: 20

            Label {
                width: aboutDialog.availableWidth
                text: "The Qt Quick Controls module delivers the next generation user interface controls based on Qt Quick."
                wrapMode: Label.Wrap
                font.pixelSize: 12
            }

            Label {
                width: aboutDialog.availableWidth
                text: "In comparison to Qt Quick Controls 1, Qt Quick Controls "
                      + "are an order of magnitude simpler, lighter, and faster."
                wrapMode: Label.Wrap
                font.pixelSize: 12
            }
        }
    }

    Dialog {
        id: invalidDownloadWarning
        modal: true
        focus: true
        title: "Download Invalid!"
        x: (window.width - width) / 2
        y: window.height / 3
        width: Math.min(window.width, window.height) / 3 * 2
        contentHeight: warningLabel.height + 10

        header: Label {
            text: parent.title
            topPadding: 10
            font.pixelSize: 22
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            id: warningLabel
            text: "Please refresh download link."
        }
        standardButtons: Dialog.Ok

        footer: DialogButtonBox {
//            anchors.left: parent.left
            anchors.right: parent.right
        }
    }
}
