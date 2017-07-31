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
    Usage: ${0##*/} [ -d WORKING_DIR ] [ -l LOGFILE ] [ -V ] [ -h ]

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


#READ common variable
source version.sh

echo "Start OpenFPCI compilation"
echo "Start OpenFPCI compilation" >> $logfile


PARAFEM_DIR=$WORKING_DIR/parafem-code/parafem

if [ ! -d $PARAFEM_DIR ]; then
    echo "Parafem not present please install it"
    exit 1
fi

############################################################
# Compilation and Installation of OpenFPCI requirement (FSI)
############################################################

# A Fluid Structure Interaction library which contains a framework
# for easy implementation of new structural models.
# Installations step from:
# https://openfoamwiki.net/index.php/Extend-bazaar/Toolkits/Fluid-structure_interaction#Install_on_foam-extend-4.0

cd $HOME/foam/foam-extend-$FOAMEXTEND_VERSION
source etc/bashrc

echo "Fsi Compilation and Installation" >> $logfile
mkdir -p $WM_PROJECT_USER_DIR
cd $WM_PROJECT_USER_DIR

if [ ! -f Fsi_40.tar.gz ]; then
    wget -c https://openfoamwiki.net/images/d/d6/Fsi_40.tar.gz >> $logfile 2>&1
fi

if [ ! -d FluidSolidInteraction ]; then
    tar -xzf Fsi_40.tar.gz >> $logfile 2>&1
fi

# build the Toolkit
cd FluidSolidInteraction/src
./Allwmake >> $logfile 2>&1

#######################################
# OpenFPCI compilation and installation
#######################################

cd  $WM_PROJECT_USER_DIR/FluidSolidInteraction/src/fluidSolidInteraction/solidSolvers

if [ ! -d OpenFPCI ]; then
    git clone git://github.com/SPHewitt/OpenFPCI.git
    ln -s OpenFPCI/paraFEM .
    OPENMPI_LINK_FLAGS="`mpicc --showme:link`"
    echo "solidSolvers/paraFEM/DyParaFEMSolid.C" > paraFEM.files
    echo "solidSolvers/paraFEM/DyParaFEMSolidSolve.C" >> paraFEM.files
    echo "solidSolvers/paraFEM/fortranRest.C" >> paraFEM.files
    echo "" >> paraFEM.files
    cat paraFEM.files $WM_PROJECT_USER_DIR/FluidSolidInteraction/src/fluidSolidInteraction/Make/files > tmp.files
    mv tmp.files $WM_PROJECT_USER_DIR/FluidSolidInteraction/src/fluidSolidInteraction/Make/files

    sed -i 's/EXE_LIBS = /EXE_LIBS = \\ \n    ..\/..\/fluidSolidInteraction\/solidSolvers\/paraFEM\/dyparafemsubroutines.o -L\/'"${PARAFEM_DIR//\//\\/}"'\/lib -lParaFEM_mpi.5.0.3  -L\/'"${PARAFEM_DIR//\//\\/}"'\/lib -larpack_linuxdesktop -lgfortran '"${OPENMPI_LINK_FLAGS//\//\\/}"' -lmpi/'  $WM_PROJECT_USER_DIR/FluidSolidInteraction/src/fluidSolidInteraction/Make/options
else
    cd OpenFPCI
    git pull >> $logfile 2>&1
fi

cd $WM_PROJECT_USER_DIR/FluidSolidInteraction/src/fluidSolidInteraction/solidSolvers/paraFEM
gfortran -v >> $logfile 2>&1
gfortran -fcheck=all -c dyparafemsubroutines.f90 -o dyparafemsubroutines.o -I${PARAFEM_DIR}/include/mpi >> $logfile 2>&1
cd ../../..
./Allwmake >> $logfile 2>&1
