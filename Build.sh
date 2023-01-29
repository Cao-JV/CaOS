#!/bin/bash

# CaOS - Build Utilities
#
# A script to kick off the CMake process and then perform various conveniences,
# Like kicking off emulation test
# 
# Maybe CMake could do this, I don't know it as well as shell, yet.
# Please advise!
#
# CopyRight (c) 2023, Cao Smith

# Set variables
# The first cli argument is the command
Command="${1}"

# Project-related variables
ProjectNameBoot="bootloader"
FileNameBinBoot="${ProjectNameBoot}.bin"
FileNameSrcBoot="${ProjectNameBoot}.asm"
FileNameObjBoot="${FileNameSrcBoot}.o"

# Directories
DirRoot="/home/cao/Development/C/c/"
DirBuild="${DirRoot}Make/"
DirCMake="${DirBuild}/CMakeFiles/"
DirBootOutput="${DirCMake}${FileNameBinBoot}.dir/Source/BootSector/"
BinBootloader="${DirBootOutput}${FileNameObjBoot}"
# SubShell to go to build dir & kick off make
(cd ${DirBuild}
make)





if [ "${Command}" = "run" ]; then
    qemu-system-x86_64 -drive format=raw,file=${BinBootloader}
elif [ "${Command}" = "" ]; then
    echo "No Command"
fi