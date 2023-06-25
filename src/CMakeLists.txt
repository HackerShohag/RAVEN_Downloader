set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")
set(YOUTUBEDL "YoutubeDL")
set(DOWNLOADER "DownloadManager")

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml)
find_package(Python3 REQUIRED COMPONENTS Interpreter Development)

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

target_link_libraries(${YOUTUBEDL} PRIVATE Qt6::Core Qt6::CorePrivate Qt6::Gui Qt6::DBus Qt6::Qml Qt6::Quick)
target_link_libraries(${YOUTUBEDL} PRIVATE ${Python3_LIBRARIES})
target_link_libraries(${DOWNLOADER} PRIVATE Qt6::Core Qt6::Quick)

target_include_directories(${YOUTUBEDL} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")
target_include_directories(${YOUTUBEDL} PRIVATE ${Python3_INCLUDE_DIRS})
target_include_directories(${DOWNLOADER} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")

execute_process(
    COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
    OUTPUT_VARIABLE ARCH_TRIPLET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(QT_IMPORTS_DIR "/lib/${ARCH_TRIPLET}")

install(TARGETS ${YOUTUBEDL} DESTINATION ${QT_IMPORTS_DIR})
install(TARGETS ${DOWNLOADER} DESTINATION ${QT_IMPORTS_DIR})
