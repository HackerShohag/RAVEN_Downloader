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
import os
from pathlib import Path
import sys

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from python.DownloadManager import DownloadManager


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

#    DownloadEngine = DownloadManager()
    DownloadEngine = DownloadManager()
    engine.rootContext().setContextProperty("downloadeng", DownloadEngine)


    engine.load(os.fspath(Path(__file__).resolve().parent / "qml/MainPage.qml"))
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
