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
    Q_PROPERTY(QStringList qualities READ getQualities NOTIFY qualitiesChanged)
    Q_PROPERTY(QList<double> filesizes READ getFilesizes NOTIFY filesizesChanged)

    Q_PROPERTY(QStringList vcodeces READ getVcodec NOTIFY vcodecChanged)
    Q_PROPERTY(QStringList notes READ getNotes NOTIFY notesChanged)
    Q_PROPERTY(QStringList resolutions READ getResolutions NOTIFY resolutionsChanged)
    Q_PROPERTY(QStringList videoExtensions READ getVideoExtensions NOTIFY videoExtensionsChanged)
    Q_PROPERTY(QStringList videoFormatIds READ getVideoFormatIds NOTIFY videoFormatIdsChanged)
    Q_PROPERTY(QStringList formats READ getFormats NOTIFY formatsChanged)

    Q_PROPERTY(QStringList acodeces READ getAcodec NOTIFY acodecChanged)
    Q_PROPERTY(QStringList audioExtensions READ getAudioExt NOTIFY audioExtChanged)
    Q_PROPERTY(QStringList audioFormatIds READ getAudioFormatIds NOTIFY audioFormatIdsChanged)

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

    QStringList getVideoFormatIds() const;
    void setVideoFormatItem(QString value);

    QStringList getFormats() const;
    void setFormatItem(QString value);

    QStringList getVideoExtensions() const;
    void setVideoExtensionItem(QString value);

    QStringList getResolutions() const;
    void setResolutionItem(QString value);

    QStringList getQualities() const;
    void setQualityItem(QString value);

    QStringList getNotes() const;
    void setNoteItem(QString value);

    QStringList getAcodec() const;
    void setAcodecItem(QString value);

    QStringList getVcodec() const;
    void setVcodecItem(QString value);

    QList<double> getFilesizes() const;
    void setFilesizeItem(double value);

    QStringList getAudioExt() const;
    void setAudioExtItem(QString value);

    QStringList getAudioFormatIds() const;
    void setAudioFormatItem(QString value);

    void clearClutter();

signals:
    void titleChanged(const QString &value);
    void thumbnailChanged(const QString &value);
    void durationChanged(const QString &value);
    void urlChanged(const QString &value);
    void videoFormatIdsChanged(const QStringList &value);
    void formatsChanged(const QStringList &value);
    void videoExtensionsChanged(const QStringList &value);
    void resolutionsChanged(const QStringList &value);
    void qualitiesChanged(const QStringList &value);
    void notesChanged(const QStringList &value);
    void acodecChanged(const QStringList &value);
    void vcodecChanged(const QStringList &value);
    void filesizesChanged(const QList<double> &value);
    void audioExtChanged();
    void audioFormatIdsChanged();

private:
    QString m_title;
    QString m_thumbnail;
    QString m_duration;
    QString m_videoUrl;
    QStringList m_formatIds;
    QStringList m_formats;
    QStringList m_extensions;
    QStringList m_resolutions;
    QStringList m_qualities;
    QStringList m_notes;
    QStringList m_acodec;
    QStringList m_vcodec;
    QList<double> m_filesizes;
    QStringList m_audioExt;
    QStringList m_audioFormatIds;
};

#endif
