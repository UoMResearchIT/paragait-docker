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
    Usage: ${0##*/} [ -d WORKING_DIR ] [ -V ] [ -h ]

       -h display this help and exit
       -d WORKINGDIR  write the result to OUTFILE instead of standard output.
       -V print version of the script
EOF
}

optspec="d:vVh"
while getopts "${optspec}" opt; do
    case ${opt} in
        # for options with required arguments, an additional shift is required
        d )
            WORKING_DIR="${OPTARG}"
            ;;
        v )
            verbose=$((verbose+1))
            ;;
        V ) 
            echo "${version}"
            exit 1
            ;;
        h ) show_help; exit;;

        *) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
    esac
    shift
done

#Define working directory as the one where the script is executed.

if [ -z "$WORKING_DIR" ]; then
    WORKING_DIR=`pwd`
    echo "Working directory: " ${WORKING_DIR}
fi

if [ ! -d $WORKING_DIR ]; then
    mkdir $WORKING_DIR
fi

cd $WORKING_DIR

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

cp examples/5th_ed/p121/demo/p121_demo.mg test/
cd test
../bin/p12meshgen p121_demo
../bin/p121 p121_demo

#######################################################
# GaitSym compilation and installation from source code
#######################################################

# Install lib and header in $HOME/Unix if not root (ie docker)
if [ ! "$(whoami)" == "root" ]; then
    INSTALL_DEP=${HOME}/Unix    # Use Unix which is Gaitsym choice
    mkdir -p $INSTALL_DEP/bin
    mkdir -p $INSTALL_DEP/lib
    mkdir -p $INSTALL_DEP/include
    export PATH=$PATH:$INSTALL_DEP/lib
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$INSTALL_DEP/lib
    echo "Add the path ${INSTALL_DEP}/lib in you LD_LIBRARY_PATH variable"
else
    INSTALL_DEP=/usr/local
fi


# Go back to working directory
cd $WORKING_DIR

# Use the official version 2015

# Compile the prerequisites
if [ ! -f GaitSym_2015_dep.zip ]; then
    wget -c http://www.animalsimulation.org/software/GaitSym/GaitSym_2015_dep.zip
fi

if [ ! -d GaitSym_2015_dep ]; then
    unzip GaitSym_2015_dep.zip
    cd GaitSym_2015_dep

    for i in $( ls ); 
        do tar xvf $i; 
    done

    # libxml2
    cd libxml2-2.9.1
    ./configure --prefix=$INSTALL_DEP
    make
    make install

    # ODE compilation. Will not work like that need to add a line in  

    cd ../ode-0.12-gaitsym-3.1-clean/
    ./configure --enable-double-precision CFLAGS="-msse" CXXFLAGS="-msse -fpermissive" --prefix=$INSTALL_DEP
    make
    make install

    # Get ANN library which is not provided
    cd ..
    wget -c https://www.cs.umd.edu/~mount/ANN/Files/1.1.2/ann_1.1.2.tar.gz
    tar xvf ann_1.1.2.tar.gz
    cd ann_1.1.2
    make linux-g++
    mv lib/* $INSTALL_DEP/lib
    mv include/ANN $INSTALL_DEP/include

    # Same things for GLUI
    cd ..
    git clone https://github.com/libglui/glui.git
    cd glui
    cmake .
    make
    mkdir -p $INSTALL_DEP/include/GL/glui
    cp algebra3.h $INSTALL_DEP/include/GL/glui
    cp include/GL/glui.h $INSTALL_DEP/include/GL/glui
    cp lib/libglui.a $INSTALL_DEP/lib
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
cp makefile makefile.orig

sed -i 's/shell uname -p/shell uname -m/' makefile
sed -i 's/CXX      = CC/CXX      = mpic++/' makefile
sed -i 's/CC       = cc/CC       = mpicc/' makefile
sed -i 's/-static//' makefile
sed -i 's/LIBS = -L"$(HOME)\/Unix\/lib" -lode -lANN -lxml2 -lpthread -lm -lz/LIBS = -L'"${INSTALL_DEP//\//\\/}"'\/lib -lode -lANN -L\/usr\/lib -lxml2 -lpthread -lm -lz -L\/usr\/lib\/openmpi/' makefile

sed -i 's/INC_DIRS\ =\ -I"$(HOME)\/Unix\/include"\ -I\/usr\/include\/libxml2/INC_DIRS\ =\ -I'"${INSTALL_DEP//\//\\/}"'\/include\ -I'"${INSTALL_DEP//\//\\/}"'\/include\/GL\ -I\/usr\/include\/libxml2 -I\/usr\/local\/include\/libxml2 -I\/usr\/include\/GL/' makefile
make

# Clean directory
cd $WORKING_DIR
rm -rf __MACOSX

