/*
 * Copyright (C) 2025  Abdullah AL Shohag
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * Embedded Python implementation for yt-dlp integration
 */

#include "embedded_python.h"

#include <Python.h>
#include <sstream>
#include <iostream>
#include <cstdlib>

// Internal state structure (hides Python.h types from header)
struct EmbeddedPython::PythonState {
    PyObject* ytdlpModule;          // yt-dlp module reference
    PyObject* jsonModule;           // json module for serialization
    PyObject* sysModule;            // sys module for path manipulation
    
    PythonState() 
        : ytdlpModule(nullptr)
        , jsonModule(nullptr)
        , sysModule(nullptr)
    {}
};

EmbeddedPython::EmbeddedPython(const std::string& appPath)
    : m_state(new PythonState())
    , m_appPath(appPath)
    , m_initialized(false)
    , m_lastError("")
{
    m_initialized = initializePython();
}

EmbeddedPython::~EmbeddedPython() {
    finalizePython();
    delete m_state;
}

bool EmbeddedPython::isInitialized() const {
    return m_initialized;
}

std::string EmbeddedPython::getLastError() const {
    return m_lastError;
}

bool EmbeddedPython::initializePython() {
    // Set PYTHONHOME to bundled Python location
    std::string pythonHome = m_appPath + "/vendor/python";
    std::wstring pythonHomeWide(pythonHome.begin(), pythonHome.end());
    Py_SetPythonHome(pythonHomeWide.c_str());

    // Set program name (helps with some Python initialization)
    std::wstring progName(m_appPath.begin(), m_appPath.end());
    Py_SetProgramName(progName.c_str());

    // Initialize Python interpreter
    Py_Initialize();
    
    if (!Py_IsInitialized()) {
        m_lastError = "Failed to initialize Python interpreter";
        return false;
    }

    // Configure PYTHONPATH to include bundled modules
    std::string pythonLibPath = pythonHome + "/lib/python3.8";
    std::string pythonSitePackages = pythonHome + "/lib/python3.8/site-packages";
    
    PyObject* sysPath = PySys_GetObject("path"); // Borrowed reference
    if (!sysPath) {
        m_lastError = "Failed to get sys.path";
        return false;
    }

    // Add bundled paths to sys.path (insert at beginning for priority)
    PyObject* pyLibPath = PyUnicode_FromString(pythonLibPath.c_str());
    PyList_Insert(sysPath, 0, pyLibPath);
    Py_DECREF(pyLibPath);
    
    PyObject* pySitePackages = PyUnicode_FromString(pythonSitePackages.c_str());
    PyList_Insert(sysPath, 0, pySitePackages);
    Py_DECREF(pySitePackages);

    // Import essential modules
    m_state->sysModule = PyImport_ImportModule("sys");
    if (!m_state->sysModule) {
        m_lastError = "Failed to import sys module: " + handlePythonException();
        return false;
    }

    m_state->jsonModule = PyImport_ImportModule("json");
    if (!m_state->jsonModule) {
        m_lastError = "Failed to import json module: " + handlePythonException();
        return false;
    }

    // Import yt-dlp
    if (!importYtDlp()) {
        return false;
    }

    return true;
}

bool EmbeddedPython::importYtDlp() {
    // Try importing yt-dlp module
    m_state->ytdlpModule = PyImport_ImportModule("yt_dlp");
    
    if (!m_state->ytdlpModule) {
        m_lastError = "Failed to import yt_dlp module. Ensure yt-dlp is installed in vendor/python/lib/python3.8/site-packages/. Error: " + handlePythonException();
        return false;
    }

    std::cout << "yt-dlp module imported successfully" << std::endl;
    return true;
}

void EmbeddedPython::finalizePython() {
    if (m_initialized) {
        // Clean up Python objects
        Py_XDECREF(m_state->ytdlpModule);
        Py_XDECREF(m_state->jsonModule);
        Py_XDECREF(m_state->sysModule);
        
        // Finalize interpreter
        if (Py_IsInitialized()) {
            Py_Finalize();
        }
        
        m_initialized = false;
    }
}

std::string EmbeddedPython::handlePythonException() {
    if (!PyErr_Occurred()) {
        return "Unknown Python error (no exception set)";
    }

    PyObject *type, *value, *traceback;
    PyErr_Fetch(&type, &value, &traceback);
    PyErr_NormalizeException(&type, &value, &traceback);

    std::string errorMsg = "Python exception: ";
    
    if (value) {
        PyObject* strValue = PyObject_Str(value);
        if (strValue) {
            const char* utf8 = PyUnicode_AsUTF8(strValue);
            if (utf8) {
                errorMsg += utf8;
            }
            Py_DECREF(strValue);
        }
    }

    // Clean up exception objects
    Py_XDECREF(type);
    Py_XDECREF(value);
    Py_XDECREF(traceback);

    return errorMsg;
}

