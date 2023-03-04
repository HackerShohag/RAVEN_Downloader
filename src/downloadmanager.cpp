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
#include <QUrl>
#include <QUrlQuery>
#include <QJsonDocument>
#include <QJsonArray>
#include "downloadmanager.h"

DownloadManager::DownloadManager(QObject *parent) : QObject{parent}
{
    connect(this->ytdl, SIGNAL(updateQString(QString)), this, SLOT(checkJsonObject(QString)));
    qDebug() << "Constructor of DownloadManager";
}

void DownloadManager::checkJsonObject(QString value) {
    this->tempJSONDataHolder.append(value);

    QJsonDocument jsonDocument = QJsonDocument::fromJson(tempJSONDataHolder.toUtf8());

    if (jsonDocument.isObject()) {
        setFormats(jsonDocument.object());
        this->tempJSONDataHolder.clear();
    }
}

DownloadManager::~DownloadManager()
{
    delete m_mediaFormats;
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

bool DownloadManager::isValidPlayListUrl(QString url) {
    if (QUrlQuery(QUrl(url).query()).queryItemValue("list").isEmpty()) {
        return false;
    }
    return true;
}

void DownloadManager::actionSubmit(QString url, int index)
{
    this->ytdl->setFormat("mp4");
    if (index) {
        this->ytdl->startForPlayList(url);
        return ;
    }
    this->ytdl->fetchSingleFormats(url);
}

void DownloadManager::setFormats(QJsonObject jsonObject)
{
    this->m_mediaFormats->clearClutter();
    this->m_mediaFormats->setTitle(jsonObject["title"].toString());
    this->m_mediaFormats->setThumbnail(jsonObject["thumbnail"].toString());
    this->m_mediaFormats->setDuration(jsonObject["duration_string"].toString());

    qDebug() << "DownloadManager::setFormats(): Title:" << jsonObject["title"].toString();

    QJsonArray jsonFormats = jsonObject["formats"].toArray();
    QJsonArray::iterator i;

    for (i = jsonFormats.begin(); i != jsonFormats.end(); ++i) {
        QJsonValue value = *i;
        QJsonObject formatObject = value.toObject();
        this->m_mediaFormats->setFormatIdItem(formatObject["format_id"].toString());
        this->m_mediaFormats->setFormatItem(formatObject["format"].toString());
        this->m_mediaFormats->setExtensionItem(formatObject["ext"].toString());
        this->m_mediaFormats->setNoteItem(formatObject["format_note"].toString());
        this->m_mediaFormats->setResolutionItem(formatObject["resolution"].toString());
        this->m_mediaFormats->setVcodecItem(formatObject["vcodec"].toString().trimmed());
        this->m_mediaFormats->setAcodecItem(formatObject["acodec"].toString().trimmed());
        this->m_mediaFormats->setUrlItem(formatObject["url"].toString());
        this->m_mediaFormats->setFilesizeItem(formatObject["filesize"].toDouble()/1048576);
    }
    emit formatsUpdated();
}

bool DownloadManager::isValidUrl(QString url)
{
    if (QUrl(url).host() == "youtu.be")
        return true;
    QUrlQuery query(QUrl(url).query());

    if (QUrl(url).host().contains("youtube")) {
        if (query.queryItemValue("v").isEmpty())
            return false;
    }
    return YoutubeDL::isValidUrl(url);
}
