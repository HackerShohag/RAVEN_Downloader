/*
 * Copyright (C) 2022  Abdullah AL Shohag
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * raven.downloader is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <QGuiApplication>
#include <QCoreApplication>
#include <QUrl>
#include <QString>
#include <QQuickView>
#include <QQmlEngine>
#include <QQmlContext>

#include <QQmlApplicationEngine>
#include <QSettings>
#include <QQuickStyle>
#include <QIcon>



#include <youtubedl.h>
#include <downloadmanager.h>

int main(int argc, char *argv[])
{
    QGuiApplication::setApplicationName("raven.downloader.shohag");
    QGuiApplication::setOrganizationName("QtProject");

    QGuiApplication app(argc, argv);

    DownloadManager *dm = new DownloadManager();

    qDebug() << "Starting app from main.cpp";

    QIcon::setThemeName("gallery");

    QSettings settings;
    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE"))
        QQuickStyle::setStyle(settings.value("style").toString());

    // If this is the first time we're running the application,
    // we need to set a style in the settings so that the QML
    // can find it in the list of built-in styles.
    const QString styleInSettings = settings.value("style").toString();
    if (styleInSettings.isEmpty())
        settings.setValue(QLatin1String("style"), QQuickStyle::name());

    QQmlApplicationEngine engine;

    QStringList builtInStyles = { QLatin1String("Basic"), QLatin1String("Fusion"),
        QLatin1String("Imagine"), QLatin1String("Material"), QLatin1String("Universal") };
#if defined(Q_OS_MACOS)
    builtInStyles << QLatin1String("macOS");
    builtInStyles << QLatin1String("iOS");
#elif defined(Q_OS_IOS)
    builtInStyles << QLatin1String("iOS");
#elif defined(Q_OS_WINDOWS)
    builtInStyles << QLatin1String("Windows");
#endif

    engine.setInitialProperties({{ "builtInStyles", builtInStyles }});

    engine.rootContext()->setContextProperty("downloadManager", dm);

    engine.load(QUrl("qrc:/qml/MainPage.qml"));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
