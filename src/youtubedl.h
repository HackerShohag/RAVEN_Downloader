/**
 * @file youtubedl.h
 * @brief YouTube video metadata fetcher with dual-mode operation (Python API / QProcess)
 * 
 * This class handles fetching video metadata from YouTube and other supported sites
 * using yt-dlp. It supports two operational modes:
 * 
 * 1. Python API Mode (Primary):
 *    - Uses embedded Python interpreter with yt-dlp as a library
 *    - Direct function calls via EmbeddedPython wrapper
 *    - Better performance and error handling
 *    - Requires bundled Python runtime
 * 
 * 2. QProcess Mode (Fallback):
 *    - Executes yt-dlp_linux binary as subprocess
 *    - Compatible with legacy deployments
 *    - Activated when Python initialization fails
 * 
 * Key Features:
 * - Automatic mode selection based on Python availability
 * - Single video and playlist support
 * - JSON metadata parsing and emission
 * - URL validation and extraction
 * - Graceful fallback handling
 * 
 * Thread Safety:
 *   - NOT thread-safe. QProcess and signals require main Qt thread.
 *   - All methods must be called from the Qt event loop thread.
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

#ifndef YOUTUBEDL_H
#define YOUTUBEDL_H

#include <QProcess>

// Forward declaration
class EmbeddedPython;

/**
 * @class YoutubeDL
 * @brief Manages yt-dlp operations for fetching video metadata
 * 
 * YoutubeDL abstracts the complexity of invoking yt-dlp, supporting both
 * embedded Python API calls and legacy subprocess execution. The class
 * automatically selects the appropriate mode during construction.
 * 
 * Usage Example:
 * @code
 * EmbeddedPython* python = new EmbeddedPython("/path/to/app");
 * YoutubeDL* ytdl = new YoutubeDL(python);
 * 
 * connect(ytdl, &YoutubeDL::updateQString, [](QString json) {
 *     qDebug() << "Received metadata:" << json;
 * });
 * 
 * ytdl->fetchSingleFormats("https://www.youtube.com/watch?v=dQw4w9WgXcQ");
 * @endcode
 * 
 * @note Emits updateQString signal for each video's JSON metadata
 * @note Emits dataFetchFinished when all data has been processed
 */
class YoutubeDL : public QObject
{
    Q_OBJECT
public:
    /**
     * @brief Constructs YoutubeDL with optional Python support
     * @param python Optional EmbeddedPython instance for API mode (nullptr for QProcess mode)
     * @param parent Parent QObject for Qt ownership hierarchy
     */
    explicit YoutubeDL(EmbeddedPython* python = nullptr, QObject* parent = nullptr);
    
    /**
     * @brief Destructor - cleans up QProcess resources
     */
    ~YoutubeDL();
    
    /**
     * @brief Fetches metadata for a single video (not a playlist)
     * @param url YouTube video URL
     * 
     * Uses Python API mode if available, otherwise falls back to QProcess.
     * Emits updateQString signal with JSON metadata when complete.
     * 
     * @note Automatically extracts video ID from URL
     * @note Emits dataFetchFinished when operation completes
     */
    void fetchSingleFormats(QString url);
    
    /**
     * @brief Extracts clean playlist URL from various YouTube URL formats
     * @param url YouTube URL (may include video and playlist parameters)
     * @return Clean playlist URL with only list parameter
     * 
     * Handles URLs like:
     * - https://www.youtube.com/watch?v=VIDEO&list=PLAYLIST
     * - https://www.youtube.com/playlist?list=PLAYLIST
     */
    static QString extractPlaylistUrl(QString url);
    
    /**
     * @brief Extracts single video URL from various YouTube URL formats
     * @param url YouTube URL (short or full format)
     * @return Standard YouTube watch URL
     * 
     * Handles URLs like:
     * - https://youtu.be/VIDEO_ID
     * - https://www.youtube.com/watch?v=VIDEO_ID&other=params
     */
    static QString extractSingleVideoUrl(QString url);
    
    /**
     * @brief Gets the internal QProcess instance
     * @return Pointer to QProcess (for legacy/fallback mode)
     * @warning Only valid when not using Python API mode
     */
    QProcess *getYtdl();
    
