#!/bin/bash

# Function to build a specific configuration
build_configuration() {
    build_type=$1
    build_dir="build_${build_type}"
    cmake_flags=$2

    mkdir $build_dir   # Ensure the directory exists
    pushd $build_dir      # Change into the build directory
    cmake .. -DCMAKE_BUILD_TYPE=$build_type $cmake_flags
    make
    popd                  # Return to the original directory
}

# Build standard version
build_configuration "release" ""

# Build debug version
build_configuration "debug" ""

# Build ASan version
asan_flags="-DCMAKE_CXX_FLAGS='${CMAKE_CXX_FLAGS_ASAN}' -DCMAKE_EXE_LINKER_FLAGS='${CMAKE_EXE_LINKER_FLAGS_ASAN}'"
build_configuration "asan" "$asan_flags"