std::string EmbeddedPython::pythonDictToJson(void* pyDict) {
    if (!pyDict) {
        return "{\"error\": \"null Python object\"}";
    }

    PyObject* dict = static_cast<PyObject*>(pyDict);
    
    // Use json.dumps() to serialize
    PyObject* dumpsFunc = PyObject_GetAttrString(m_state->jsonModule, "dumps");
    if (!dumpsFunc) {
        return "{\"error\": \"Failed to get json.dumps\"}";
    }

    PyObject* args = PyTuple_Pack(1, dict);
    PyObject* jsonStr = PyObject_CallObject(dumpsFunc, args);
    
    Py_DECREF(args);
    Py_DECREF(dumpsFunc);

    if (!jsonStr) {
        std::string error = handlePythonException();
        return "{\"error\": \"JSON serialization failed: " + error + "\"}";
    }

    const char* utf8 = PyUnicode_AsUTF8(jsonStr);
    std::string result = utf8 ? utf8 : "{\"error\": \"UTF-8 conversion failed\"}";
    
    Py_DECREF(jsonStr);
    return result;
}

std::pair<bool, std::string> EmbeddedPython::runYtDlpExtract(const std::string& url, bool isPlaylist) {
    if (!m_initialized) {
        return {false, "{\"error\": \"Python not initialized: " + m_lastError + "\"}"};
    }

    GILGuard gil; // Acquire GIL for thread safety

    // Create YoutubeDL instance with options
    PyObject* ytdlClass = PyObject_GetAttrString(m_state->ytdlpModule, "YoutubeDL");
    if (!ytdlClass) {
        std::string error = handlePythonException();
        return {false, "{\"error\": \"Failed to get YoutubeDL class: " + error + "\"}"};
    }

    // Configure options dictionary
    PyObject* options = PyDict_New();
    PyDict_SetItemString(options, "quiet", Py_True);
    PyDict_SetItemString(options, "no_warnings", Py_True);
    PyDict_SetItemString(options, "extract_flat", isPlaylist ? Py_True : Py_False);
    
    // For single video, don't extract playlist
    if (!isPlaylist) {
        PyDict_SetItemString(options, "noplaylist", Py_True);
    }

    // Create YoutubeDL instance
    PyObject* args = PyTuple_Pack(1, options);
    PyObject* ytdl = PyObject_CallObject(ytdlClass, args);
    
    Py_DECREF(args);
    Py_DECREF(options);
    Py_DECREF(ytdlClass);

    if (!ytdl) {
        std::string error = handlePythonException();
        return {false, "{\"error\": \"Failed to create YoutubeDL instance: " + error + "\"}"};
    }

    // Call extract_info(url)
    PyObject* extractMethod = PyObject_GetAttrString(ytdl, "extract_info");
    if (!extractMethod) {
        Py_DECREF(ytdl);
        std::string error = handlePythonException();
        return {false, "{\"error\": \"Failed to get extract_info method: " + error + "\"}"};
    }

    PyObject* urlObj = PyUnicode_FromString(url.c_str());
    PyObject* downloadArg = Py_False; // Don't download, just extract info
    
    PyObject* extractArgs = PyTuple_Pack(2, urlObj, downloadArg);
    PyObject* result = PyObject_CallObject(extractMethod, extractArgs);
    
    Py_DECREF(extractArgs);
    Py_DECREF(urlObj);
    Py_DECREF(extractMethod);
    Py_DECREF(ytdl);

    if (!result) {
        std::string error = handlePythonException();
        return {false, "{\"error\": \"yt-dlp extraction failed: " + error + "\"}"};
    }

    // Convert result dictionary to JSON string
    std::string jsonResult = pythonDictToJson(result);
    Py_DECREF(result);

    return {true, jsonResult};
}

