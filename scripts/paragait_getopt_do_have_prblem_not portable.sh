#!/usr/bin/env bash

#? paragaitdep 0.1.0
#? Copyright (C) 2017 Nicolas Gruel
#? License MIT
#? This is free software: you are free to change and redistribute it.
#? There is NO WARRANTY, to the extent permitted by law.

version=$(grep "^#?"  "$0" | cut -c 4-)

# Usage info
show_help() {
    cat << EOF
    Usage: ${0##*/} [ -d WORKING_DIR | -directory WORKING_DIR] [ -V | --version ] [ -h | --help ]
    
       -h | --help display this help and exit
       -d          WORKINGDIR  write the result to OUTFILE instead of standard output.
       -V          print version of the script
   EOF
   }

   
# options may be followed by one colon to indicate they have a required argument
if ! options=$(getopt -o d:vVh\? -l directory:,help,verbose,version -- "$@")
then
    # something went wrong, getopt will put out an error message for us
    exit 1
fi

set -- $options

while [ $# -gt 0 ]
do
    case $1 in
    # for options with required arguments, an additional shift is required
    -d|--directory)  
        WORKING_DIR="$2"; shift ;;
    -v|--verbose) verbose=$((verbose+1)) ;;

    -V|--version) echo "${version}"
        exit 1
        ;;
    -h|--help|-\?) show_help; exit;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
    (*) break;;
    esac
    shift
done

#Define working directory as the one where the script is executed.

if [ -z "$WORKING_DIR" ]; then
    WORKING_DIR=`pwd`
fi

if [ ! -d $WORKING_DIR ]; then
    mkdir $WORKING_DIR
fi

cd $WORKING_DIR

exit 1;

# Installation of system program needed and library
# Done with docker

####################################################################
# Parafem compilation and installation from source code (repository)
####################################################################

# Parafem is provided through sourceforge and a subversion repository
# I prefer to use git to download the code 

if [ ! -d parafem-code ]; then
    git svn clone https://svn.code.sf.net/p/parafem/code/trunk parafem-code
    cd parafem-code/parafem
else
    cd parafem-code/parafem
    git svn fetch
    git rebase git-svn
fi

# Compilation for linuxdesktop
MACHINE=linuxdesktop ./make-parafem 2>&1 | tee parafem.log

# Testing parafem
if [ ! -d test ]; then
 mkdir test
fi
cp ../examples/5th_ed/p121/demo/p121_demo.mg test/
cd test
../bin/p12meshgen p121_demo
../bin/p121 p121_demo

#######################################################
# GaitSym compilation and installation from source code
#######################################################

# Go back to working directory
cd $WORKING_DIR

# Use the official version 2015

# Compile the prerequisites
if [ ! -f GaitSym_2015_dep.zip ]; then
    wget -c http://www.animalsimulation.org/software/GaitSym/GaitSym_2015_dep.zip
    unzip GaitSym_2015_dep.zip

    cd GaitSym_2015_dep
    for i in $( ls ); 
        do tar xvf $i; 
    done

    # libxml2
    cd libxml2-2.9.1
    ./configure 
    make
    make install

    # ODE compilation. Will not work like that need to add a line in  

    cd ../ode-0.12-gaitsym-3.1-clean/
    ./configure --enable-double-precision CFLAGS="-msse" CXXFLAGS="-msse -fpermissive" 
    make
    make install

    # Get ANN library which is not provided
    cd ..
    wget -c https://www.cs.umd.edu/~mount/ANN/Files/1.1.2/ann_1.1.2.tar.gz
    tar xvf ann_1.1.2.tar.gz
    cd ann_1.1.2
    make linux-g++
    mv lib/* /usr/local/lib
    mv include/ANN /usr/local/include

    # Same things for GLUI
    cd ..
    git clone https://github.com/libglui/glui.git
    cd glui
    cmake .
    make
    mkdir -p /usr/local/include/GL/glui
    cp algebra3.h /usr/local/include/GL/glui
    cp include/GL/glui.h /usr/local/include/GL/glui
    cp lib/libglui.a /usr/local/lib
fi    

cd $WORKING_DIR
# Gaitsym compilation
if [ ! -f GaitSym_2015_src.zip ]; then
    wget -c http://www.animalsimulation.org/software/GaitSym/GaitSym_2015_src.zip
fi
if [ ! -d GaitSym_2015_src ]; then
    unzip GaitSym_2015_src.zip
fi

cd GaitSym_2015_src
sed -i 's/shell uname -p/shell uname -m/' makefile
sed -i 's/CXX      = CC/CXX      = mpic++/' makefile
sed -i 's/CC       = cc/CC       = mpicc/' makefile
sed -i 's/-static//' makefile
sed -i 's/LIBS = -L"$(HOME)\/Unix\/lib" -lode -lANN -lxml2 -lpthread -lm -lz/LIBS = -L$(HOME)\/Unix\/lib -lode -lANN -L\/usr\/lib -lxml2 -lpthread -lm -lz -L\/usr\/lib\/openmpi/' makefile

sed -i 's/INC_DIRS\ =\ -I"$(HOME)\/Unix\/include"\ -I\/usr\/include\/libxml2/INC_DIRS\ =\ -I$(HOME)\/Unix\/include\ -I\/usr\/include\/libxml2 -I\/usr\/local\/include\/libxml2 -I\/usr\/include\/GL -I\/usr\/local\/include\/GL/' makefile
make


