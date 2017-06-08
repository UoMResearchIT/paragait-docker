# To build use:
# docker build -t paragait .
FROM ubuntu:17.04
MAINTAINER Nicolas Gruel < nicolas.gruel at manchester.ac.uk>

LABEL description="A linux C++ build environment for Paragait."

RUN apt-get update && apt-get install -y \
  gcc g++ gfortran libopenmpi-dev \
  make \
  git git-svn \
  python-dev \
  zlib1g-dev \
  wget unzip \
  mesa-common-dev freeglut3-dev 

RUN mkdir /Paragait
WORKDIR /Paragait

COPY paragait.sh .
RUN chmod +x paragait.sh
# Je pensais que cela ne se ferait que a la creation mais non cela se fait aussi quand on veut se connecter!
# Pas bon. Cela peut etre contourne a priori par:
# docker run --rm -it paragait bash
#RUN /Paragait/paragait.sh

CMD ["/bin/bash "]
