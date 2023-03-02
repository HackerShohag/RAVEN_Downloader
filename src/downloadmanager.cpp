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
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include "downloadmanager.h"

DownloadManager::DownloadManager(QObject *parent) : QObject{parent}
{
    connect(this->ytdl, SIGNAL(updateData(QList<QJsonObject>)), this, SLOT(setFormats(QList<QJsonObject>)));
    qDebug() << "Constructor of DownloadManager";
}

MediaFormat *DownloadManager::getMediaFormats()
{
    return this->m_mediaFormats;
}

QJsonDocument DownloadManager::loadJson(QString fileName) {
    QFile jsonFile(fileName);
    jsonFile.open(QFile::ReadOnly);
    return QJsonDocument().fromJson(jsonFile.readAll());
}

void DownloadManager::saveJson(QJsonDocument document, QString fileName) {
    QFile jsonFile(fileName);
    jsonFile.open(QFile::WriteOnly);
    jsonFile.write(document.toJson());
}

void DownloadManager::actionSubmit(QString url)
{
    this->ytdl->fetchAvailableFormats(url);
}

void DownloadManager::setFormats(QList<QJsonObject> result)
{
    this->m_mediaFormats->setTitle(result.value(0)["title"].toString());
    this->m_mediaFormats->setThumbnail(result.value(0)["thumbnail"].toString());
    this->m_mediaFormats->setDuration(result.value(0)["duration"].toString());

    qDebug() << "DownloadManager::setFormats(): Title:" << result.value(2)["format_id"].toString();

    for (int i = 1; i < result.length(); ++i) {
        this->m_mediaFormats->setFormatIdItem(result.value(i)["format_id"].toString());
        this->m_mediaFormats->setFormatItem(result.value(i)["format"].toString());
        this->m_mediaFormats->setExtensionItem(result.value(i)["ext"].toString());
        this->m_mediaFormats->setNoteItem(result.value(i)["format_note"].toString());
        this->m_mediaFormats->setResolutionItem(result.value(i)["resolution"].toString());
        this->m_mediaFormats->setVcodecItem(result.value(i)["vcodec"].toString());
        this->m_mediaFormats->setAcodecItem(result.value(i)["acodec"].toString());
        this->m_mediaFormats->setUrlItem(result.value(i)["url"].toString());
        this->m_mediaFormats->setFilesizeItem(result.value(i)["filesize"].toDouble());
    }
    emit formatsUpdated();
}

bool DownloadManager::isValidUrl(QString url)
{
    return YoutubeDL::isValidUrl(url);
}