    /**
     * @brief Clears the command-line arguments list
     * @note Used internally for QProcess mode
     */
    void resetArguments();
    
    /**
     * @brief Validates URL format using regex
     * @param url URL string to validate
     * @return true if URL has valid HTTP/HTTPS format, false otherwise
     */
    static bool isValidUrl(QString url);
    
    /**
     * @brief Sets video format for download
     * @param format yt-dlp format string (e.g., "bestvideo+bestaudio", "137+140")
     * @note Adds "-f" argument for QProcess mode
     */
    void setFormat(QString format);
    
    /**
     * @brief Starts video download process
     * @param url Video URL to download
     * @param workingDirectory Directory where files will be saved
     * @note Legacy method - primarily for QProcess mode
     */
    void startDownload(QString url, QString workingDirectory);
    
    /**
     * @brief Adds custom command-line argument
     * @param arg Argument to add (e.g., "--embed-subs")
     * @note Used in QProcess mode only
     */
    void addArguments(QString arg);

    /**
     * @brief Fetches metadata for all videos in a playlist
     * @param url YouTube playlist URL
     * 
     * Uses Python API mode if available, otherwise falls back to QProcess.
     * Emits updateQString signal for each video in the playlist.
     * 
     * @note Automatically handles playlist URL extraction
     * @note Emits dataFetchFinished after all videos are processed
     */
    void startForPlayList(QString url);

    /**
     * @brief Stops ongoing QProcess operation
     * @note Only applicable in QProcess mode
     * @warning Does not affect Python API operations
     */
    void stopConnection();

public slots:
    /**
     * @brief Handles QProcess stdout data ready signal
     * @note Internal slot - connected to QProcess::readyReadStandardOutput
     * @note Only used in QProcess fallback mode
     */
    void readyReadStandardOutput();
    
    /**
     * @brief Handles QProcess completion
     * @param exitCode Process exit code (0 for success)
     * @param exitStatus Normal or crash exit status
     * @note Emits dataFetchFinished signal
     */
    void finishedSlot(int exitCode, QProcess::ExitStatus exitStatus);
    
    /**
     * @brief Handles QProcess errors and forwards to signal
     * @param error Process error type
     */
    void emitErrorMessage(QProcess::ProcessError error);

signals:
    /**
     * @brief Emitted when video metadata JSON is available
     * @param value JSON string containing video metadata
     * @note Emitted once per video (multiple times for playlists)
     */
    void updateQString(QString value);
    
    /**
     * @brief Emitted when all metadata fetching is complete
     * @note Signals that no more updateQString emissions will occur
     */
    void dataFetchFinished();
    
    /**
     * @brief Emitted when QProcess encounters an error
     * @param error Process error type (FailedToStart, Crashed, etc.)
     */
    void qProcessError(QProcess::ProcessError error);

private:
    EmbeddedPython* m_python;  ///< Python instance (not owned)
    bool m_usePythonMode;      ///< true if using Python API, false for QProcess fallback
    
    // Legacy QProcess members (fallback mode)
    QStringList arguments;     ///< Command-line arguments for yt-dlp_linux
    QString program;           ///< Program name ("yt-dlp_linux")
    QProcess *ytdl;            ///< QProcess instance for subprocess execution
    
    /**
     * @brief Fetches metadata using embedded Python API
     * @param url Video or playlist URL
     * @param isPlaylist true for playlist, false for single video
     * 
     * Calls EmbeddedPython::runYtDlpExtract(), parses JSON, and emits signals.
     * For playlists, splits JSON array and emits each entry separately.
     */
    void fetchWithPython(const QString& url, bool isPlaylist);
    
    /**
     * @brief Fetches metadata using QProcess subprocess
     * @param url Video or playlist URL
     * @param isPlaylist true for playlist, false for single video
     * 
     * Executes yt-dlp_linux binary with appropriate arguments.
     * Output is received via readyReadStandardOutput slot.
     */
    void fetchWithQProcess(const QString& url, bool isPlaylist);
};

#endif // YOUTUBEDL_H
