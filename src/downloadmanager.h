/**
 * @file downloadmanager.h
 * @brief Central controller for video download operations and metadata management
 * 
 * DownloadManager serves as the primary orchestrator for the RAVEN Downloader
 * application, coordinating between the UI (QML), YoutubeDL metadata fetcher,
 * and the download execution layer. It supports both embedded Python API mode
 * and legacy QProcess mode for maximum compatibility.
 * 
 * Key Responsibilities:
 * - Video URL validation and submission
 * - Metadata fetching via YoutubeDL integration
 * - Download execution with progress tracking
 * - History persistence (JSON-based)
 * - MediaFormat data model management
 * - Dual-mode operation (Python API / QProcess)
 * 
 * Operational Modes:
 * 1. Python API Mode (Primary):
 *    - Uses embedded Python with yt-dlp library
 *    - Better error handling and performance
 *    - Requires bundled Python runtime
 * 
 * 2. QProcess Mode (Fallback):
 *    - Executes yt-dlp_linux binary
 *    - Legacy compatibility mode
 *    - Activated when Python initialization fails
 * 
 * QML Integration:
 *   - Exposed via Q_PROPERTY for MediaFormat model
 *   - Provides Q_INVOKABLE slots for QML method calls
 *   - Emits signals for UI updates (progress, completion, errors)
 * 
 * Thread Safety:
 *   - NOT thread-safe. Must be used from Qt's main event loop thread.
 *   - All QProcess and signal operations require main thread.
 * 
 * @author Abdullah AL Shohag
 * @date 2022-2025
 * @copyright GNU General Public License v3.0 or later
 */

#ifndef DOWNLOADMANAGER_H
#define DOWNLOADMANAGER_H

#include <QObject>
#include <QJsonObject>
#include <QJsonDocument>
#include <QStandardPaths>
#include <youtubedl.h>
#include <QProcess>

#include "mediaformat.h"

class EmbeddedPython;

/**
 * @class DownloadManager
 * @brief Central controller for download workflow and metadata management
 * 
 * DownloadManager coordinates all aspects of video downloading:
 * - URL submission and validation (single videos and playlists)
 * - Metadata fetching through YoutubeDL
 * - Download execution with real-time progress reporting
 * - Download history persistence
 * - Error handling and user notifications
 * 
 * Usage Example:
 * @code
 * EmbeddedPython* python = new EmbeddedPython("/opt/app");
 * DownloadManager* dm = new DownloadManager(python);
 * 
 * // Connect signals
 * connect(dm, &DownloadManager::downloadProgress, [](QString progress, qint64 id) {
 *     qDebug() << "Download" << id << "progress:" << progress << "%";
 * });
 * 
 * // Submit URL
 * dm->actionSubmit("https://www.youtube.com/watch?v=VIDEO_ID", 0);
 * @endcode
 * 
 * @note Automatically selects Python API or QProcess mode based on initialization
 */
class DownloadManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MediaFormat *mediaFormats READ getMediaFormats NOTIFY mediaFormatsChanged);

public:
    /**
     * @brief Constructs DownloadManager with optional Python support
     * @param python Optional EmbeddedPython instance (nullptr for QProcess mode)
     * @param parent Parent QObject for Qt ownership hierarchy
     */
    explicit DownloadManager(EmbeddedPython* python = nullptr, QObject *parent = nullptr);
    
    /**
     * @brief Destructor - cleans up MediaFormat resources
     */
    ~DownloadManager();
    
    /**
     * @brief Gets the MediaFormat model instance
     * @return Pointer to MediaFormat containing current video metadata
     * @note Used by QML for property binding
     */
    MediaFormat *getMediaFormats();

