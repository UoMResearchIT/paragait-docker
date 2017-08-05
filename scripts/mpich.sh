#!/usr/bin/env bash

# Script to compile and install specific version of openmpi

#? paragaitdep 0.1.0
#? Copyright (C) 2017 Nicolas Gruel
#? License MIT
#? This is free software: you are free to change and redistribute it.
#? There is NO WARRANTY, to the extent permitted by law.

version=$(grep "^#?"  "$0" | cut -c 4-)

# Usage info
show_help() {
    cat << EOF
    Usage: ${0##*/} [ -d WORKING_DIR ] [ -v MPICH_VERSION ] [ -l LOGFILE ] [ -V ] [ -h ]

       -d WORKINGDIR  write the result to OUTFILE instead of standard output.
       -h display this help and exit
       -v MPICH_VERSION OpenMPI version to compile and install
       -V print version of the script
EOF
}

optspec="v:Vhl:"
while getopts "${optspec}" opt; do
    case ${opt} in
        # for options with required arguments, an additional shift is required
        v )
            MPICH_VERSION="${OPTARG}"
            ;;
	    l )
            LOGFILE="${OPTARG}"
            ;;
        V ) 
            echo "${version}"
            exit 1
            ;;
        h ) show_help; exit;;

        *) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
    esac
done

if [ -z "${WORKING_DIR}" ]; then
    WORKING_DIR=`pwd`
    echo "Working directory: " ${WORKING_DIR}
fi

# Set logfile
if [ -z "${LOGFILE}" ]; then
    LOGFILE=`echo $0 | sed 's/.sh/.log/'`
    logfile=$WORKING_DIR/$LOGFILE
else
    logfile=$LOGFILE
fi

if [ -z "${MPICH_VERSION}" ]; then
    MPICH_VERSION=3.2
    MPICH_MODULEENV=3.2
    echo "MPICH version " $MPICH_VERSION
fi

if [ ! -f $logfile ]; then
    echo "MPICH version compilation: " $MPICH_VERSION > $logfile
fi

if [ ! -f mpich-$MPICH_VERSION.tar.bz2 ]; then
    wget -c http://www.mpich.org/static/downloads/$MPICH_VERSION/mpich-$MPICH_VERSION.tar.gz
fi

if [ ! -d mpich-$MPICH_VERSION ]; then
    tar xvf mpich-$MPICH_VERSION.tar.bz2
fi

cd mpich-$MPICH_VERSION
./configure --prefix=$HOME/mpi/gcc/mpich/$MPICH_MODULEENV
make 
make install
cd ..

#GCC_VERSION=gcc --version | grep ^gcc | awk '{print $3}' | cut -d. -f1-3

# Install module file for that version of openmpi in $HOME/
MPICH_ENV_DIR=$HOME/privatemodules/mpi/gcc/mpich/
mkdir -p $MPICH_ENV_DIR
cp mpich.modenv $MPICH_ENV_DIR/$MPICH_MODULEENV
sed -i 's/MPICH_VERSION/'"${MPICH_MODULEENV//\//\\/}"'/' $MPICH_ENV_DIR/$MPICH_MODULEENV

# Read openmpi
module del use.own mpi/gcc/mpich/$MPICH_MODULEENV
module load use.own mpi/gcc/mpich/$MPICH_MODULEENV
