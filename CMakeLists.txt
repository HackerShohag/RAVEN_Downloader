cmake_minimum_required(VERSION 3.0.0)
project(raven.downloader VERSION 3.1.1 LANGUAGES CXX)

add_subdirectory(src)

# Automatically create moc files
set(CMAKE_AUTOMOC ON)

find_package(Qt5Core REQUIRED)
find_package(Qt5Qml REQUIRED)
find_package(Qt5Quick REQUIRED)
find_package(Qt5QuickControls2 REQUIRED)

execute_process(
    COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
    OUTPUT_VARIABLE ARCH_TRIPLET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(QT_IMPORTS_DIR "lib/${ARCH_TRIPLET}")
set(PROJECT_NAME "raven.downloader")
set(FULL_PROJECT_NAME "raven.downloader.shohag")
set(DATA_DIR /)
set(DESKTOP_FILE_NAME ${PROJECT_NAME}.desktop)

# This command figures out the minimum SDK framework for use in the manifest
# file via the environment variable provided by Clickable or sets a default value otherwise.
if(DEFINED ENV{SDK_FRAMEWORK})
    set(CLICK_FRAMEWORK "$ENV{SDK_FRAMEWORK}")
else()
    set(CLICK_FRAMEWORK "ubuntu-sdk-20.04")
endif()

# This figures out the build direcory
if(DEFINED ENV{BUILD_DIR})
    set(BUILD_DIR "$ENV{BUILD_DIR}")
else()
    set(BUILD_DIR ${CMAKE_BINARY_DIR})
endif()

# This figures out the target architecture for use in the manifest file.
if(DEFINED ENV{ARCH})
    set(CLICK_ARCH "$ENV{ARCH}")
else()
    execute_process(
        COMMAND dpkg-architecture -qDEB_HOST_ARCH
        OUTPUT_VARIABLE CLICK_ARCH
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
endif()

# Sets BUILD_VERSION: Either tag of the current git HEAD or devel build version with git hash
execute_process(
  COMMAND git describe --tags --abbrev=0 --exact-match
  OUTPUT_VARIABLE BUILD_VERSION_RAW
  OUTPUT_STRIP_TRAILING_WHITESPACE
  ERROR_QUIET
  )
if(NOT BUILD_VERSION_RAW)
  set(
    LAST_VERSION_RAW " v${PROJECT_VERSION}-focal"
  )
  string(TIMESTAMP BUILD_VERSION_RAW "${LAST_VERSION_RAW}.%y%m%d%H%M%S" UTC)
endif(NOT BUILD_VERSION_RAW)
string(SUBSTRING ${BUILD_VERSION_RAW} 1 -1 BUILD_VERSION)
message(STATUS "Build version is: ${BUILD_VERSION}")


configure_file(manifest.json.in ${CMAKE_CURRENT_BINARY_DIR}/manifest.json)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/manifest.json DESTINATION ${CMAKE_INSTALL_PREFIX})
install(FILES ${PROJECT_NAME}.apparmor DESTINATION ${DATA_DIR})
install(FILES assets/raven_downloader_logo_v3.png DESTINATION assets)

qt5_add_resources(QT_RESOURCES qml/qml.qrc)
qt5_add_resources(QT_RESOURCES assets/assets.qrc)

add_executable(${PROJECT_NAME} main.cpp ${QT_RESOURCES})

set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS_RELEASE -s)
target_link_libraries(${PROJECT_NAME} DownloadManager YoutubeDL Qt5::Gui Qt5::Qml Qt5::Quick Qt5::QuickControls2)

install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX})

# Translations
file(GLOB_RECURSE I18N_SRC_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/po qml/*.qml qml/*.js)
list(APPEND I18N_SRC_FILES ${DESKTOP_FILE_NAME}.in.h)

find_program(INTLTOOL_MERGE intltool-merge)
if(NOT INTLTOOL_MERGE)
    message(FATAL_ERROR "Could not find intltool-merge, please install the intltool package")
endif()
find_program(INTLTOOL_EXTRACT intltool-extract)
if(NOT INTLTOOL_EXTRACT)
    message(FATAL_ERROR "Could not find intltool-extract, please install the intltool package")
endif()

add_custom_target(${DESKTOP_FILE_NAME} ALL
    COMMENT "Merging translations into ${DESKTOP_FILE_NAME}..."
    COMMAND LC_ALL=C ${INTLTOOL_MERGE} -d -u ${CMAKE_SOURCE_DIR}/po ${CMAKE_SOURCE_DIR}/${DESKTOP_FILE_NAME}.in ${DESKTOP_FILE_NAME}
    COMMAND sed -i 's/${PROJECT_NAME}-//g' ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE_NAME}
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE_NAME} DESTINATION ${DATA_DIR})

# yt-dlp architecture dependend files downloads
if(${CLICK_ARCH} STREQUAL "arm64")
    set(TARGET_ARCH "_aarch64")
elseif(${CLICK_ARCH} STREQUAL "armhf")
    set(TARGET_ARCH "_armv7l")
else()
    set(TARGET_ARCH "")
endif()

message("Target architecture ${CLICK_ARCH} and link https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux${TARGET_ARCH}" )

file(DOWNLOAD https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux${TARGET_ARCH} ${BUILD_DIR}/bin/yt-dlp_linux SHOW_PROGRESS)
install(FILES ${BUILD_DIR}/bin/yt-dlp_linux TYPE BIN PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ)

add_subdirectory(po)
add_subdirectory(plugins)

# Make source files visible in qtcreator
file(GLOB_RECURSE PROJECT_SRC_FILES
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    qml/*.qml
    qml/*.js
    src/*
    *.json
    *.json.in
    *.apparmor
    *.desktop.in
)

add_custom_target(${PROJECT_NAME}_FILES ALL SOURCES ${PROJECT_SRC_FILES})

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()
