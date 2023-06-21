# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles/raven.downloader_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/raven.downloader_autogen.dir/ParseCache.txt"
  "raven.downloader_autogen"
  )
endif()
