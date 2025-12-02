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
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import "version.js" as Version

/**
 * AboutPage - Application information and credits
 * Displays app version, features, developer info, and technologies used
 */
Dialog {
    id: aboutDialogue
    title: i18n.tr("About RAVEN Downloader")
    
    Flickable {
        width: parent.width
        height: Math.min(contentHeight, units.gu(50))
        contentHeight: aboutContent.height
        clip: true
        
        ColumnLayout {
            id: aboutContent
            width: parent.width
            spacing: units.gu(1)
            
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.bold: true
                text: "RAVEN Downloader"
            }
            
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: "Version " + Version.BUILD_VERSION
            }
            
            Label {
                Layout.fillWidth: true
                Layout.topMargin: units.gu(1)
                wrapMode: Text.WordWrap
                font.bold: true
                text: i18n.tr("Multi-Platform Video Downloader")
            }
            
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: i18n.tr("Download videos from 12+ platforms including YouTube, Vimeo, Dailymotion, Twitch, Facebook, Instagram, Twitter, TikTok, SoundCloud, Reddit, and Bilibili.")
            }
            
            Label {
                Layout.fillWidth: true
                Layout.topMargin: units.gu(1)
                wrapMode: Text.WordWrap
                font.bold: true
                text: i18n.tr("Features:")
            }
            
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: "• " + i18n.tr("Multi-platform support with smart URL detection") + "\n" +
                      "• " + i18n.tr("Playlist downloads (platform-dependent)") + "\n" +
                      "• " + i18n.tr("Custom format and quality selection") + "\n" +
                      "• " + i18n.tr("Native ContentHub integration") + "\n" +
                      "• " + i18n.tr("Subtitle & caption support")
            }
            
            Label {
                Layout.fillWidth: true
                Layout.topMargin: units.gu(1)
                wrapMode: Text.WordWrap
                font.bold: true
                text: i18n.tr("Developer:")
            }
            
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: "Abdullah AL Shohag"
            }
            
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                color: theme.palette.normal.activity
                text: "<a href='mailto:HackerShohag@outlook.com'>HackerShohag@outlook.com</a>"
                onLinkActivated: Qt.openUrlExternally(link)
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }
            
            Label {
                Layout.fillWidth: true
                Layout.topMargin: units.gu(1)
                wrapMode: Text.WordWrap
                font.bold: true
                text: i18n.tr("Report Bugs & Send Feedback:")
            }
            
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                color: theme.palette.normal.activity
                text: "<a href='https://t.me/HackerShohag'>Telegram: @HackerShohag</a>"
                onLinkActivated: Qt.openUrlExternally(link)
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }

            Label {
                Layout.fillWidth: true
                Layout.topMargin: units.gu(1)
                wrapMode: Text.WordWrap
                font.bold: true
                text: i18n.tr("Technologies & Libraries:")
            }

            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                color: theme.palette.normal.activity
                text: "• <a href='https://github.com/yt-dlp/yt-dlp'>yt-dlp</a> (1800+ site extractors)<br>" +
                      "• <a href='https://ffmpeg.org'>FFmpeg</a> 8.0.1<br>"
                onLinkActivated: Qt.openUrlExternally(link)
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }
            
            Label {
                Layout.fillWidth: true
                Layout.topMargin: units.gu(1)
                wrapMode: Text.WordWrap
                font.bold: true
                text: i18n.tr("License:")
            }
            
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: "GNU GPL v3.0"
            }
            
            Label {
                Layout.fillWidth: true
                Layout.topMargin: units.gu(1)
                wrapMode: Text.WordWrap
                font.bold: true
                text: i18n.tr("Source Code:")
            }
            
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                color: theme.palette.normal.activity
                text: "<a href='https://github.com/HackerShohag/RAVEN_Downloader'>https://github.com/HackerShohag/RAVEN_Downloader</a>"
                onLinkActivated: Qt.openUrlExternally(link)
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }

        }
    }
    
    Button {
        text: i18n.tr("Close")
        color: theme.palette.normal.positive
        onClicked: PopupUtils.close(aboutDialogue)
    }
}
