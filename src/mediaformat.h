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

#ifndef MEDIAFORMAT_H
#define MEDIAFORMAT_H

#include <QObject>
#include <QString>
#include <QStringList>

class MediaFormat : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString title READ getTitle NOTIFY titleChanged)
    Q_PROPERTY(QString thumbnail READ getThumbnail NOTIFY thumbnailChanged)
    Q_PROPERTY(QString duration READ getDuration NOTIFY durationChanged)
    Q_PROPERTY(QString videoUrl READ getUrl NOTIFY urlChanged)
    Q_PROPERTY(QStringList formatIds READ getFormatId NOTIFY formatIdChanged)
    Q_PROPERTY(QStringList formats READ getFormat NOTIFY formatChanged)
    Q_PROPERTY(QStringList extensions READ getExtension NOTIFY extensionChanged)
    Q_PROPERTY(QStringList resolutions READ getResolution NOTIFY resolutionChanged)
    Q_PROPERTY(QStringList qualities READ getQuality NOTIFY qualityChanged)
    Q_PROPERTY(QStringList notes READ getNote NOTIFY noteChanged)
    Q_PROPERTY(QStringList acodeces READ getAcodec NOTIFY acodecChanged)
    Q_PROPERTY(QStringList vcodeces READ getVcodec NOTIFY vcodecChanged)
    Q_PROPERTY(QList<double> filesizes READ getFilesize NOTIFY filesizeChanged)

public:
    explicit MediaFormat(QObject *parent = nullptr);

    QString getTitle() const;
    void setTitle(QString value);

    QString getThumbnail() const;
    void setThumbnail(QString value);

    QString getDuration() const;
    void setDuration(QString value);

    QString getUrl() const;
    void setUrl(QString value);

    QStringList getFormatId() const;
    void setFormatIdItem(QString value);

    QStringList getFormat() const;
    void setFormatItem(QString value);

    QStringList getExtension() const;
    void setExtensionItem(QString value);

    QStringList getResolution() const;
    void setResolutionItem(QString value);

    QStringList getQuality() const;
    void setQualityItem(QString value);

    QStringList getNote() const;
    void setNoteItem(QString value);

    QStringList getAcodec() const;
    void setAcodecItem(QString value);

    QStringList getVcodec() const;
    void setVcodecItem(QString value);

    QList<double> getFilesize() const;
    void setFilesizeItem(double value);

    void clearClutter();

signals:
    void titleChanged(const QString &value);
    void thumbnailChanged(const QString &value);
    void durationChanged(const QString &value);
    void urlChanged(const QString &value);
    void formatIdChanged(const QStringList &value);
    void formatChanged(const QStringList &value);
    void extensionChanged(const QStringList &value);
    void resolutionChanged(const QStringList &value);
    void qualityChanged(const QStringList &value);
    void noteChanged(const QStringList &value);
    void acodecChanged(const QStringList &value);
    void vcodecChanged(const QStringList &value);
    void filesizeChanged(const QList<double> &value);

private:
    QString m_title;
    QString m_thumbnail;
    QString m_duration;
    QString m_videoUrl;
    QStringList m_formatId;
    QStringList m_format;
    QStringList m_extension;
    QStringList m_resolution;
    QStringList m_quality;
    QStringList m_note;
    QStringList m_acodec;
    QStringList m_vcodec;
    QList<double> m_filesize;
};

#endif
