/* youtube-dl-qt is Free Software: You can use, study share
 * and improve it at your will. Specifically you can redistribute
 * and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 * 
 * The original author of this code : Robin de Rooij (https://github.com/rrooij)
 * The original repository of this code : https://github.com/rrooij/youtube-dl-qt 
 */

#ifndef YOUTUBEDL_H
#define YOUTUBEDL_H

#include <QJsonObject>
#include <QProcess>
#include <QVector>

class YoutubeDL: public QObject {
    Q_OBJECT
public:
    YoutubeDL();
    ~YoutubeDL();
    QJsonObject createJsonObject(QString url);
    void fetchAvailableFormats(QString url);
    QString extractPlaylistUrl(QString url);
    QProcess *getYtdl();
    void resetArguments();
    static bool isValidUrl(QString url);
    void setFormat(QString format);
    void startDownload(QString url, QString workingDirectory);
    void addArguments(QString arg);

    // playlist compatible methods
    void startForPlayList(QString url);

public slots:
    QList<QJsonObject> createFormats(QJsonObject jsonObject);
    void readyReadStandardOutput();

signals:
    void updateData(QList<QJsonObject> value);

private:
    QStringList arguments;
    QString program;
    QProcess *ytdl;
};

#endif // YOUTUBEDL_H
