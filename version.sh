#!/usr/bin/env bash

#? paragaitdep 0.1.0
#? Copyright (C) 2017 Nicolas Gruel
#? License MIT
#? This is free software: you are free to change and redistribute it.
#? There is NO WARRANTY, to the extent permitted by law.

GCC_VERSION=4.9.4
GCC_MODULEENV=4.9

#OPENMPI_VERSION=1.6.5
#OPENMPI_MODULEENV=1.6

OPENMPI_VERSION=2.1.1
OPENMPI_MODULEENV=2.1

MPI_DIR=/usr
FOAMEXTEND_VERSION=4.0

#METIS_VERSION=5.1.0
#PARMETIS_VERSION=4.0.3
#PARMGRIDEN_VERSION=1.0
#MESQUITE_VERSION=2.1.2
#LIBCCMIO_VERSION=2.6.1
#SCOTCH_VERSION=6.0.4


#[gruel@ruth Docker]$ OPENMPI=FALSE
#[gruel@ruth Docker]$ if [ $OPENMPI = FALSE ]; then echo "toto"; fi
#toto
#[gruel@ruth Docker]$ OPENMPI=TRUE
#[gruel@ruth Docker]$ if [ $OPENMPI = TRUE ]; then echo "toto"; fi
#toto
#[gruel@ruth Docker]$ if [ $OPENMPI = FALSE ]; then echo "toto"; fi
#[gruel@ruth Docker]$
