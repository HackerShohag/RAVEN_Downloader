/**
 * @file mediaformat.h
 * @brief Media format data model for video/audio metadata and format information
 * 
 * This class serves as a Qt-based data model that stores and manages metadata
 * for downloaded media content. It provides properties for video information
 * (title, thumbnail, duration, quality, codecs) and audio information (formats,
 * bitrates, languages). The class integrates with Qt's property system for
 * seamless QML binding.
 * 
 * Key Features:
 * - Complete video metadata storage (title, thumbnail, duration, URL)
 * - Multiple video format support (resolutions, codecs, extensions, file sizes)
 * - Audio format management (codecs, bitrates, languages, sizes)
 * - Qt property system integration for QML binding
 * - Signal emission for reactive UI updates
 * - Efficient data clearing and reuse
 * 
 * Thread Safety:
 *   - NOT thread-safe. Must be accessed from Qt's main thread only.
 *   - Designed for use in single-threaded Qt/QML applications.
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

#ifndef MEDIAFORMAT_H
#define MEDIAFORMAT_H

#include <QObject>

/**
 * @class MediaFormat
 * @brief Qt model class for managing video and audio format metadata
 * 
 * MediaFormat encapsulates all metadata related to downloadable media content,
 * including video properties (resolution, codec, file size) and audio properties
 * (bitrate, language, codec). It exposes this data through Qt properties for
 * easy integration with QML user interfaces.
 * 
 * Usage Example:
 * @code
 * MediaFormat* format = new MediaFormat();
 * format->setTitle("Sample Video");
 * format->setVideoFormatItem("137");
 * format->setResolutionItem("1920x1080");
 * format->setFilesizeItem(52.3); // MB
 * 
 * QString title = format->getTitle();
 * QStringList resolutions = format->getResolutions();
 * @endcode
 * 
 * @note All string lists are synchronized - index N in one list corresponds
 *       to index N in related lists (e.g., videoFormatIds[0] matches resolutions[0])
 */
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
    /**
     * @brief Constructs a MediaFormat object
     * @param parent Parent QObject for Qt ownership hierarchy
     */
    explicit MediaFormat(QObject *parent = nullptr);

    /**
     * @brief Gets video title
     * @return Title string
     */
    QString getTitle() const;
    
    /**
     * @brief Sets video title and emits titleChanged signal
     * @param value Title string
     */
    void setTitle(QString value);

    /**
     * @brief Gets video thumbnail URL
     * @return Thumbnail URL string
     */
    QString getThumbnail() const;
    
    /**
     * @brief Sets video thumbnail URL and emits thumbnailChanged signal
     * @param value Thumbnail URL
     */
    void setThumbnail(QString value);

    /**
     * @brief Gets video duration string
     * @return Duration in human-readable format (e.g., "5:32")
     */
    QString getDuration() const;
    
    /**
     * @brief Sets video duration and emits durationChanged signal
     * @param value Duration string
     */
    void setDuration(QString value);

    /**
     * @brief Gets video URL or ID
     * @return Video URL or YouTube video ID
     */
    QString getUrl() const;
    
    /**
     * @brief Sets video URL/ID
     * @param value Video URL or ID
     */
    void setUrl(QString value);

    /**
     * @brief Gets list of video format IDs
     * @return List of yt-dlp format IDs (e.g., ["137", "136", "135"])
     */
    QStringList getVideoFormatIds() const;
    
    /**
     * @brief Appends video format ID to the list
     * @param value Format ID to add
     */
    void setVideoFormatItem(QString value);

    /**
     * @brief Gets list of format descriptions
     * @return List of full format strings from yt-dlp
     */
    QStringList getFormats() const;
    
    /**
     * @brief Appends format description to the list
     * @param value Format description
     */
    void setFormatItem(QString value);

    /**
     * @brief Gets list of video file extensions
     * @return List of extensions (e.g., ["mp4", "webm"])
     */
    QStringList getVideoExtensions() const;
    
    /**
     * @brief Appends video extension to the list
     * @param value File extension
     */
    void setVideoExtensionItem(QString value);

    /**
     * @brief Gets list of video resolutions
     * @return List of resolutions (e.g., ["1920x1080", "1280x720"])
     */
    QStringList getResolutions() const;
    
    /**
     * @brief Appends resolution to the list
     * @param value Resolution string
     */
    void setResolutionItem(QString value);

    /**
     * @brief Gets list of quality labels
     * @return List of quality strings
     */
    QStringList getQualities() const;
    
    /**
     * @brief Appends quality label to the list
     * @param value Quality string
     */
    void setQualityItem(QString value);

    /**
     * @brief Gets list of format notes/quality indicators
     * @return List of notes (e.g., ["1080p", "720p", "480p"])
     */
    QStringList getNotes() const;
    
    /**
     * @brief Appends format note to the list
     * @param value Note/quality indicator
     */
    void setNoteItem(QString value);

    /**
     * @brief Gets list of audio codecs
     * @return List of audio codec names (e.g., ["opus", "aac"])
     */
    QStringList getAcodec() const;
    
    /**
     * @brief Appends audio codec to the list
     * @param value Codec name
     */
    void setAcodecItem(QString value);

    /**
     * @brief Gets list of video codecs
     * @return List of video codec names (e.g., ["vp9", "avc1"])
     */
    QStringList getVcodec() const;
    
    /**
     * @brief Appends video codec to the list
     * @param value Codec name
     */
    void setVcodecItem(QString value);

    /**
     * @brief Gets list of video file sizes
     * @return List of file sizes in megabytes (rounded to int)
     */
    QList<int> getFilesizes() const;
    
    /**
     * @brief Appends file size to the list
     * @param value File size in megabytes (will be rounded)
     */
    void setFilesizeItem(double value);

    /**
     * @brief Gets list of audio file extensions
     * @return List of audio extensions (e.g., ["m4a", "webm"])
     */
    QStringList getAudioExt() const;
    
    /**
     * @brief Appends audio extension to the list
     * @param value Audio file extension
     */
    void setAudioExtItem(QString value);

    /**
     * @brief Gets list of audio format IDs
     * @return List of yt-dlp audio format IDs
     */
    QStringList getAudioFormatIds() const;
    
    /**
     * @brief Appends audio format ID to the list
     * @param value Audio format ID
     */
    void setAudioFormatItem(QString value);

    /**
     * @brief Gets list of audio bitrates with optional language tags
     * @return List of bitrate strings (e.g., ["128Kbps", "96Kbps, en"])
     */
    QStringList getAudioBitrates() const;
    
    /**
     * @brief Appends audio bitrate to the list
     * @param value Bitrate in Kbps (will be rounded)
     * @param lang Optional language code (appended if not empty)
     */
    void setAudioBitrateItem(double value, QString lang = NULL);

    /**
     * @brief Gets list of available languages
     * @return List of language names
     */
    QStringList getLanguages() const;
    
    /**
     * @brief Appends language name to the list
     * @param value Language name
     */
    void setLanguageItem(QString value);

    /**
     * @brief Gets list of language codes
     * @return List of language codes (e.g., ["en", "es", "fr"])
     */
    QStringList getLanguageIds() const;
    
    /**
     * @brief Appends language code to the list
     * @param value Language code
     */
    void setLanguageIdItem(QString value);

    /**
     * @brief Gets list of audio file sizes
     * @return List of audio file sizes in megabytes (rounded to int)
     */
    QList<int> getAudioSizes() const;
    
    /**
     * @brief Appends audio file size to the list
     * @param value File size in megabytes (will be rounded)
     */
    void setAudioSizeItem(double value);

    /**
     * @brief Clears all stored metadata for object reuse
     * 
     * Resets all member variables (title, formats, codecs, etc.)
     * to empty state. Does not emit signals.
     */
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