public slots:
    /**
     * @brief Submits URL for metadata fetching
     * @param url YouTube video or playlist URL
     * @param index 0 for single video, non-zero for playlist
     * 
     * Initiates metadata fetching via YoutubeDL. Results are received
     * through checkJsonObject slot and stored in MediaFormat.
     * 
     * @note Emits finished signal when playlist processing completes
     */
    void actionSubmit(QString url, int index);
    
    /**
     * @brief Starts video download with specified options
     * @param url Video URL to download
     * @param data JSON object containing download options:
     *   - format: yt-dlp format string
     *   - subtitle: if present, download all subtitles
     *   - strConvert: if present, convert subs to SRT
     *   - embedded: if present, embed subtitles
     *   - caption: if present, download auto-generated captions
     *   - indexID: unique identifier for progress tracking
     * 
     * Uses Python API mode if available, otherwise QProcess fallback.
     * Emits downloadProgress and downloadFinished signals.
     */
    void actionDownload(QString url, QJsonObject data);
    
    /**
     * @brief Stops ongoing QProcess operation
     * @note Only affects QProcess mode operations
     */
    void stopProcess();
    
    /**
     * @brief Parses JSON object and updates MediaFormat model
     * @param jsonObject JSON object containing video metadata from yt-dlp
     * 
     * Extracts title, thumbnail, duration, formats, codecs, resolutions,
     * file sizes, and other metadata. Emits formatsUpdated when complete.
     */
    void setFormats(QJsonObject jsonObject);
    
    /**
     * @brief Validates URL format
     * @param url URL string to validate
     * @return true if URL matches YouTube domain patterns
     */
    bool isValidUrl(QString url);
    
    /**
     * @brief Checks if URL contains playlist parameter
     * @param url URL string to check
     * @return true if URL has "list" query parameter
     */
    bool isValidPlayListUrl(QString url);
    
    /**
     * @brief Processes incoming JSON string from YoutubeDL
     * @param value JSON string fragment or complete object
     * 
     * Accumulates JSON fragments until a complete object is received,
     * then calls setFormats() to update the model.
     * 
     * @note Connected to YoutubeDL::updateQString signal
     */
    void checkJsonObject(QString value);
    
    /**
     * @brief Handles metadata fetching completion
     * 
     * Emits finished signal with playlist title and entry count.
     * Resets internal state for next operation.
     * 
     * @note Connected to YoutubeDL::dataFetchFinished signal
     */
    void finishedFetching();

    /**
     * @brief Loads JSON document from file
     * @param fileName Absolute path to JSON file
     * @return QJsonDocument containing parsed data, or empty on failure
     */
    QJsonDocument loadJson(QString fileName);
    
    /**
     * @brief Saves JSON document to file
     * @param document JSON document to save
     * @param fileName Absolute path to destination file
     */
    void saveJson(QJsonDocument document, QString fileName);
    
    /**
     * @brief Saves current MediaFormat data to history file
     * @param value JSON string representation of download item
     * 
     * Appends to history.json in AppDataLocation.
     */
    void saveListModelData(QString value);
    
    /**
     * @brief Loads download history and populates MediaFormat
     * @return true if history loaded successfully, false if file not found
     * 
     * Reads history.json and emits formatsUpdated for each entry.
     * Emits listModelDataLoaded when complete.
     */
    bool loadListModelData();
    
    /**
     * @brief Handles download progress updates from QProcess
     * @param downloader QProcess instance performing the download
     * @param indexID Unique identifier for this download
     * 
     * Parses stdout for progress percentage and filename.
     * Emits downloadProgress signal with parsed data.
     * 
     * @note Only used in QProcess fallback mode
     */
    void downloadProgressSlot(QProcess *downloader, qint64 indexID);
    
    /**
     * @brief Handles QProcess download completion
     * @param exitCode Process exit code (0 for success)
     * @param exitStatus Normal or crash exit status
     * 
     * Emits downloadFinished signal with filename on success.
     */
    void downloadFinishedSlot(int exitCode, QProcess::ExitStatus exitStatus);

    /**
     * @brief Handles QProcess errors
     * @param errorMessage Process error type
     * 
     * Translates QProcess errors to user-friendly messages and
     * emits generalMessage signal.
     */
    void errorMessage(QProcess::ProcessError errorMessage);

signals:
    /**
     * @brief Emitted when MediaFormat model changes
     */
    void mediaFormatsChanged();
    
    /**
     * @brief Emitted when video formats are updated
     * @param hasIndex true if this is a history entry with saved indices
     * @param videoIndex Previously selected video format index
     * @param audioIndex Previously selected audio format index
     * @param videoProgress Previous download progress percentage
     */
    void formatsUpdated(bool hasIndex, qint64 videoIndex = 0, qint64 audioIndex = 0, qint64 videoProgress = 0);
    
    /**
     * @brief Emitted when submitted URL is not a valid playlist
     */
    void invalidPlaylistUrl();
    
    /**
     * @brief Emitted when playlist fetching completes
     * @param playlistTitle Title of the playlist
     * @param entries Number of videos in the playlist
     */
    void finished(QString playlistTitle, qint64 entries);
    
    /**
     * @brief Emitted during download progress
     * @param value Progress percentage as string
     * @param indexID Unique identifier for the download
     */
    void downloadProgress(QString value, qint64 indexID);
    
    /**
     * @brief Emitted when download completes successfully
     * @param fileName Full path to downloaded file
     */
    void downloadFinished(QString fileName);
    
    /**
     * @brief Emitted when download history is loaded
     */
    void listModelDataLoaded();
    
    /**
     * @brief Emitted for general user messages (errors, warnings)
     * @param message Human-readable message string
     */
    void generalMessage(QString message);

private:
    /**
     * @brief Downloads video using embedded Python API
     * @param url Video URL
     * @param format yt-dlp format string
     * @param outputPath Output path template (e.g., "/path/%(title)s")
     * @param indexID Unique identifier for progress tracking
     * 
     * Calls EmbeddedPython::runYtDlpDownload() with progress callback.
     * Emits downloadProgress and downloadFinished signals.
     */
    void downloadWithPython(const QString& url, const QString& format, const QString& outputPath, qint64 indexID);
    
    /**
     * @brief Downloads video using QProcess subprocess
     * @param url Video URL
     * @param format yt-dlp format string
     * @param outputPath Output path template
     * @param indexID Unique identifier for progress tracking
     * 
     * Executes yt-dlp_linux binary and monitors stdout for progress.
     */
    void downloadWithQProcess(const QString& url, const QString& format, const QString& outputPath, qint64 indexID);
    
    EmbeddedPython* m_python = nullptr;  ///< Python instance (not owned)
    bool m_usePythonMode = false;        ///< true for Python API, false for QProcess
    YoutubeDL *ytdl = nullptr;           ///< YoutubeDL instance for metadata fetching
    MediaFormat *m_mediaFormats = new MediaFormat();  ///< Model for QML binding
    QString configPath = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);  ///< App config directory
    QString cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);  ///< App cache directory
    QString appDataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);  ///< App data directory
    QString tempJSONDataHolder;  ///< Buffer for accumulating JSON fragments
    QString playlistTitle;       ///< Title of currently processing playlist
    qint64 entries = 0;          ///< Number of entries in current playlist
    QString downloadPath = this->appDataPath;  ///< Download destination directory
    QString filename;            ///< Most recently downloaded filename

};

#endif
