set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")
set(YOUTUBEDL "YoutubeDL")

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml)

set(
    SRC
    youtubedl.h
    youtubedl.cpp
    mediaformat.h
    mediaformat.cpp
    downloadmanager.h
    downloadmanager.cpp

)

set(CMAKE_AUTOMOC ON)

add_library(${YOUTUBEDL} SHARED ${SRC})

set_target_properties(${YOUTUBEDL} PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${YOUTUBEDL})

target_link_libraries(${YOUTUBEDL} PRIVATE Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick)

target_include_directories(${YOUTUBEDL} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")

execute_process(
    COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
    OUTPUT_VARIABLE ARCH_TRIPLET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(QT_IMPORTS_DIR "/lib/${ARCH_TRIPLET}")

install(TARGETS ${YOUTUBEDL} DESTINATION ${QT_IMPORTS_DIR})
