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

class MediaFormat : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString title READ getTitle NOTIFY titleChanged)
    Q_PROPERTY(QString thumbnail READ getThumbnail NOTIFY thumbnailChanged)
    Q_PROPERTY(QString duration READ getDuration NOTIFY durationChanged)
    Q_PROPERTY(QString videoUrl READ getUrl NOTIFY urlChanged)
    Q_PROPERTY(QStringList qualities READ getQualities NOTIFY qualitiesChanged)
    Q_PROPERTY(QList<int> filesizes READ getFilesizes NOTIFY filesizesChanged)

    Q_PROPERTY(QStringList vcodeces READ getVcodec NOTIFY vcodecChanged)
    Q_PROPERTY(QStringList notes READ getNotes NOTIFY notesChanged)
    Q_PROPERTY(QStringList resolutions READ getResolutions NOTIFY resolutionsChanged)
    Q_PROPERTY(QStringList videoExtensions READ getVideoExtensions NOTIFY videoExtensionsChanged)
    Q_PROPERTY(QStringList videoFormatIds READ getVideoFormatIds NOTIFY videoFormatIdsChanged)
    Q_PROPERTY(QStringList formats READ getFormats NOTIFY formatsChanged)

    Q_PROPERTY(QStringList acodeces READ getAcodec NOTIFY acodecChanged)
    Q_PROPERTY(QStringList audioExtensions READ getAudioExt NOTIFY audioExtChanged)
    Q_PROPERTY(QStringList audioFormatIds READ getAudioFormatIds NOTIFY audioFormatIdsChanged)
    Q_PROPERTY(QStringList audioBitrates READ getAudioBitrates NOTIFY audioBitratesChanged)
    Q_PROPERTY(QList<int> audioSizes READ getAudioSizes NOTIFY audioSizesChanged)

    Q_PROPERTY(QStringList languages READ getLanguages NOTIFY languagesChanged)
    Q_PROPERTY(QStringList languageIds READ getLanguageIds NOTIFY languagedsChanged)


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

    QList<int> getFilesizes() const;
    void setFilesizeItem(double value);

    QStringList getAudioExt() const;
    void setAudioExtItem(QString value);

    QStringList getAudioFormatIds() const;
    void setAudioFormatItem(QString value);

    QStringList getAudioBitrates() const;
    void setAudioBitrateItem(double value, QString lang = NULL);

    QStringList getLanguages() const;
    void setLanguageItem(QString value);

    QStringList getLanguageIds() const;
    void setLanguageIdItem(QString value);

    QList<int> getAudioSizes() const;
    void setAudioSizeItem(double value);

    void clearClutter();

signals:
    void titleChanged(QString value);
    void thumbnailChanged(QString value);
    void durationChanged(QString value);
    void urlChanged(QString value);
    void videoFormatIdsChanged();
    void formatsChanged();
    void videoExtensionsChanged();
    void resolutionsChanged();
    void qualitiesChanged();
    void notesChanged();
    void acodecChanged();
    void vcodecChanged();
    void filesizesChanged();
    void audioExtChanged();
    void audioFormatIdsChanged();
    void audioBitratesChanged();
    void languagesChanged();
    void languagedsChanged();
    void audioSizesChanged();

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
    QList<int> m_filesizes;
    QStringList m_audioExt;
    QStringList m_audioFormatIds;
    QStringList m_audioBitrates;
    QStringList m_languages;
    QStringList m_languageIds;
    QList<int> m_audioSizes;
};

#endif
