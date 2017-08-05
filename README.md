# paragait-docker

Repository to create a docker image and the installation script
to compile paragait and all the dependencies.

## Continuous integration with Travis CI

https://travis-ci.org/gruel/paragait-docker/builds

## Requirement

- [Docker](https://www.docker.com/) for linux 

## Download the code

  ```bash
  git clone https://github.com/UoMResearchIT/paragait-docker
  ```

## How-To

When Docker is installed go to the previous repository:

  ```bash
  cd paragait-docker
  ```

build the docker image:

  ```bash
  docker build -t paragait .
  ```

Start the container from the latest paragait image, give it the name paragait and log into a bash shell:

  ```bash
  docker run --name paragait -i -t paragait:latest /bin/bash
  ```
  
Run the installation script which should be in the directory:

  ```bash
  ./paragait.sh
  ```

## Access a container after leaving it

List the available containers:

  ```bash
  docker ps -a
  ```

The list will be something like:

CONTAINER ID | IMAGE | COMMAND | CREATED | STATUS  | PORTS | NAMES
------------ | ----- | ------- | ------- | ------- | ------| -----
ed56e6355086    |    paragait:latest  |   "/bin/bash"    |      4 seconds ago  |     Exited (0) 1 second ago   |     |  paragait
bb020705acab    |    paragait:latest  |   "/bin/bash"    |      2 hours ago    |     Up 39 minutes             |     |  paragait0.5
da76eeec88d7    |    a721e441a9e0     |    "/bin/bash"   |      5 days ago     |     Exited (0) 4 days ago     |     |  paragait0.4
57fa0423d5e8    |    99641c22a35c     |    "/bin/bash"   |      5 days ago     |     Exited (0) 5 days ago     |     |  paragait0.3
9c1dccb36ee7    |    99641c22a35c     |    "/bin/bash"   |      5 days ago     |     Exited (0) 5 days ago     |     |  paragait0.2
1bc31ba3794d    |    99641c22a35c     |    "/bin/bash"   |      6 days ago     |     Exited (0) 5 days ago     |     |  paragait0.1

Start the container you want to interact with:

  ```bash
  docker start paragait
  ```
  
and log into it:

  ```bash
  docker attach paragait
  ```
 
When log on the docker image, you can run every script individually or 
use the convenient script `paragait.sh` which will run the following 

1. parafem.sh 
2. gaitsym.sh (NOE WORKING YET)
3. foam-extend.sh
4. openfpci.sh 
