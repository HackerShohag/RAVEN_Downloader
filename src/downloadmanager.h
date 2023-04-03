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

#ifndef DOWNLOADMANAGER_H
#define DOWNLOADMANAGER_H

#include <QObject>
#include <QJsonObject>
#include <QJsonDocument>
#include <QStandardPaths>

#include <youtubedl.h>
#include <mediaformat.h>

class DownloadManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MediaFormat *mediaFormats READ getMediaFormats NOTIFY mediaFormatsChanged);

public:
    explicit DownloadManager(QObject *parent = nullptr);
    ~DownloadManager();
    MediaFormat *getMediaFormats();

public slots:
    void actionSubmit(QString url, int index);
    void actionDownload(QString url, QJsonObject data);
    void stopProcess();
    void setFormats(QJsonObject jsonObject);
    bool isValidUrl(QString url);
    bool isValidPlayListUrl(QString url);
    void checkJsonObject(QString value);
    void finishedFetching();

    QJsonDocument loadJson(QString fileName);
    void saveJson(QJsonDocument document, QString fileName);
    void saveListModelData(QString value);
    bool loadListModelData();
    void downloadProgressSlot(QProcess *downloader, qint64 indexID);

    void errorMessage(QProcess::ProcessError errorMessage);

signals:
    void mediaFormatsChanged();
    void formatsUpdated(bool hasIndex, qint64 videoIndex = 0, qint64 audioIndex = 0, qint64 videoProgress = 0);
    void invalidPlaylistUrl();
    void finished(QString playlistTitle, qint64 entries);
    void downloadProgress(QString value, qint64 indexID);
    void listModelDataLoaded();
    void generalMessage(QString message);

private:
    YoutubeDL *ytdl = new YoutubeDL();
    MediaFormat *m_mediaFormats = new MediaFormat();
    QString configPath = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
    QString cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    QString appDataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QString tempJSONDataHolder;
    QString playlistTitle;
    qint64 entries = 0;
    QString downloadPath;
};

#endif
