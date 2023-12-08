# cmake build file for squish
# by Stefan Roettger (stefan@stereofx.org)
# updated by Simon Brown (si@sjbrown.co.uk)
# updated for Apple Silicon by Bob Berry (bberry@galacticannihilation.gg)

# features:
#   Xcode: builds universal binaries, uses SSE2 on i386 and Altivec on ppc
#   Unix and VS: SSE2 support is enabled by default
#   use BUILD_SQUISH_WITH_SSE2 and BUILD_SQUISH_WITH_ALTIVEC to override
cmake_minimum_required(VERSION 3.21) # Updated the minimum required version for better modern CMake features

project(squish LANGUAGES CXX) # Specified the language to make it clear

# Options
option(BUILD_SQUISH_WITH_SSE2 "Build with SSE2." OFF)
option(BUILD_SQUISH_WITH_ALTIVEC "Build with Altivec." OFF)
option(BUILD_SHARED_LIBS "Build shared libraries." OFF)
option(BUILD_SQUISH_EXTRA "Build extra source code." OFF)

# SSE2 and Altivec are not applicable for Apple Silicon, so disabling them
if(APPLE)
    set(BUILD_SQUISH_WITH_SSE2 OFF)
    set(BUILD_SQUISH_WITH_ALTIVEC OFF)
endif()

# Header and Source files
set(SQUISH_HDRS
    squish.h
)

set(SQUISH_SRCS
    alpha.cpp
    alpha.h
    clusterfit.cpp
    clusterfit.h
    colourblock.cpp
    colourblock.h
    colourfit.cpp
    colourfit.h
    colourset.cpp
    colourset.h
    maths.cpp
    maths.h
    rangefit.cpp
    rangefit.h
    simd.h
    simd_float.h
    simd_sse.h
    simd_ve.h
    singlecolourfit.cpp
    singlecolourfit.h
    singlecolourlookup.inl
    squish.cpp
)

# Include directories
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

# Library target
add_library(squish ${SQUISH_SRCS} ${SQUISH_HDRS})

# Set a variable for the suffix based on the build type
set(SQUISH_SUFFIX "")
    if(CMAKE_BUILD_TYPE STREQUAL "debug")
        set(SQUISH_SUFFIX "_debug")
    elseif(CMAKE_BUILD_TYPE STREQUAL "asan")
        set(SQUISH_SUFFIX "_asan")
endif()

set_target_properties(squish PROPERTIES
    OUTPUT_NAME "squish${SQUISH_SUFFIX}"
    PUBLIC_HEADER "${SQUISH_HDRS}"
    VERSION 0.0
    SOVERSION 0.0
)

# Debug configuration
set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g")

# Address Sanitizer configuration
set(CMAKE_CXX_FLAGS_ASAN
    "-fsanitize=address -fno-omit-frame-pointer -g"
    CACHE STRING "Flags used by the C++ compiler during Address Sanitizer builds."
    FORCE)
set(CMAKE_C_LINK_EXECUTABLE_ASAN
    "${CMAKE_C_LINK_EXECUTABLE} -fsanitize=address"
    CACHE STRING "Flags used for linking binaries during Address Sanitizer builds."
    FORCE)
set(CMAKE_EXE_LINKER_FLAGS_ASAN
    "${CMAKE_EXE_LINKER_FLAGS} -fsanitize=address"
    CACHE STRING "Flags used for executables during Address Sanitizer builds."
    FORCE)

# Extra build targets
if(BUILD_SQUISH_EXTRA)
    SET(SQUISHTEST_SRCS extra/squishtest.cpp)

    ADD_EXECUTABLE(squishtest ${SQUISHTEST_SRCS})
    SET_TARGET_PROPERTIES(squishtest PROPERTIES DEBUG_POSTFIX "d")
    TARGET_LINK_LIBRARIES(squishtest squish)

    SET(SQUISHPNG_SRCS extra/squishpng.cpp)

    FIND_PACKAGE(PNG)

    IF (PNG_FOUND)
        SET(CMAKE_PLATFORM_IMPLICIT_INCLUDE_DIRECTORIES)
        INCLUDE_DIRECTORIES(${PNG_INCLUDE_DIR})
        ADD_EXECUTABLE(squishpng ${SQUISHPNG_SRCS})
        SET_TARGET_PROPERTIES(squishpng PROPERTIES DEBUG_POSTFIX "d")
        TARGET_LINK_LIBRARIES(squishpng squish ${PNG_LIBRARIES})
    ENDIF (PNG_FOUND)
endif()

# Installation
install(
    TARGETS squish
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    PUBLIC_HEADER DESTINATION include
)