std::pair<bool, std::string> EmbeddedPython::runYtDlpDownload(
    const std::string& url,
    const std::string& format,
    const std::string& outputPath,
    std::function<void(double, const std::string&)> progressCallback)
{
    if (!m_initialized) {
        return {false, "Python not initialized: " + m_lastError};
    }

    GILGuard gil;

    // Create options dictionary
    PyObject* options = PyDict_New();
    
    // Set format
    PyObject* formatObj = PyUnicode_FromString(format.c_str());
    PyDict_SetItemString(options, "format", formatObj);
    Py_DECREF(formatObj);
    
    // Set output template
    PyObject* outputObj = PyUnicode_FromString(outputPath.c_str());
    PyDict_SetItemString(options, "outtmpl", outputObj);
    Py_DECREF(outputObj);

    PyDict_SetItemString(options, "quiet", Py_False);

    // TODO: Add progress_hooks callback wrapper for progressCallback
    // This requires wrapping C++ function as Python callable
    // For now, downloads proceed without progress updates

    // Create YoutubeDL instance
    PyObject* ytdlClass = PyObject_GetAttrString(m_state->ytdlpModule, "YoutubeDL");
    if (!ytdlClass) {
        Py_DECREF(options);
        std::string error = handlePythonException();
        return {false, "Failed to get YoutubeDL class: " + error};
    }

    PyObject* args = PyTuple_Pack(1, options);
    PyObject* ytdl = PyObject_CallObject(ytdlClass, args);
    
    Py_DECREF(args);
    Py_DECREF(options);
    Py_DECREF(ytdlClass);

    if (!ytdl) {
        std::string error = handlePythonException();
        return {false, "Failed to create YoutubeDL instance: " + error};
    }

    // Call download([url])
    PyObject* downloadMethod = PyObject_GetAttrString(ytdl, "download");
    if (!downloadMethod) {
        Py_DECREF(ytdl);
        std::string error = handlePythonException();
        return {false, "Failed to get download method: " + error};
    }

    PyObject* urlList = PyList_New(1);
    PyObject* urlObj = PyUnicode_FromString(url.c_str());
    PyList_SetItem(urlList, 0, urlObj); // Steals reference

    PyObject* downloadArgs = PyTuple_Pack(1, urlList);
    PyObject* result = PyObject_CallObject(downloadMethod, downloadArgs);
    
    Py_DECREF(downloadArgs);
    Py_DECREF(urlList);
    Py_DECREF(downloadMethod);
    Py_DECREF(ytdl);

    if (!result) {
        std::string error = handlePythonException();
        return {false, "Download failed: " + error};
    }

    // Result is typically 0 for success
    long returnCode = PyLong_AsLong(result);
    Py_DECREF(result);

    if (returnCode == 0) {
        return {true, "Download completed successfully"};
    } else {
        return {false, "Download failed with code " + std::to_string(returnCode)};
    }
}

std::pair<bool, std::string> EmbeddedPython::executePythonCode(const std::string& pythonCode) {
    if (!m_initialized) {
        return {false, "Python not initialized: " + m_lastError};
    }

    GILGuard gil;

    PyObject* mainModule = PyImport_AddModule("__main__");
    if (!mainModule) {
        return {false, "Failed to get __main__ module"};
    }

    PyObject* globalDict = PyModule_GetDict(mainModule); // Borrowed reference

    // Execute code
    PyObject* result = PyRun_String(pythonCode.c_str(), Py_eval_input, globalDict, globalDict);
    
    if (!result) {
        // Try as statement instead of expression
        PyErr_Clear();
        result = PyRun_String(pythonCode.c_str(), Py_file_input, globalDict, globalDict);
        
        if (!result) {
            std::string error = handlePythonException();
            return {false, "Execution failed: " + error};
        }
        
        Py_DECREF(result);
        return {true, "Code executed (no return value)"};
    }

    // Convert result to string
    PyObject* strResult = PyObject_Str(result);
    const char* utf8 = strResult ? PyUnicode_AsUTF8(strResult) : nullptr;
    std::string resultStr = utf8 ? utf8 : "Failed to convert result";
    
    Py_XDECREF(strResult);
    Py_DECREF(result);

    return {true, resultStr};
}

std::string EmbeddedPython::getYtDlpVersion() {
    if (!m_initialized) {
        return "Error: Python not initialized";
    }

    GILGuard gil;

    PyObject* versionObj = PyObject_GetAttrString(m_state->ytdlpModule, "version");
    if (!versionObj) {
        return "Error: Could not get version attribute";
    }

    PyObject* versionAttr = PyObject_GetAttrString(versionObj, "__version__");
    Py_DECREF(versionObj);
    
    if (!versionAttr) {
        return "Error: Could not get __version__";
    }

    const char* utf8 = PyUnicode_AsUTF8(versionAttr);
    std::string version = utf8 ? utf8 : "Unknown";
    
    Py_DECREF(versionAttr);
    return version;
}

// GILGuard implementation for thread safety
EmbeddedPython::GILGuard::GILGuard() {
    m_gilState = static_cast<int>(PyGILState_Ensure());
}

EmbeddedPython::GILGuard::~GILGuard() {
    PyGILState_Release(static_cast<PyGILState_STATE>(m_gilState));
}
