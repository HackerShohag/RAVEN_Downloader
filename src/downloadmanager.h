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

class DownloadManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MediaFormat *mediaFormats READ getMediaFormats NOTIFY mediaFormatsChanged);

public:
    explicit DownloadManager(QObject *parent = nullptr);
    MediaFormat *getMediaFormats();
    QJsonDocument loadJson(QString fileName);
    void saveJson(QJsonDocument document, QString fileName);

public slots:
    void actionSubmit(QString url);
    void setFormats(QList<QJsonObject> result);
    bool isValidUrl(QString url);

signals:
    void mediaFormatsChanged();
    void formatsUpdated();

private:
    YoutubeDL *ytdl = new YoutubeDL();
    MediaFormat *m_mediaFormats = new MediaFormat();
};

#endif
