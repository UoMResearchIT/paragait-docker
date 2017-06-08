#!/usr/bin/env bash

WORKING_DIR=`pwd`

# Installation of system program needed and library

#apt-get install libglu1-mesa-dev libqt5opengl5-dev

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


