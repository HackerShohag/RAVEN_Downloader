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

#define PY_SSIZE_T_CLEAN
#include <Python.h>

#include <QDebug>
#include <QUrlQuery>
#include <QRegularExpressionValidator>

#include "youtubedl.h"

YoutubeDL::YoutubeDL()
{
    qDebug() << "YTDL Constructor";
    Py_Initialize();

    PyRun_SimpleString("import sys");
    PyRun_SimpleString("import os");
    PyRun_SimpleString("sys.path.append(os.getcwd())");

    PyObject *args=NULL;
    qDebug() << "Py_Initialize() from ytdl";

    PyObject* yt_dlp = PyImport_ImportModule("yt_dlp");
    PyErr_Print();
    PyObject* value = PyObject_GetAttrString(yt_dlp, "version.RELEASE_GIT_HEAD");
//    PyObject* pvalue = PyObject_CallObject(pFunc, args);
//    Py_XDECREF(pFunc);
    PyRun_SimpleString("print(yt_dlp.version.RELEASE_GIT_HEAD)");

    PyObject* repr = PyObject_Repr(value);
    PyObject* str = PyUnicode_AsEncodedString(repr, "utf-8", "~E~");
    qDebug() << "value from py: " << PyBytes_AS_STRING(str);

    Py_FinalizeEx();

    this->ytdl = new QProcess();
    this->program = "assets:/yt-dlp_linux";
    this->ytdl->setProcessChannelMode(QProcess::SeparateChannels);
    // playlist_title
    connect(this->ytdl, SIGNAL(readyReadStandardOutput()), this, SLOT(readyReadStandardOutput()));
    connect(this->ytdl, SIGNAL(readyRead()), this, SLOT(readyReadStandardOutput()));
    connect(this->ytdl, SIGNAL(finished(int, QProcess::ExitStatus)), this, SLOT(finishedSlot(int, QProcess::ExitStatus)));
    connect(this->ytdl, SIGNAL(errorOccurred(QProcess::ProcessError)), this, SLOT(emitErrorMessage(QProcess::ProcessError)));
}

YoutubeDL::~YoutubeDL()
{
    this->ytdl->close();
    delete ytdl;
}

void YoutubeDL::fetchSingleFormats(QString url)
{
    qInfo() << Q_FUNC_INFO;
    this->arguments << "-j" << "--no-playlist" << "--flat-playlist" << url;
    this->ytdl->setProcessChannelMode(QProcess::SeparateChannels);
    this->ytdl->start(this->program, this->arguments);
    this->resetArguments();
}

QString YoutubeDL::extractPlaylistUrl(QString url)
{
    QString listValue = QUrlQuery(QUrl(url).query()).queryItemValue("list");
    return "https://www.youtube.com/playlist?list="+ listValue;
}

QString YoutubeDL::extractSingleVideoUrl(QString url)
{
    if ((QUrl(url).host() == "youtu.be"))
        return url;
    QString vValue = QUrlQuery(QUrl(url).query()).queryItemValue("v");
    return "https://www.youtube.com/watch?v="+ vValue;
}

bool YoutubeDL::isValidUrl(QString url)
{
    QRegularExpression urlRegex("^(http|https)://[a-z0-9]+([-.]{1}[a-z0-9]+)*.[a-z]{2,5}(([0-9]{1,5})?/?.*)$");
    QRegularExpressionValidator validator(urlRegex);
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

void YoutubeDL::startForPlayList(QString url)
{
    arguments << "-j" << extractPlaylistUrl(url);
    ytdl->setProcessChannelMode(QProcess::SeparateChannels);
    ytdl->start(this->program, this->arguments);
    this->resetArguments();
}

void YoutubeDL::stopConnection()
{
    this->ytdl->close();
}

void YoutubeDL::readyReadStandardOutput()
{
    qDebug() << Q_FUNC_INFO;
    QByteArray output = this->ytdl->readAll().trimmed();
    emit updateQString(output);
}

void YoutubeDL::finishedSlot(int exitCode, QProcess::ExitStatus exitStatus)
{
    qDebug() << "exitCode:" << exitCode << "exitStatus:" << exitStatus;
    emit dataFetchFinished();
}

void YoutubeDL::emitErrorMessage(QProcess::ProcessError error)
{
    emit qProcessError(error);
}

void YoutubeDL::resetArguments()
{
    this->arguments.clear();
}
