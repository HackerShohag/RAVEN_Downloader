/*
 * Copyright (C) 2025  Abdullah AL Shohag
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * Embedded Python wrapper for yt-dlp integration
 * Provides safe C++ interface to embedded Python interpreter with bundled yt-dlp
 */

#ifndef EMBEDDED_PYTHON_H
#define EMBEDDED_PYTHON_H

#include <string>
#include <utility>
#include <functional>

/**
 * @brief EmbeddedPython - Manages embedded Python interpreter for yt-dlp integration
 * 
 * This class provides a self-contained Python 3 interpreter embedded in the app,
 * with bundled yt-dlp module for video metadata extraction and downloading.
 * 
 * Features:
 * - Automatic PYTHONHOME and PYTHONPATH configuration for bundled Python
 * - Safe reference counting and exception handling
 * - Direct yt-dlp Python API calls (no subprocess overhead)
 * - Progress callback support for downloads
 * - Thread-safe operations with GIL management
 * 
 * Architecture support: ARM64, ARMv7, x86_64 Ubuntu Touch devices
 */
class EmbeddedPython {
public:
    /**
     * @brief Construct and initialize the embedded Python interpreter
     * @param appPath Absolute path to the application root (e.g., /opt/click.ubuntu.com/...)
     * 
     * Automatically configures:
     * - PYTHONHOME to appPath/vendor/python
     * - PYTHONPATH to include site-packages with yt-dlp
     * - Initializes Python interpreter
     * - Imports yt-dlp module
     */
    explicit EmbeddedPython(const std::string& appPath);
    
    /**
     * @brief Destructor - safely finalizes Python interpreter
     */
    ~EmbeddedPython();

    // Prevent copying to avoid double-finalization
    EmbeddedPython(const EmbeddedPython&) = delete;
    EmbeddedPython& operator=(const EmbeddedPython&) = delete;

    /**
     * @brief Check if Python interpreter initialized successfully
     * @return true if ready to use, false otherwise
     */
    bool isInitialized() const;

    /**
     * @brief Get last error message from Python or initialization
     * @return Error message string (empty if no error)
     */
    std::string getLastError() const;

    /**
     * @brief Extract video/playlist metadata using yt-dlp
     * @param url YouTube video or playlist URL
     * @param isPlaylist true to extract playlist, false for single video
     * @return pair<success, json_string> - success flag and JSON metadata or error message
     * 
     * JSON format matches yt-dlp output structure:
     * Single video: {"title": "...", "thumbnail": "...", "formats": [...], ...}
     * Playlist: {"entries": [{...}, {...}], "title": "...", ...}
     * 
     * Error format: {"error": "error message"}
     */
    std::pair<bool, std::string> runYtDlpExtract(const std::string& url, bool isPlaylist = false);

    /**
     * @brief Download video using yt-dlp with format selection
     * @param url YouTube video URL
     * @param format Format selector (e.g., "bestvideo+bestaudio", "137+140")
     * @param outputPath Output file path template (e.g., "/path/to/%(title)s.%(ext)s")
     * @param progressCallback Optional callback for download progress (0.0 to 1.0)
     * @return pair<success, message> - success flag and completion/error message
     * 
     * Progress callback signature: void(double progress, const std::string& status)
     * - progress: 0.0 to 1.0 indicating completion percentage
     * - status: Current status string from yt-dlp
     */
    std::pair<bool, std::string> runYtDlpDownload(
        const std::string& url,
        const std::string& format,
        const std::string& outputPath,
        std::function<void(double, const std::string&)> progressCallback = nullptr
    );

    /**
     * @brief Execute arbitrary Python code snippet (advanced use)
     * @param pythonCode Python code string to execute
     * @return pair<success, result> - success flag and result/error string
     * 
     * WARNING: Use with caution. Intended for debugging and utility functions.
     * Properly escapes and sanitizes within Python context.
     */
    std::pair<bool, std::string> executePythonCode(const std::string& pythonCode);

    /**
     * @brief Get yt-dlp version information
     * @return yt-dlp version string (e.g., "2024.11.18") or error message
     */
    std::string getYtDlpVersion();

private:
    struct PythonState;
    PythonState* m_state; // Opaque pointer to hide Python.h from header

    std::string m_appPath;
    bool m_initialized;
    std::string m_lastError;

    /**
     * @brief Initialize Python interpreter with custom paths
     * @return true on success, false on failure (sets m_lastError)
     */
    bool initializePython();

    /**
     * @brief Import yt-dlp module and verify availability
     * @return true on success, false on failure (sets m_lastError)
     */
    bool importYtDlp();

    /**
     * @brief Safely finalize Python interpreter
     */
    void finalizePython();

    /**
     * @brief Handle Python exception and convert to C++ error string
     * @return Error message from Python exception
     */
    std::string handlePythonException();

    /**
     * @brief Convert Python dictionary to JSON string
     * @param pyDict Python dict object (borrowed reference)
     * @return JSON string representation
     */
    std::string pythonDictToJson(void* pyDict);

    /**
     * @brief RAII wrapper for Python GIL acquisition
     */
    class GILGuard {
    public:
        GILGuard();
        ~GILGuard();
        GILGuard(const GILGuard&) = delete;
        GILGuard& operator=(const GILGuard&) = delete;
    private:
        int m_gilState;  // Store as int to avoid including Python.h
    };
};

#endif // EMBEDDED_PYTHON_H
