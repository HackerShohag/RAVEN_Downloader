/**
 * @file main.cpp
 * @brief Application entry point with Python runtime initialization
 * 
 * This file contains the main() function that initializes the RAVEN Downloader
 * application with embedded Python support. It handles:
 * 
 * Initialization Sequence:
 * 1. Qt GUI application setup
 * 2. Application path detection (Click package vs local)
 * 3. Embedded Python interpreter initialization
 * 4. DownloadManager construction with Python instance
 * 5. QML engine setup and context property binding
 * 6. Main window display
 * 7. Event loop execution
 * 8. Graceful cleanup on exit
 * 
 * Deployment Support:
 * - Ubuntu Touch Click packages (/opt/click.ubuntu.com/...)
 * - Local development builds (arbitrary paths)
 * - Automatic Python bundle path resolution
 * 
 * Error Handling:
 * - Python initialization failures trigger QProcess fallback mode
 * - Detailed logging for debugging deployment issues
 * - Application continues even if Python fails to load
 * 
 * Resource Management:
 * - Explicit cleanup of all allocated objects
 * - Python interpreter finalization before exit
 * - Qt event loop termination handling
 * 
 * @author Abdullah AL Shohag
 * @date 2022-2025
 * @copyright GNU General Public License v3.0 or later
 */

#include <QGuiApplication>
#include <QCoreApplication>
#include <QUrl>
#include <QString>
#include <QQuickView>
#include <QQmlEngine>
#include <QQmlContext>
#include <QDir>
#include <QDebug>

#include <downloadmanager.h>
#include "src/embedded_python.h"

/**
 * @brief Application entry point
 * 
 * @param argc Command-line argument count
 * @param argv Command-line argument values
 * @return Exit code (0 for success, non-zero for errors)
 * 
 * Initializes Qt application, embedded Python runtime, and QML user interface.
 * Automatically falls back to QProcess mode if Python initialization fails.
 */
int main(int argc, char *argv[])
{
    // Initialize Qt GUI application
    QGuiApplication *app = new QGuiApplication(argc, (char**)argv);
    app->setApplicationName("raven.downloader.shohag");

    qDebug() << "Starting RAVEN Downloader";

    // Determine application path for Python bundle location
    QString appPath = QCoreApplication::applicationDirPath();
    
    // For Click packages on Ubuntu Touch, the structure is:
    // /opt/click.ubuntu.com/<appname>/<version>/
    // Check if we're running from a Click package
    if (appPath.contains("/opt/click.ubuntu.com/")) {
        qDebug() << "Running from Click package:" << appPath;
    } else {
        qDebug() << "Running from local path:" << appPath;
    }
    
    // Initialize embedded Python
    EmbeddedPython* embeddedPython = nullptr;
    try {
        embeddedPython = new EmbeddedPython(appPath.toStdString());
        
        if (embeddedPython->isInitialized()) {
            qInfo() << "Python initialized successfully";
            qInfo() << "yt-dlp version:" << QString::fromStdString(embeddedPython->getYtDlpVersion());
        } else {
            qWarning() << "Python initialization failed. Falling back to QProcess mode.";
            qWarning() << "Error:" << QString::fromStdString(embeddedPython->getLastError());
        }
    } catch (const std::exception& e) {
        qCritical() << "Exception during Python initialization:" << e.what();
        qWarning() << "Continuing with QProcess fallback mode";
        embeddedPython = nullptr;
    }

    QQuickView *view = new QQuickView();
    
    // Pass Python instance to DownloadManager
    DownloadManager *dm = new DownloadManager(embeddedPython, view);

    view->engine()->rootContext()->setContextProperty("downloadManager", dm);
    view->setSource(QUrl("qrc:/MainPage.qml"));
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->show();

    int result = app->exec();
    
    // Cleanup
    delete dm;
    delete view;
    delete embeddedPython;
    delete app;
    
    return result;
}
