/**
 * @file youtubedl.cpp
 * @brief Implementation of dual-mode yt-dlp metadata fetcher
 * 
 * Implements video metadata fetching using either:
 * 1. Embedded Python API (m_python->runYtDlpExtract())
 * 2. QProcess subprocess execution (yt-dlp_linux binary)
 * 
 * The implementation handles JSON parsing, playlist processing, and
 * signal emission for both modes transparently.
 * 
 * Implementation Details:
 * - Constructor determines mode based on EmbeddedPython initialization status
 * - fetchWithPython() handles JSON array splitting for playlists
 * - fetchWithQProcess() maintains legacy subprocess behavior
 * - All methods emit updateQString for each video entry
 * 
 * Original Source:
 *   youtube-dl-qt by Robin de Rooij (https://github.com/rrooij/youtube-dl-qt)
 *   Licensed under GNU GPL v3 or later
 *   Extensively modified for RAVEN Downloader project
 * 
 * @author Robin de Rooij (original), Abdullah AL Shohag (modifications)
 * @date 2022-2025
 * @copyright GNU General Public License v3.0 or later
 */

#include <QRegExpValidator>
#include <QDebug>
#include <QUrlQuery>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

#include "youtubedl.h"
#include "embedded_python.h"

/**
 * @brief Constructs YoutubeDL with optional Python support
 * 
 * @param python Optional EmbeddedPython instance for API mode (nullptr for QProcess mode)
 * @param parent Parent QObject for Qt ownership hierarchy
 * 
 * If python is provided and initialized, the object operates in Python API mode.
 * Otherwise, it falls back to QProcess mode using the yt-dlp_linux binary.
 */
YoutubeDL::YoutubeDL(EmbeddedPython* python, QObject* parent)
    : QObject(parent)
    , m_python(python)
    , m_usePythonMode(python && python->isInitialized())
{
    this->ytdl = new QProcess();
    this->program = "yt-dlp_linux";
    this->ytdl->setProcessChannelMode(QProcess::SeparateChannels);
    // playlist_title
    connect(this->ytdl, SIGNAL(readyReadStandardOutput()), this, SLOT(readyReadStandardOutput()));
    connect(this->ytdl,SIGNAL(readyRead()), this, SLOT(readyReadStandardOutput()));
    connect(this->ytdl,SIGNAL(finished(int, QProcess::ExitStatus)), this, SLOT(finishedSlot(int, QProcess::ExitStatus)));
    connect(this->ytdl, SIGNAL(errorOccurred(QProcess::ProcessError)), this, SLOT(emitErrorMessage(QProcess::ProcessError)));
    
    qDebug() << "YoutubeDL initialized. Python mode:" << m_usePythonMode;
    if (m_usePythonMode) {
        qDebug() << "yt-dlp version:" << QString::fromStdString(m_python->getYtDlpVersion());
    }
}

YoutubeDL::~YoutubeDL()
{
    this->ytdl->close();
    delete ytdl;
}

void YoutubeDL::fetchSingleFormats(QString url)
{
    qInfo() << Q_FUNC_INFO << "URL:" << url;
    
    if (m_usePythonMode) {
        fetchWithPython(url, false);
    } else {
        fetchWithQProcess(url, false);
    }
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

void YoutubeDL::startForPlayList(QString url)
{
    qInfo() << Q_FUNC_INFO << "Playlist URL:" << url;
    
    if (m_usePythonMode) {
        fetchWithPython(url, true);
    } else {
        fetchWithQProcess(url, true);
    }
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

void YoutubeDL::fetchWithPython(const QString& url, bool isPlaylist)
{
    qDebug() << "Fetching with Python API. Playlist:" << isPlaylist;
    
    // Call embedded Python yt-dlp
    auto result = m_python->runYtDlpExtract(url.toStdString(), isPlaylist);
    
    if (result.first) {
        // Success - emit JSON data
        QString jsonData = QString::fromStdString(result.second);
        qDebug() << "Python fetch successful. JSON length:" << jsonData.length();
        
        if (isPlaylist) {
            // For playlists, we need to emit each video entry separately
            QJsonDocument doc = QJsonDocument::fromJson(jsonData.toUtf8());
            if (doc.isObject()) {
                QJsonObject playlistObj = doc.object();
                QJsonArray entries = playlistObj["entries"].toArray();
                
                qDebug() << "Playlist has" << entries.size() << "entries";
                
                // Emit each entry as separate JSON
                for (const QJsonValue& entry : entries) {
                    if (entry.isObject()) {
                        QJsonDocument entryDoc(entry.toObject());
                        QString entryJson = QString::fromUtf8(entryDoc.toJson(QJsonDocument::Compact));
                        emit updateQString(entryJson);
                    }
                }
            }
        } else {
            // Single video - emit directly
            emit updateQString(jsonData);
        }
        
        // Signal completion
        emit dataFetchFinished();
    } else {
        // Error - emit error signal
        QString errorMsg = QString::fromStdString(result.second);
        qWarning() << "Python fetch failed:" << errorMsg;
        emit qProcessError(QProcess::UnknownError);
        emit dataFetchFinished();
    }
}

void YoutubeDL::fetchWithQProcess(const QString& url, bool isPlaylist)
{
    qDebug() << "Fetching with QProcess (fallback mode)";
    
    this->arguments.clear();
    this->arguments << "-j";
    
    if (isPlaylist) {
        this->arguments << extractPlaylistUrl(url);
    } else {
        this->arguments << "--no-playlist" << "--flat-playlist" << url;
    }
    
    this->ytdl->setProcessChannelMode(QProcess::SeparateChannels);
    this->ytdl->start(this->program, this->arguments);
    this->resetArguments();
}

void YoutubeDL::resetArguments()
{
    this->arguments.clear();
}
