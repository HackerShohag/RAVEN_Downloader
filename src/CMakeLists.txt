set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
set(YOUTUBEDL "YoutubeDL")
set(DOWNLOADER "DownloadManager")

find_package(Qt5 COMPONENTS Gui REQUIRED)
find_package(Qt5 REQUIRED COMPONENTS Core)

set(
    SRC
    youtubedl.h
    youtubedl.cpp
)
set(
    DMSRC
    mediaformat.h
    mediaformat.cpp
    downloadmanager.h
    downloadmanager.cpp
)

set(CMAKE_AUTOMOC ON)

add_library(${YOUTUBEDL} SHARED ${SRC})
add_library(${DOWNLOADER} SHARED ${DMSRC})

set_target_properties(${YOUTUBEDL} PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${YOUTUBEDL})
set_target_properties(${DOWNLOADER} PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${DOWNLOADER})

qt5_use_modules(${YOUTUBEDL} Qml Quick DBus)
qt5_use_modules(${DOWNLOADER} Core)

target_link_libraries(${DOWNLOADER} Qt5::Core Qt5::Quick)

target_include_directories(${YOUTUBEDL} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")
target_include_directories(${DOWNLOADER} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")

execute_process(
    COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
    OUTPUT_VARIABLE ARCH_TRIPLET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(QT_IMPORTS_DIR "/lib/${ARCH_TRIPLET}")

install(TARGETS ${YOUTUBEDL} DESTINATION ${QT_IMPORTS_DIR})
install(TARGETS ${DOWNLOADER} DESTINATION ${QT_IMPORTS_DIR})
