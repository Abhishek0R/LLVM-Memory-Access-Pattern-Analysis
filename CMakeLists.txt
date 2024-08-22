cmake_minimum_required(VERSION 3.10)
project(MemoryAccessPatterns)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set LLVM and Clang directories
set(LLVM_DIR "/usr/local/opt/llvm/lib/cmake/llvm")
set(Clang_DIR "/usr/local/opt/llvm/lib/cmake/clang")

find_package(LLVM REQUIRED CONFIG)
find_package(Clang REQUIRED CONFIG)

include_directories(${LLVM_INCLUDE_DIRS})
include_directories(${CLANG_INCLUDE_DIRS})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
add_definitions(${LLVM_DEFINITIONS})

# Create the shared library for the LLVM pass
add_library(newmemory SHARED
    src/newmemory.cpp
)

# Link the LLVM libraries
llvm_map_components_to_libnames(llvm_libs support core irreader passes)
target_link_libraries(newmemory ${llvm_libs})

# Ensure the correct output directory for the shared library
set_target_properties(newmemory PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
)

# Optionally, install the library (if you want to install it to a standard location)
install(TARGETS newmemory DESTINATION lib)
