#!/usr/bin/env bash

# Script to define the compiling environment for some known environment

#? paragaitdep 0.1.0
#? Copyright (C) 2017 Nicolas Gruel
#? License MIT
#? This is free software: you are free to change and redistribute it.
#? There is NO WARRANTY, to the extent permitted by law.

version=$(grep "^#?"  "$0" | cut -c 4-)

# Usage info
show_help() {
    cat << EOF
    Usage: ${0##*/} [ -n NAME ] [ -l LOGFILE ] [ -V ] [ -h ]

       -h display this help and exit
       -n NAME of the computer
       -V print version of the script
EOF
}

optspec="n:Vhl:"
while getopts "${optspec}" opt; do
    case ${opt} in
        # for options with required arguments, an additional shift is required
        n )
            NAME="${OPTARG}"
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

# Set logfile
if [ -z "${LOGFILE}" ]; then
    LOGFILE=`echo $0 | sed 's/.sh/.log/'`
    logfile=$WORKING_DIR/$LOGFILE
else
    logfile=$LOGFILE
fi

if [ -f version.sh ]; then
    source version.sh
fi

case $NAME in
    docker )
        # Compiler should be gcc-4.9 (for OpenFPCI)
        GCC_V=`gcc --version | grep ^gcc | awk '{print $3}' | cut -d. -f1-2`
        TEST_V=`echo $GCC_V'>'6 | bc -l`
        if [ "$TEST_V" ]; then
            echo "Too recent version of GCC (Should be <6)"
            #exit 1
        fi
        #source openmpi.sh;
        ;;
    csf )
        module load compilers/gcc/4.9.0;
        module load gcc/openmpi/$OPENMPI_MODULEENV
        ;;
    arch )
        source openmpi.sh
        ;;
esac


