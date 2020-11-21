## 14 (docker)
* docker, docker-compose, docker-machine;

### Usefull clmmands:
```
$ docker info - information about docker (including the number of containers, images, etc.).
$ docker images - list of all images.
$ docker ps - list of currently running containers.
$ docker ps -a - list of all containers, incl. stopped.
$ docker system df - information about disk space (containers, images, etc.).
$ docker inspect <id> - Details of the docker object.
$ docker run hello-world - Runs the hello-world container. Can serve as a docker health test.
$ docker run -it ubuntu:16.04 /bin/bash - is an example of how you can create and run a container and then go to the terminal.
    -i - start container in foreground-mode (docker attach).
    -d - start the container in the background.
    -t - Create TTY.
Example:
* docker run -it ubuntu:16:04 bash
* docker run -dt nginx:latest
```

Important points:
* if the --rm flag is not specified, then after the shutdown container will remain on the disk;
* docker run starts a new container every time;
* docker run = docker create + docker start;

```
$ docker start <u_container_id> - starts a stopped container.
$ docker attach <u_container_id> -  connection of an already created container to the terminal.

$ docker exec <u_container_id> <command> - start a new process inside the container.
Example:
docker exec -it <u_container_id> bash

$ docker commit <u_container_id> <name> - create an image from a container.

$ docker kill <u_container_id> - send SIGKILL.
$ docker stop <u_container_id> - send SIGTERM, затем (через 10 секунд) SIGKILL.
Example:
docker kill $(docker ps -q) - kills all running containers.

$ docker rm <u_container_id> - delete container (must be stopped).
    -f - allows you to remove a running container (pre-sent SIGKILL).
Example:
$ docker rm $(docker ps -a -q) - removes all containers that are not running.

$ docker rmi - remove image if running containers do not depend on it.
```

## 15 (docker)
* docker host, Dockerfile;
* published Dockerfile on Docker Hub; (ivandebian/reddit:1.0)
* applicarion deployment automation protorype in a bundle Packer + Ansible Terraform.

### Docker machine
Create a host with docker in GCP using docker-machine:
  ```bash
  export GOOGLE_PROJECT=my_project
  ```
  ```bash
  $ docker-machine create --driver google \
  --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
  --google-machine-type f1-micro \
  --google-zone europe-west1-b docker-host
  ```

Switch to remote docker (all docker commands will be executed on the remote host):
  ```bash
  eval $(docker-machine env <имя>)
  ```

Switching to local docker:
  ```bash
  eval $(docker-machine env --unset)
  ```

Removal:
  ```bash
  docker-machine rm <имя>
  ```

### Preparing the Dockerfile
For a complete description of the container, we need the following files:
*Dockerfile
*mongod.conf
*db_config
*start.sh

Create image from Dockerfile: (docker-mono/Dockerfile)
```bash
$ docker build -t reddit:latest .
```
    -t - tag for the built image;

Running a container based on image:
```bash
$ sudo docker run --name reddit -d --network=host reddit:latestb599f36debf988fe01d919ca4e149153b1fb0c1808378ab528773875c825eecb
$ docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                        SWARM   DOCKER      ERRORS
docker-host   -        google   Running   tcp://35.195.30.236:2376           v19.03.13
```

### Docker hub
After registering on docker hub, we perform authentication:
$ docker login

Publishing the image to docker hub:
```bash
$ docker tag reddit:latest ivandebian/reddit:1.0
$ sudo docker push ivandebian/reddit:1.0
The push refers to repository [docker.io/ivandebian/reddit]
16c7ee0fefdc: Layer already exists 
2ac0a4e09a94: Pushed 
b0e0b2fd9007: Layer already exists 
c0d47dfd09ab: Pushed 
893039e3b135: Pushed 
9343907ef64e: Pushed 
305af4ebc386: Pushed 
1e7c8a60ad3f: Pushed 
ae91e13500ea: Pushed 
9edaa71ce233: Layer already exists 
62fdddf6a67c: Layer already exists 
eff16de3ff64: Layer already exists 
61727f5e6796: Layer already exists 
1.0: digest: sha256:7bee59150ade7aed3da722bbc96cbf786bfcfa895a7e4a105bc698703762b6f7 size: 3035
```

### Useful commands
Checking which command the container will run with:
```bash
$ docker inspect ivandebian/reddit:1.0 -f '{{.ContainerConfig.Cmd}}'
```

List of changes in the FS since the start of the container:
```bash
$ docker diff reddit
```
