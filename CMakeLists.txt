# CaOS

cmake_minimum_required(VERSION 3.18...3.25)
# Weird (bug?)Requirement to explicitly point out NASM doesn't do linking...
# https://stackoverflow.com/questions/56420035/how-to-use-cmake-to-build-binaries-with-nasm
set(CMAKE_ASM_NASM_LINK_EXECUTABLE "ld <CMAKE_ASM_NASM_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>")

#specify C params
set(CMAKE_C_COMPILER /usr/bin/clang-15)
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED True)

# specify the C++ params
set(CMAKE_CXX_COMPILER /usr/bin/clang++-15)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Set the boostrap as our first project to build
project(bootloader VERSION 0.01 LANGUAGES ASM_NASM)   
# The binary file name
set(CaOS_BOOTLOADER_BINARY bootloader.bin)
# REAL Mode instructions
include_directories(${PROJECT_SOURCE_DIR} boot/16bit) 
# PROTECTED Mode instructions
include_directories(${PROJECT_SOURCE_DIR} boot/32bit) 
# LONG Mode instructions
include_directories(${PROJECT_SOURCE_DIR} boot/64bit) 
# Set Binary format to RAW for the bootloader-specific code
set(CMAKE_ASM_NASM_OBJECT_FORMAT bin)

# Force Binary Format for compiler call
set(CMAKE_ASM_NASM_COMPILE_OBJECT "<CMAKE_ASM_NASM_COMPILER> <INCLUDES> <FLAGS> -f ${CMAKE_ASM_NASM_OBJECT_FORMAT} -o <OBJECT> <SOURCE>")

# bootloader root - ASM does it's own inclusions during assembly
set_source_files_properties(Source/BootSector/bootloader.asm PROPERTIES LANGUAGE ASM_NASM)

# Create the object file
add_library(${CaOS_BOOTLOADER_BINARY} Source/BootSector/bootloader.asm)

project(kernel VERSION 0.00)
# Not there yet.