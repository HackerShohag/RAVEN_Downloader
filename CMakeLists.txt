# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.16)
project(raven.downloader LANGUAGES CXX)

add_subdirectory(src)

set(CMAKE_AUTOMOC ON)

if(NOT DEFINED INSTALL_EXAMPLESDIR)
    set(INSTALL_EXAMPLESDIR "examples")
endif()

set(INSTALL_EXAMPLEDIR "${INSTALL_EXAMPLESDIR}/quickcontrols/gallery")

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickControls2)

qt_add_executable(raven.downloader
    main.cpp
)

qt_add_qml_module(raven.downloader
    URI gallery
    NO_RESOURCE_TARGET_PATH
    QML_FILES
        "qml/MainPage.qml"
        "qml/Components/MediaItem.qml"
        "qml/Components/LayoutsCustom.qml"
        "qml/Components/CustomProgressBar.qml"
        "qml/Components/CustomComboPopup.qml"
        "qml/Components/ToolBar.qml"
    RESOURCES
        "icons/gallery/20x20/back.png"
        "icons/gallery/20x20/drawer.png"
        "icons/gallery/20x20/menu.png"
        "icons/gallery/20x20@2/back.png"
        "icons/gallery/20x20@2/drawer.png"
        "icons/gallery/20x20@2/menu.png"
        "icons/gallery/20x20@3/back.png"
        "icons/gallery/20x20@3/drawer.png"
        "icons/gallery/20x20@3/menu.png"
        "icons/gallery/20x20@4/back.png"
        "icons/gallery/20x20@4/drawer.png"
        "icons/gallery/20x20@4/menu.png"
        "icons/gallery/index.theme"
        "images/arrow.png"
        "images/arrow@2x.png"
        "images/arrow@3x.png"
        "images/arrow@4x.png"
        "images/arrows.png"
        "images/arrows@2x.png"
        "images/arrows@3x.png"
        "images/arrows@4x.png"
        "images/qt-logo.png"
        "images/qt-logo@2x.png"
        "images/qt-logo@3x.png"
        "images/qt-logo@4x.png"
        "qmldir"
        "qtquickcontrols2.conf"
)

target_link_libraries(raven.downloader PUBLIC
    Qt::Core
    Qt::Gui
    Qt::Quick
    Qt::QuickControls2
    DownloadManager
    YoutubeDL
)

if(UNIX AND NOT APPLE AND CMAKE_CROSSCOMPILING)
    find_package(Qt6 REQUIRED COMPONENTS QuickTemplates2)

    # Work around QTBUG-86533
    target_link_libraries(raven.downloader PRIVATE Qt::QuickTemplates2)
endif()

add_custom_command(TARGET ${PROJECT_NAME} PRE_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory "${CMAKE_SOURCE_DIR}/src/yt_dlp/yt_dlp" "${CMAKE_CURRENT_BINARY_DIR}/yt_dlp"
)

install(TARGETS raven.downloader
    RUNTIME DESTINATION "${INSTALL_EXAMPLEDIR}"
    BUNDLE DESTINATION "${INSTALL_EXAMPLEDIR}"
    LIBRARY DESTINATION "${INSTALL_EXAMPLEDIR}"
)

set(ANDROID_PACKAGE_SOURCE_DIR ${PROJECT_SOURCE_DIR}/android CACHE INTERNAL "")
