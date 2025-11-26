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

import QtQuick 2.7
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3

Dialog {
    id: dialogue
//    title: i18n.tr("Invalid Playlist URL!")
//    text: i18n.tr("Please provide a link with valid list argument.")
    Keys.onPressed: PopupUtils.close(dialogue)
    Button {
        text: i18n.tr("OK")
        onClicked: PopupUtils.close(dialogue)
    }
}
