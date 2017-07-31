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

optspec="vVhd:l:"
while getopts "${optspec}" opt; do
    case ${opt} in
        # for options with required arguments, an additional shift is required
        d )
            WORKING_DIR="${OPTARG}"
            ;;
	l )
	    LOGFILE="${OPTARG}"
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
done

#Define working directory as the one where the script is executed.

if [ -z "${WORKING_DIR}" ]; then
    WORKING_DIR=`pwd`
    echo "Working directory: " ${WORKING_DIR}
fi

if [ ! -d $WORKING_DIR ]; then
    mkdir $WORKING_DIR
fi

if [ -z "${LOGFILE}" ]; then
    LOGFILE=`echo $0 | sed 's/.sh/.log/'`
    logfile=$WORKING_DIR/$LOGFILE
else
    logfile=$LOGFILE
fi

if [ ! -f $logfile ]; then
    echo "working directory: " $WORKING_DIR > $logfile
fi

#######################################################
# GaitSym compilation and installation from source code
#######################################################

echo "Start Gaitsym compilation" 
echo "Start Gaitsym compilation" >> $logfile

cd $WORKING_DIR

# Install lib and header in $HOME/Unix if not root (ie docker)
if [ ! "$(whoami)" == "root" ]; then
    INSTALL_DEP=${HOME}/Unix    # Use Unix which is Gaitsym choice
    mkdir -p $INSTALL_DEP/bin
    mkdir -p $INSTALL_DEP/lib
    mkdir -p $INSTALL_DEP/include
    export PATH=$PATH:$INSTALL_DEP/lib
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$INSTALL_DEP/lib
    echo "Add the path ${INSTALL_DEP}/lib in you LD_LIBRARY_PATH variable" >> $logfile
else
    INSTALL_DEP=/usr/local
fi

echo "Gaitsym dependencies path:" $INSTALL_DEP >> $logfile

# Use the official version 2015

# Compile the prerequisites
if [ ! -f GaitSym_2015_dep.zip ]; then
    echo "Download Gaitsym dependencies file" >> $logfile
    wget -c http://www.animalsimulation.org/software/GaitSym/GaitSym_2015_dep.zip >> $logfile 2>&1  
fi

if [ ! -d GaitSym_2015_dep ]; then
    echo "Compiling and installing dependencies" >> $logfile
    unzip GaitSym_2015_dep.zip >> $logfile 2>&1  
    cd GaitSym_2015_dep

    for i in $( ls ); 
        do tar xvf $i >> $logfile 2>&1  ; 
    done

    # libxml2
    echo "Install libxml2 library." >> $logfile
    cd libxml2-2.9.1
    ./configure --prefix=$INSTALL_DEP >> $logfile 2>&1  
    make >> $logfile 2>&1  
    make install >> $logfile 2>&1  

    # ODE compilation. Will not work like that need to add a line in  
    echo "Install ODE library modified for Gaitsym." >> $logfile
    cd ../ode-0.12-gaitsym-3.1-clean/
    ./configure --enable-double-precision CFLAGS="-msse" CXXFLAGS="-msse -fpermissive" --prefix=$INSTALL_DEP >> $logfile 2>&1  
    make >> $logfile 2>&1  
    make install >> $logfile 2>&1  

    # Get ANN library which is not provided
    echo "Donwload and Install ANN library." >> $logfile
    echo "(missing from Gaitsym required dependencies file)" >> $logfile
    cd ..
    wget -c https://www.cs.umd.edu/~mount/ANN/Files/1.1.2/ann_1.1.2.tar.gz >> $logfile 2>&1  
    tar xvf ann_1.1.2.tar.gz >> $logfile 2>&1   
    cd ann_1.1.2
    make linux-g++ >> $logfile 2>&1  
    mv lib/* $INSTALL_DEP/lib/
    mkdir -p $INSTALL_DEP/include/ANN
    mv include/ANN/* $INSTALL_DEP/include/ANN/

    # Same things for GLUI
    echo "Donwload and Install GLUI library." >> $logfile
    echo "(missing from Gaitsym required dependencies file)" >> $logfile
    cd ..
    git clone https://github.com/libglui/glui.git >> $logfile 2>&1  
    cd glui
    cmake . >> $logfile 2>&1  
    make >> $logfile 2>&1  
    mkdir -p $INSTALL_DEP/include/GL/glui
    cp algebra3.h $INSTALL_DEP/include/GL/glui
    cp include/GL/glui.h $INSTALL_DEP/include/GL/glui
    cp lib/libglui.a $INSTALL_DEP/lib
fi    

cd $WORKING_DIR
# Gaitsym compilation
if [ ! -f GaitSym_2015_src.zip ]; then
    echo "Download Gaitsym source code" >> $logfile 
    wget -c http://www.animalsimulation.org/software/GaitSym/GaitSym_2015_src.zip >> $logfile 2>&1  
fi

echo "Compile Gaitsym"
if [ ! -d GaitSym_2015_src ]; then
    unzip GaitSym_2015_src.zip >> $logfile 2>&1  
    rm -rf __MACOSX
    cd $WORKING_DIR/GaitSym_2015_src
    echo "modify Gaitsym makefile" >> $logfile
    cp makefile makefile.orig
    sed -i 's/shell uname -p/shell uname -m/' makefile
    sed -i 's/CXX      = CC/CXX      = mpic++/' makefile
    sed -i 's/CC       = cc/CC       = mpicc/' makefile
    sed -i 's/-static//' makefile
    sed -i 's/LIBS = -L"$(HOME)\/Unix\/lib" -lode -lANN -lxml2 -lpthread -lm -lz/LIBS = -L'"${INSTALL_DEP//\//\\/}"'\/lib -lode -lANN -L\/usr\/lib -lxml2 -lpthread -lm -lz -L\/usr\/lib\/openmpi/' makefile
    sed -i 's/INC_DIRS\ =\ -I"$(HOME)\/Unix\/include"\ -I\/usr\/include\/libxml2/INC_DIRS\ =\ -I'"${INSTALL_DEP//\//\\/}"'\/include\ -I'"${INSTALL_DEP//\//\\/}"'\/include\/GL\ -I\/usr\/include\/libxml2 -I\/usr\/local\/include\/libxml2 -I\/usr\/include\/GL/' makefile
    make >> $logfile 2>&1  
else
    cd $WORKING_DIR/GaitSym_2015_src
    make >> $logfile 2>&1  
fi

# Clean directory
cd $WORKING_DIR
