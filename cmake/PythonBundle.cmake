# Python Bundle Management Module
# This module handles downloading, extracting, and configuring Python bundle

# Detect Python version from system or use default
if(EXISTS "/usr/lib/python3.8")
    set(PYTHON_VERSION "3.8")
    set(PYTHON_SO_VERSION "3.8")
elseif(EXISTS "/usr/lib/python3.9")
    set(PYTHON_VERSION "3.9")
    set(PYTHON_SO_VERSION "3.9")
elseif(EXISTS "/usr/lib/python3.10")
    set(PYTHON_VERSION "3.10")
    set(PYTHON_SO_VERSION "3.10")
else()
    # Default to 3.8 and download it
    set(PYTHON_VERSION "3.8")
    set(PYTHON_SO_VERSION "3.8")
endif()

message(STATUS "Using Python version: ${PYTHON_VERSION}")

set(PYTHON_BUNDLE_DIR "${CMAKE_BINARY_DIR}/python_bundle")
set(PYTHON_STDLIB_DIR "${PYTHON_BUNDLE_DIR}/lib/python${PYTHON_VERSION}")
set(PYTHON_SITE_PACKAGES "${PYTHON_STDLIB_DIR}/site-packages")
set(PYTHON_DOWNLOAD_URL "https://www.python.org/ftp/python/3.8.20/Python-3.8.20.tar.xz")
set(PYTHON_TARBALL "${CMAKE_BINARY_DIR}/Python-3.8.20.tar.xz")
set(PYTHON_EXTRACT_DIR "${CMAKE_BINARY_DIR}/Python-3.8.20")

# Function to download and extract Python
function(setup_python_bundle)
    if(NOT EXISTS "${PYTHON_BUNDLE_DIR}/lib/python${PYTHON_VERSION}")
        message(STATUS "Creating Python ${PYTHON_VERSION} bundle in build directory...")
        
        # Try system Python first (in Docker container)
        if(EXISTS "/usr/lib/python${PYTHON_VERSION}")
            message(STATUS "Copying Python ${PYTHON_VERSION} standard library from system...")
            file(MAKE_DIRECTORY "${PYTHON_STDLIB_DIR}")
            execute_process(
                COMMAND ${CMAKE_COMMAND} -E copy_directory
                        "/usr/lib/python${PYTHON_VERSION}"
                        "${PYTHON_STDLIB_DIR}"
            )
        else()
            # Download Python if not available in system
            message(STATUS "System Python ${PYTHON_VERSION} not found, downloading from python.org...")
            
            if(NOT EXISTS "${PYTHON_TARBALL}")
                message(STATUS "Downloading Python ${PYTHON_VERSION} source...")
                file(DOWNLOAD "${PYTHON_DOWNLOAD_URL}" "${PYTHON_TARBALL}"
                     SHOW_PROGRESS
                     STATUS DOWNLOAD_STATUS)
                list(GET DOWNLOAD_STATUS 0 DOWNLOAD_ERROR)
                if(DOWNLOAD_ERROR)
                    message(FATAL_ERROR "Failed to download Python from ${PYTHON_DOWNLOAD_URL}")
                endif()
            endif()
            
            # Extract Python tarball
            if(NOT EXISTS "${PYTHON_EXTRACT_DIR}")
                message(STATUS "Extracting Python tarball...")
                execute_process(
                    COMMAND ${CMAKE_COMMAND} -E tar xf "${PYTHON_TARBALL}"
                    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
                    RESULT_VARIABLE EXTRACT_RESULT
                )
                if(EXTRACT_RESULT)
                    message(FATAL_ERROR "Failed to extract Python tarball")
                endif()
            endif()
            
            # Copy standard library from extracted source
            message(STATUS "Copying Python ${PYTHON_VERSION} standard library from extracted source...")
            file(MAKE_DIRECTORY "${PYTHON_STDLIB_DIR}")
            execute_process(
                COMMAND ${CMAKE_COMMAND} -E copy_directory
                        "${PYTHON_EXTRACT_DIR}/Lib"
                        "${PYTHON_STDLIB_DIR}"
            )
        endif()
        
        # Clean up unnecessary modules to reduce size
        message(STATUS "Cleaning up unnecessary Python modules...")
        file(REMOVE_RECURSE 
            "${PYTHON_STDLIB_DIR}/test"
            "${PYTHON_STDLIB_DIR}/unittest"
            "${PYTHON_STDLIB_DIR}/idlelib"
            "${PYTHON_STDLIB_DIR}/tkinter"
            "${PYTHON_STDLIB_DIR}/turtledemo"
            "${PYTHON_STDLIB_DIR}/ensurepip"
            "${PYTHON_STDLIB_DIR}/distutils"
            "${PYTHON_STDLIB_DIR}/pydoc_data"
            "${PYTHON_STDLIB_DIR}/lib2to3"
        )
        
        message(STATUS "Python standard library prepared successfully")
    else()
        message(STATUS "Python bundle already exists, skipping setup")
    endif()
