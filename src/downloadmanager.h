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
#include <QVector>
#include <QJsonObject>
#include <youtubedl.h>
#include <mediaformat.h>
#include <QStandardPaths>

class DownloadManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MediaFormat *mediaFormats READ getMediaFormats NOTIFY mediaFormatsChanged);

public:
    explicit DownloadManager(QObject *parent = nullptr);
    ~DownloadManager();
    MediaFormat *getMediaFormats();
    QJsonDocument loadJson(QString fileName);
    void saveJson(QJsonDocument document, QString fileName);

public slots:
    void actionSubmit(QString url, int index);
    void actionDownload(QString url, QString format, int indexID);
    void stopProcess();
    void setFormats(QJsonObject jsonObject);
    bool isValidUrl(QString url);
    bool isValidPlayListUrl(QString url);
    void checkJsonObject(QString value);
    void finishedFetching();

    void debugInfo(QProcess *downloader, int indexID);

signals:
    void mediaFormatsChanged();
    void formatsUpdated();
    void invalidPlaylistUrl();
    void finished(QString playlistTitle, int entries);
    void downloadProgress(QString value, int indexID);

private:
    YoutubeDL *ytdl = new YoutubeDL();
//    QProcess *downloader;
    MediaFormat *m_mediaFormats = new MediaFormat();
    QString tempJSONDataHolder;
    QString playlistTitle;
    int entries;
    QString configPath = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
    QString cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    QString appDataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

};

#endif
