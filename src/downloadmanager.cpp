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
    connect(this->ytdl, SIGNAL(dataFetchFinished()), this, SLOT(finishedFetching()));
    qDebug() << "Constructor of DownloadManager";
}

DownloadManager::~DownloadManager()
{
    delete m_mediaFormats;
}

void DownloadManager::checkJsonObject(QString value)
{
    this->tempJSONDataHolder.append(value);

    QJsonDocument jsonDocument = QJsonDocument::fromJson(tempJSONDataHolder.toUtf8());

    if (jsonDocument.isObject()) {
        setFormats(jsonDocument.object());
        this->tempJSONDataHolder.clear();
    }
}

void DownloadManager::finishedFetching()
{
    emit finished(this->playlistTitle, this->entries);
    this->playlistTitle.clear();
    this->entries = 0;
}

void DownloadManager::downloadProgressSlot(QProcess *downloader, qint64 indexID)
{
    QString output = downloader->readAllStandardOutput();
    QRegExp rx("\\d+.\\d+%");
    rx.indexIn(output);
    QStringList f = rx.capturedTexts();
    qDebug() << output;
    if (!(f[0].isEmpty()))
        emit downloadProgress(QString::number(qRound(f[0].replace("%","").toDouble())), indexID);
}

MediaFormat *DownloadManager::getMediaFormats()
{
    return this->m_mediaFormats;
}

QJsonDocument DownloadManager::loadJson(QString fileName)
{
    QFile jsonFile(fileName);
    jsonFile.open(QFile::ReadOnly);
    return QJsonDocument().fromJson(jsonFile.readAll());
}

void DownloadManager::saveListModelData(QString value)
{
    QJsonDocument document = QJsonDocument::fromJson(value.toUtf8());
    saveJson(document, this->appDataPath + "/history.json");
}

bool DownloadManager::loadListModelData()
{
    QJsonDocument document = loadJson(this->appDataPath + "/history.json");
    emit listModelDataLoaded(QString(document.toJson(QJsonDocument::Compact)));
    if (document.isEmpty()) return false;
    return true;
}

void DownloadManager::saveJson(QJsonDocument document, QString fileName)
{
    QFile jsonFile(fileName);
    jsonFile.open(QFile::WriteOnly);
    jsonFile.write(document.toJson());
}

bool DownloadManager::isValidPlayListUrl(QString url)
{
    if (QUrlQuery(QUrl(url).query()).queryItemValue("list").isEmpty())
    {
        return false;
    }
    return true;
}

void DownloadManager::actionSubmit(QString url, int index)
{
    qDebug() << Q_FUNC_INFO;
    if (index) {
        this->ytdl->startForPlayList(this->ytdl->extractPlaylistUrl(url));
        return ;
    }
    this->ytdl->fetchSingleFormats(this->ytdl->extractSingleVideoUrl(url));
}

void DownloadManager::actionDownload(QString url, QString format, int indexID)
{
    qDebug() << Q_FUNC_INFO;
    QProcess *downloader = new QProcess();
    QStringList arguments;
    arguments << "-f" << format << url;
    qDebug() << "Arguments:" << arguments;
    downloader->setWorkingDirectory(this->appDataPath);
    downloader->start("yt-dlp", arguments);
    connect(downloader, &QProcess::readyReadStandardOutput, this, [this, downloader, indexID] {downloadProgressSlot(downloader, indexID);} );
    qDebug() << "Finished" << arguments;
}

void DownloadManager::stopProcess()
{
    this->ytdl->stopConnection();
}

void DownloadManager::setFormats(QJsonObject jsonObject)
{
    this->playlistTitle = jsonObject["playlist_title"].toString();
    this->entries = jsonObject["n_entries"].toInt();

    this->m_mediaFormats->clearClutter();
    this->m_mediaFormats->setTitle(jsonObject["title"].toString());
    this->m_mediaFormats->setThumbnail(jsonObject["thumbnail"].toString());
    this->m_mediaFormats->setDuration(jsonObject["duration_string"].toString());
    this->m_mediaFormats->setUrl(jsonObject["id"].toString());

    qDebug() << "DownloadManager::setFormats(): Title:" << jsonObject["title"].toString();

    QJsonArray jsonFormats = jsonObject["formats"].toArray();
    QJsonArray::iterator i;

    for (i = jsonFormats.begin(); i != jsonFormats.end(); ++i) {
        QJsonValue value = *i;
        QJsonObject formatObject = value.toObject();

        // audio formats
        if (formatObject["resolution"].toString().contains("audio")) {
            this->m_mediaFormats->setAcodecItem(formatObject["acodec"].toString().trimmed());
            this->m_mediaFormats->setAudioExtItem(formatObject["audio_ext"].toString());
            this->m_mediaFormats->setAudioFormatItem(formatObject["format_id"].toString());
            this->m_mediaFormats->setAudioBitrateItem(formatObject["abr"].toDouble());
        }

        //video formats
        if (formatObject["vcodec"].toString() != "none") {
            this->m_mediaFormats->setVcodecItem(formatObject["vcodec"].toString().trimmed());
            this->m_mediaFormats->setNoteItem(formatObject["format_note"].toString());
            this->m_mediaFormats->setResolutionItem(formatObject["resolution"].toString());
            this->m_mediaFormats->setVideoExtensionItem(formatObject["ext"].toString());
            this->m_mediaFormats->setVideoFormatItem(formatObject["format_id"].toString());
            this->m_mediaFormats->setFormatItem(formatObject["format"].toString());
            this->m_mediaFormats->setFilesizeItem(formatObject["filesize"].toDouble()/1048576);
        }
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

//void listModelToString() {
//  QJsonArray datamodel = [];
//  for (var i = 0; i < downloadItemsModel.count; ++i){
//    datamodel.push(downloadItemsModel.get(i));
//  }
//  var keysList = JSON.stringify(datamodel);
//  console.log(keysList[0]);
//  downloadManager.saveJson(datamodel, "/home/shohag/data3.json");
//}
