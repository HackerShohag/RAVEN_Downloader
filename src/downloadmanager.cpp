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

#include <QDebug>
#include "downloadmanager.h"
#include "youtubedl.h"

DownloadManager::DownloadManager(QObject *parent) : QObject{parent}
{
    qDebug() << "Constructor of DownloadManager";
}

QString DownloadManager::author() const {
    return m_author;
}

void DownloadManager::setAuthor(const QString &a) {
    if (a != m_author) {
        m_author = a;
        emit authorChanged(m_author);
    }
}

bool DownloadManager::isValidUrl(QString url) {
    return YoutubeDL::isValidUrl(url);
}

void DownloadManager::sayHello(QString hello) {
    qDebug() << "Hello, " << hello;
}
