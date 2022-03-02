'''
 Copyright (C) 2022 Team RAVEN

 Authors:
  Abdullah AL Shohag <HackerShohag@outlook.com>
  Mehedi Hasan Maruf <meek.er.007@protonmail.com>

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; version 3.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
'''

# This Python file uses the following encoding: utf-8
from PySide6 import QtCore
import youtube_dl

#class Console(QtCore.QObject):
#    @QtCore.Slot(str)
#    def outputStr(self, s):
#        print(s)

class DownloadManager(QtCore.QObject):
    def __init__(self):
        super(DownloadManager, self).__init__()
        print("Not defined yet")

    @QtCore.Slot(str)
    def getHistoy(self, text):
        print("Not defined yet")

    @QtCore.Slot(str,result=list)
    def getDownloadLinks(self, url):
        with youtube_dl.YoutubeDL({}) as ydl:
            result = ydl.extract_info(url, download=False)
        if 'entries' in result:
            videos = result['entries'][0]
        else:
            videos = result
        r_videos = []
        for video in videos['formats']:
            r_videos.append([{'url': video['url'], 'format': video['format'], 'size': video['filesize']}])
        return r_videos
