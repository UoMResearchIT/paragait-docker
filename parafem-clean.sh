#!/usr/bin/env bash


#? paragait 0.1.0
#? Copyright (C) 2017 Nicolas Gruel
#? License MIT
#? This is free software: you are free to change and redistribute it.
#? There is NO WARRANTY, to the extent permitted by law.

version=$(grep "^#?"  "$0" | cut -c 4-)

# Usage info
show_help() {
    cat << EOF
    Usage: ${0##*/} [ -d WORKING_DIR ] [ -V ] [ -h ]

       -h              display this help and exit
       -d WORKING_DIR  write the result to OUTFILE instead of standard output.
       -l LOGFILE      Name of the logfile 
       -V              print version of the script
EOF
}

optspec="vVhd:l:"
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
        h ) show_help
            exit;;
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

if [ -d parafem-code ]; then
    cd $WORKING_DIR/parafem-code/parafem 
    find . -type f \( -name "*.o" \) -exec rm {} \;
    find . -type f \( -name "*.mod" \) -exec rm {} \;
    find . -type f \( -name "*.a" \) -exec rm {} \;
    rm -f bin/* lib/*
fi

