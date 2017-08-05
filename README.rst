paragait-docker
===============

Repository to create a docker image and the installation script
to compile paragait and all the dependencies.

Continuous integration with Travis CI
-------------------------------------

`Travis <https://travis-ci.org/gruel/paragait-docker/builds>`_

Requirement
-----------

-  `Docker <https://www.docker.com/>`_ for linux

Download the code
-----------------

::

        git clone https://github.com/UoMResearchIT/paragait-docker

How-To
------

When Docker is installed go to the previous repository::

        cd paragait-docker

build the docker image::

        docker build -t paragait .

Start the container from the latest paragait image, give it the name
paragait and log into a bash shell::

        docker run --name paragait -i -t paragait:latest /bin/bash

Run the installation script which should be in the directory::

        ./paragait.sh

Access a container after leaving it
-----------------------------------

List the available containers::

        docker ps -a

The list will be something like:

+---------------+--------+----------+----------+----------+---------+--------+
| CONTAINER ID  | IMAGE  | COMMAND  | CREATED  | STATUS   | PORTS   | NAMES  |
+===============+========+==========+==========+==========+=========+========+
| ed56e6355086  | paraga | "/bin/ba | 4        | Exited   |         | paraga |
|               | it:lat | sh"      | seconds  | (0) 1    |         | it     |
|               | est    |          | ago      | second   |         |        |
|               |        |          |          | ago      |         |        |
+---------------+--------+----------+----------+----------+---------+--------+
| bb020705acab  | paraga | "/bin/ba | 2 hours  | Up 39    |         | paraga |
|               | it:lat | sh"      | ago      | minutes  |         | it0.5  |
|               | est    |          |          |          |         |        |
+---------------+--------+----------+----------+----------+---------+--------+
| da76eeec88d7  | a721e4 | "/bin/ba | 5 days   | Exited   |         | paraga |
|               | 41a9e0 | sh"      | ago      | (0) 4    |         | it0.4  |
|               |        |          |          | days ago |         |        |
+---------------+--------+----------+----------+----------+---------+--------+
| 57fa0423d5e8  | 99641c | "/bin/ba | 5 days   | Exited   |         | paraga |
|               | 22a35c | sh"      | ago      | (0) 5    |         | it0.3  |
|               |        |          |          | days ago |         |        |
+---------------+--------+----------+----------+----------+---------+--------+
| 9c1dccb36ee7  | 99641c | "/bin/ba | 5 days   | Exited   |         | paraga |
|               | 22a35c | sh"      | ago      | (0) 5    |         | it0.2  |
|               |        |          |          | days ago |         |        |
+---------------+--------+----------+----------+----------+---------+--------+
| 1bc31ba3794d  | 99641c | "/bin/ba | 6 days   | Exited   |         | paraga |
|               | 22a35c | sh"      | ago      | (0) 5    |         | it0.1  |
|               |        |          |          | days ago |         |        |
+---------------+--------+----------+----------+----------+---------+--------+

Start the container you want to interact with::

        docker start paragait

and log into it::

        docker attach paragait

When log on the docker image, you can run every script individually or
use the convenient script ``paragait.sh`` which will run the following

1. parafem.sh
2. gaitsym.sh (NOT WORKING YET)
3. foam-extend.sh
4. openfpci.sh

.. note::

   To compile openFPCI, you have to use gcc<6.0 (FSI, a library needed by the project does not compile 
   with gcc>=6.0). 
   To realise that, the docker image is configured to use gcc4.9. Depending on your distribution or system
   different possibilities to achieve it are available:
    
      - on ubuntu the best way is to use the `update-alternative` 
      
      - on archlinux, you have to install gcc5 and modify the gcc, g++ and gfortran executable to use gcc5 
        (be careful to save the original version to be able to put back the system in its default state)
      
      - On HPC, use the `module env` system. E.g. ::

          module load gcc/4.9
     
