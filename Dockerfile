# To build use:
# docker build -t paragait-split .
# To start a new container and log into it
# docker run --name paragait-split -i -t paragait-split /bin/bash
FROM ubuntu:17.04
MAINTAINER Nicolas Gruel <nicolas.gruel at manchester.ac.uk>

LABEL description="A linux C++ build environment for Paragait."

RUN apt-get update && apt-get install -y \
  libopenmpi-dev \
  make cmake rpm \
  flex bison \
  gcc g++ gfortran \
  gcc-4.9 g++-4.9 gfortran-4.9 \
  environment-modules \
  git git-svn subversion \
  python-dev \
  zlib1g-dev \
  wget unzip \
  mesa-common-dev freeglut3-dev

RUN mkdir /Paragait
WORKDIR /Paragait

COPY paragait.sh parafem.sh gaitsym.sh foam-extend.sh openfpci.sh version.sh ./
RUN chmod +x paragait.sh parafem.sh gaitsym.sh foam-extend.sh openfpci.sh

# This three line can be removed if you do not want to build and use OpenFPCI.
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 100 --slave /usr/bin/g++ g++ /usr/bin/g++-4.9 --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-4.9
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 50 --slave /usr/bin/g++ g++ /usr/bin/g++-6 --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-6
RUN update-alternatives --set gcc "/usr/bin/gcc-4.9"

# A mettre dans script paragait.
#RUN mkdir -p $HOME/privatemodules/gcc/openmpi/1.6
#RUN . /etc/profile.d/env-modules.sh
#RUN module load use.own
#RUN module load gcc/openmpi/1.6

#RUN apt-get remove -y gcc g++ gfortran gcc-6 g++-6 gfortran-6
#RUN apt-get remove -y libopenmpi-dev
#RUN apt-get autoremove
#RUN ln -s /usr/bin/gcc-4.9 /usr/bin/gcc
#RUN ln -s /usr/bin/g++-4.9 /usr/bin/g++
#RUN ln -s /usr/bin/gfortran-4.9 /usr/bin/gfortran

# Je pensais que cela ne se ferait que a la creation mais non cela se fait aussi quand on veut se connecter!
# Pas bon. Cela peut etre contourne a priori par:
# docker run --rm -it paragait bash
#RUN /Paragait/paragait.sh

CMD ["/bin/bash "]

# Copy openmpi (after removing the system one)
# do a script for it that will be easier
# cd openmpi
# ./autogen.sh #FAILED NEED TO INSTALL AUTOCONF
# ./configure
