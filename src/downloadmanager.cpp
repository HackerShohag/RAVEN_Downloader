#include <QDebug>
#include "downloadmanager.h"
#include "youtubedl.h"

DownloadManager::DownloadManager(QObject *parent) : QObject{parent}
{
    qDebug() << "Constructor of DownloadManager";
}

QString DownloadManager::author() const {
    return m_author;
}

void DownloadManager::setAuthor(const QString &a) {
    if (a != m_author) {
        m_author = a;
        emit authorChanged(m_author);
    }
}

bool DownloadManager::isValidUrl(QString url) {
    return YoutubeDL::isValidUrl(url);
}

void DownloadManager::sayHello(QString hello) {
    qDebug() << "Hello, " << hello;
}
