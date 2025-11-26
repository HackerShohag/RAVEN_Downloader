set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
set(YOUTUBEDL "YoutubeDL")
set(DOWNLOADER "DownloadManager")

# Find Python3 for embedded interpreter
# For cross-compilation: use host Python as interpreter, ARM Python for libraries
set(Python3_FIND_STRATEGY LOCATION)
set(Python3_FIND_REGISTRY NEVER)

# Get the target architecture triplet for cross-compilation
execute_process(
    COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
    OUTPUT_VARIABLE ARCH_TRIPLET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Use host Python executable for running during build
find_program(PYTHON38_EXECUTABLE python3.8)
if(PYTHON38_EXECUTABLE)
    set(Python3_EXECUTABLE ${PYTHON38_EXECUTABLE})
    message(STATUS "Found python3.8 at: ${PYTHON38_EXECUTABLE}")
endif()

# Set hints for cross-compilation to find Python headers and libraries for target arch
if(ARCH_TRIPLET)
    set(Python3_INCLUDE_DIRS "/usr/include/python3.8")
    set(Python3_LIBRARIES "/usr/lib/${ARCH_TRIPLET}/libpython3.8.so")
    message(STATUS "Cross-compiling for ${ARCH_TRIPLET}")
    message(STATUS "Using Python include dir: ${Python3_INCLUDE_DIRS}")
    message(STATUS "Using Python library: ${Python3_LIBRARIES}")
    
    # For cross-compilation, manually set variables and skip interpreter check
    set(Python3_FOUND TRUE)
    set(Python3_VERSION "3.8.10")
    set(Python3_VERSION_MAJOR 3)
    set(Python3_VERSION_MINOR 8)
    set(Python3_Interpreter_FOUND TRUE)
    set(Python3_Development_FOUND TRUE)
else()
    find_package(Python3 3.8 COMPONENTS Interpreter Development REQUIRED)
endif()

message(STATUS "Using Python: ${Python3_VERSION} at ${Python3_EXECUTABLE}")
message(STATUS "Python Include Dirs: ${Python3_INCLUDE_DIRS}")
message(STATUS "Python Libraries: ${Python3_LIBRARIES}")

find_package(Qt5 COMPONENTS Gui REQUIRED)
find_package(Qt5 REQUIRED COMPONENTS Core)

set(
    SRC
    youtubedl.h
    youtubedl.cpp
    embedded_python.h
    embedded_python.cpp
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

# Link Python3 libraries to both targets
target_include_directories(${YOUTUBEDL} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}" ${Python3_INCLUDE_DIRS})
target_include_directories(${DOWNLOADER} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}" ${Python3_INCLUDE_DIRS})

target_link_libraries(${YOUTUBEDL} ${Python3_LIBRARIES})
target_link_libraries(${DOWNLOADER} ${Python3_LIBRARIES})

set(QT_IMPORTS_DIR "/lib/${ARCH_TRIPLET}")

install(TARGETS ${YOUTUBEDL} DESTINATION ${QT_IMPORTS_DIR})
install(TARGETS ${DOWNLOADER} DESTINATION ${QT_IMPORTS_DIR})
