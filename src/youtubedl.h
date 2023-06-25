/* youtube-dl-qt is Free Software: You can use, study share
 * and improve it at your will. Specifically you can redistribute
 * and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This source have been modified significantly to adapt with the project.
 *
 * The original author of this code : Robin de Rooij (https://github.com/rrooij)
 * The original repository of this code : https://github.com/rrooij/youtube-dl-qt
 */

#ifndef YOUTUBEDL_H
#define YOUTUBEDL_H

#include <QProcess>

class YoutubeDL: public QObject
{
    Q_OBJECT
public:
    YoutubeDL();
    ~YoutubeDL();
    void fetchSingleFormats(QString url);
    static QString extractPlaylistUrl(QString url);
    static QString extractSingleVideoUrl(QString url);
    QProcess *getYtdl();
    void resetArguments();
    static bool isValidUrl(QString url);
    void setFormat(QString format);
    void startDownload(QString url, QString workingDirectory);
    void addArguments(QString arg);

    // playlist compatible methods
    void startForPlayList(QString url);

    // stopping connection
    void stopConnection();

public slots:
    void readyReadStandardOutput();
    void finishedSlot(int exitCode, QProcess::ExitStatus exitStatus);
    void emitErrorMessage(QProcess::ProcessError error);

signals:
    void updateQString(QString value);
    void dataFetchFinished();
    void qProcessError(QProcess::ProcessError error);

private:
    QStringList arguments;
    QString program;
    QProcess *ytdl;
};

#endif // YOUTUBEDL_H
