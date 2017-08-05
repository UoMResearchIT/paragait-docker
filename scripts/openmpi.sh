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
    Usage: ${0##*/} [ -d WORKING_DIR ] [ -v OPENMPI_VERSION ] [ -l LOGFILE ] [ -V ] [ -h ]

       -d WORKINGDIR  write the result to OUTFILE instead of standard output.
       -h display this help and exit
       -v OPENMPI_VERSION OpenMPI version to compile and install
       -V print version of the script
EOF
}

optspec="v:Vhl:"
while getopts "${optspec}" opt; do
    case ${opt} in
        # for options with required arguments, an additional shift is required
        v )
            OPENMPI_VERSION="${OPTARG}"
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

if [ -z "${OPENMPI_VERSION}" ]; then
    OPENMPI_VERSION=2.1.1
    OPENMPI_MODULEENV=2.1
    echo "OpenMPI version " $OPENMPI_VERSION
fi

if [ ! -f $logfile ]; then
    echo "OpenMPI version compilation: " $OPENMPI_VERSION > $logfile
fi

if [ ! -f openmpi-$OPENMPI_VERSION.tar.bz2 ]; then
    wget -c https://www.open-mpi.org/software/ompi/v$OPENMPI_MODULEENV/downloads/openmpi-$OPENMPI_VERSION.tar.bz2
fi

if [ ! -d openmpi-$OPENMPI_VERSION ]; then
    tar xvf openmpi-$OPENMPI_VERSION.tar.bz2
fi

cd openmpi-$OPENMPI_VERSION
./configure --prefix=$HOME/mpi/gcc/openmpi/$OPENMPI_MODULEENV
make 
make install
cd ..

#GCC_VERSION=gcc --version | grep ^gcc | awk '{print $3}' | cut -d. -f1-3

# Install module file for that version of openmpi in $HOME/
OPENMPI_ENV_DIR=$HOME/privatemodules/mpi/gcc/openmpi/
mkdir -p $OPENMPI_ENV_DIR
cp openmpi.modenv $OPENMPI_ENV_DIR/$OPENMPI_MODULEENV
sed -i 's/OPENMPI_VERSION/'"${OPENMPI_MODULEENV//\//\\/}"'/' $OPENMPI_ENV_DIR/$OPENMPI_MODULEENV

# Read openmpi
module del use.own mpi/gcc/openmpi/$OPENMPI_MODULEENV
module load use.own mpi/gcc/openmpi/$OPENMPI_MODULEENV