endfunction()

# Function to install pip packages
function(install_pip_packages)
    set(YTDLP_MARKER "${PYTHON_SITE_PACKAGES}/yt_dlp/__init__.py")
    
    if(NOT EXISTS "${YTDLP_MARKER}")
        add_custom_target(install_ytdlp ALL
            COMMAND ${CMAKE_COMMAND} -E make_directory "${PYTHON_SITE_PACKAGES}"
            # Bootstrap pip if not available (Python 3.8 compatible)
            COMMAND bash -c "if ! python3.8 -m pip --version &> /dev/null && ! python3 -m pip --version &> /dev/null; then echo 'pip not found, installing pip...'; wget -q https://bootstrap.pypa.io/pip/get-pip.py -O /tmp/get-pip.py && python3 /tmp/get-pip.py --user --no-warn-script-location && rm -f /tmp/get-pip.py; fi"
            # Install yt-dlp and dependencies using python3.8 if available, otherwise python3
            COMMAND bash -c "if command -v python3.8 &> /dev/null; then python3.8 -m pip install --target=${PYTHON_SITE_PACKAGES} --no-cache-dir --upgrade yt-dlp certifi brotli mutagen pycryptodome websockets; else python3 -m pip install --target=${PYTHON_SITE_PACKAGES} --no-cache-dir --upgrade yt-dlp certifi brotli mutagen pycryptodome websockets; fi"
            COMMAND ${CMAKE_COMMAND} -E touch "${YTDLP_MARKER}.stamp"
            COMMENT "Installing yt-dlp and dependencies to Python bundle..."
            VERBATIM
        )
    else()
        add_custom_target(install_ytdlp
            COMMAND ${CMAKE_COMMAND} -E echo "yt-dlp already installed, skipping..."
        )
    endif()
endfunction()

# Function to install Python bundle to Click package
function(install_python_bundle)
    # Install Python bundle to Click package
    install(DIRECTORY "${PYTHON_BUNDLE_DIR}/"
            DESTINATION vendor/python
            USE_SOURCE_PERMISSIONS
            PATTERN "*.pyc" EXCLUDE
            PATTERN "__pycache__" EXCLUDE
            PATTERN "*.dist-info" EXCLUDE)

    # Install Python shared library for runtime (try 3.8, 3.9, and 3.10)
    if(EXISTS "/usr/lib/${ARCH_TRIPLET}/libpython${PYTHON_SO_VERSION}.so.1.0")
        install(FILES "/usr/lib/${ARCH_TRIPLET}/libpython${PYTHON_SO_VERSION}.so.1.0"
                DESTINATION lib/${ARCH_TRIPLET}
                PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
    elseif(EXISTS "/usr/lib/${ARCH_TRIPLET}/libpython3.9.so.1.0")
        install(FILES "/usr/lib/${ARCH_TRIPLET}/libpython3.9.so.1.0"
                DESTINATION lib/${ARCH_TRIPLET}
                PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
    elseif(EXISTS "/usr/lib/${ARCH_TRIPLET}/libpython3.8.so.1.0")
        install(FILES "/usr/lib/${ARCH_TRIPLET}/libpython3.8.so.1.0"
                DESTINATION lib/${ARCH_TRIPLET}
                PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
    else()
        message(WARNING "Python shared library not found for installation")
    endif()
endfunction()

# Execute the setup
setup_python_bundle()
install_pip_packages()
install_python_bundle()
