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
#include <youtubedl.h>
#include <mediaformat.h>

class DownloadManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString author READ author WRITE setAuthor NOTIFY authorChanged);
    Q_PROPERTY(MediaFormat *mediaFormats READ getMediaFormats WRITE setMediaFormats NOTIFY mediaFormatsChanged);

public:
    explicit DownloadManager(QObject *parent = nullptr);
    QString author() const;
    void setAuthor(const QString &a);

    MediaFormat *getMediaFormats();
    void setMediaFormats(MediaFormat *f);

public slots:
    void actionSubmit(QString url);
    bool isValidUrl(QString url);
    void sayHello(QString hello);

signals:
    void authorChanged(const QString &m_string);
    void mediaFormatsChanged();

private:
    QString m_author;
    YoutubeDL *ytdl;
    MediaFormat *m_mediaFormats = new MediaFormat();
};

#endif // DOWNLOADMANAGER_H
