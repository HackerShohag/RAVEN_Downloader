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

DownloadManager::DownloadManager(QObject *parent) : QObject{parent}
{
    connect(this, SIGNAL(authorChanged(QString)), this, SLOT(actionSubmit(QString)));

    this->ytdl = new YoutubeDL();

    qDebug() << "Constructor of DownloadManager";
}

QString DownloadManager::author() const
{
    return m_author;
}

void DownloadManager::setAuthor(const QString &a)
{
    if (a != m_author) {
        m_author = a;
        emit authorChanged(m_author);
    }
}

MediaFormat *DownloadManager::getMediaFormats()
{
    return this->m_mediaFormats;
}

void DownloadManager::setMediaFormats(MediaFormat *f)
{
    this->m_mediaFormats = f;
}

void DownloadManager::actionSubmit(QString url)
{
    QList<QJsonObject> result = this->ytdl->fetchJSONAvailableFormats(url);

    for (int i = 0; i < result.length(); ++i) {
        this->m_mediaFormats->setFormatIdItem(result.value(i)["format_id"].toString());
        this->m_mediaFormats->setFormatItem(result.value(i)["format"].toString());
        this->m_mediaFormats->setExtensionItem(result.value(i)["ext"].toString());
        this->m_mediaFormats->setNoteItem(result.value(i)["format_note"].toString());
        this->m_mediaFormats->setResolutionItem(result.value(i)["resolution"].toString());
        this->m_mediaFormats->setVcodecItem(result.value(i)["vcodec"].toString());
        this->m_mediaFormats->setAcodecItem(result.value(i)["acodec"].toString());
    }
}

bool DownloadManager::isValidUrl(QString url)
{
    return YoutubeDL::isValidUrl(url);
}

void DownloadManager::sayHello(QString hello)
{
    qDebug() << "Hello, " << hello;
}
