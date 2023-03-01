/* youtube-dl-qt is Free Software: You can use, study share
 * and improve it at your will. Specifically you can redistribute
 * and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 * 
 * The original author of this code : Robin de Rooij (https://github.com/rrooij)
 * The original repository of this code : https://github.com/rrooij/youtube-dl-qt
 */

#include <QGuiApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValueRef>
#include <QJsonValue>
#include <QRegExp>
#include <QRegExpValidator>
#include <QString>
#include <QStringList>
#include <QProcess>
#include <QDebug>

#include "youtubedl.h"

YoutubeDL::YoutubeDL()
{
    this->program = "yt-dlp"; // "youtube-dl";
    QObject *parent = QGuiApplication::instance();
    this->ytdl = new QProcess(parent);
    this->ytdl->setProcessChannelMode(QProcess::MergedChannels);
}

YoutubeDL::~YoutubeDL() {
}

QJsonObject YoutubeDL::createJsonObject(QString url)
{
    arguments << "-j" << "--no-playlist" << "--flat-playlist" << url;
    ytdl->setProcessChannelMode(QProcess::SeparateChannels);
    ytdl->start(this->program, this->arguments);
    ytdl->waitForFinished();
    QByteArray output(this->ytdl->readAllStandardOutput());
    QJsonDocument json = QJsonDocument::fromJson(output);
    this->resetArguments();
    return json.object();
}

QList<QJsonObject> YoutubeDL::fetchAvailableFormats(QString url)
{
    QList<QJsonObject> formats;

    QJsonObject jsonObject = createJsonObject(url);

    this->title = jsonObject["title"].toString();
    this->thumbnail = jsonObject["thumbnail"].toString();
    this->duration = jsonObject["duration_string"].toString();

    QJsonArray jsonFormats = jsonObject["formats"].toArray();
    QJsonArray::iterator i;
    QJsonObject format;

    for (i = jsonFormats.begin(); i != jsonFormats.end(); ++i) {
        QJsonValue value = *i;
        QJsonObject formatObject = value.toObject();
        format.insert("format_id", QJsonValue(formatObject["format_id"].toString()));
        format.insert("url", QJsonValue(formatObject["url"].toString()));
        format.insert("format", QJsonValue(formatObject["format"].toString()));
        format.insert("ext", QJsonValue(formatObject["ext"].toString()));
        format.insert("format_note", QJsonValue(formatObject["format_note"].toString()));
        format.insert("resolution", QJsonValue(formatObject["resolution"].toString()));
        format.insert("vcodec", QJsonValue(formatObject["vcodec"].toString().trimmed()));
        format.insert("acodec", QJsonValue(formatObject["acodec"].toString().trimmed()));
        format.insert("filesize", QJsonValue(formatObject["filesize"].toDouble()/1048576));
//        qDebug() << "Filesize: " << formatObject["filesize"].toDouble()/1048576;

        formats.append(format);
    }
    return formats;
}

QString YoutubeDL::getUrl(QString url)
{
    qDebug() << "Started getUrl function";
    this->arguments << "-g" << url;
    this->ytdl->start(this->program, this->arguments);
    this->ytdl->waitForFinished();
    qDebug() << "Program:" << this->program << "arguments:" << this->arguments;
//    qDebug() << "standard output:" << this->ytdl->readAllStandardOutput();
    QString output(this->ytdl->readAllStandardOutput());
    qDebug() << "Output:" << output;
    qDebug() << "Error:" << this->ytdl->readAllStandardError();
    qDebug() << "Finished getUrl function";
    return output;
}

bool YoutubeDL::isValidUrl(QString url)
{
    QRegExp urlRegex("^(http|https)://[a-z0-9]+([-.]{1}[a-z0-9]+)*.[a-z]{2,5}(([0-9]{1,5})?/?.*)$");
    QRegExpValidator validator(urlRegex);
    int index = 0;

    if(validator.validate(url, index) == QValidator::Acceptable) {
        return true;
    }
    return false;
}

void YoutubeDL::setFormat(QString format)
{
    this->arguments << "-f" << format;
}

void YoutubeDL::startDownload(QString url, QString workingDirectory)
{
    this->arguments << url;
    this->ytdl->setWorkingDirectory(workingDirectory);
    this->ytdl->start(this->program, this->arguments);
}

QProcess* YoutubeDL::getYtdl()
{
    return this->ytdl;
}

void YoutubeDL::addArguments(QString arg)
{
    this->arguments << arg;
}

QString YoutubeDL::getMediaTitle()
{
    return this->title;
}

QString YoutubeDL::getThumbnail()
{
    return this->thumbnail;
}

QString YoutubeDL::getDuration()
{
    return this->duration;
}

void YoutubeDL::resetArguments()
{
    this->arguments.clear();
}
