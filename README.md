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


## 16 (docker-3)
* describe and build Docker images for a service application;
* optimize work with Docker images;
* launch and operation of the application based on Docker images;
* ease of running containers using docker run;
* redefined ENV via docker run;
* optimized container size (Alpine based image).

The work was carried out in the src directory, where there is a separate directory for each service (comment, post-py, ui). For MongoDB, I used an image from Docker Hub.

Changes have been made as per hadolint guidelines:
### docker-mono/Dockerfile Example
RUN apt-get update -qq && apt-get install -y build-essential
=>
RUN apt-get update -qq && apt-get install -y build-essential --no-install-recommends \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ADD Gemfile* $APP_HOME/
=>
COPY Gemfile* $APP_HOME/

ADD . $APP_HOME
=>
COPY . $APP_HOME

For convenience, our containers used network aliases (there is a reference to them in ENV). Since aliases are not available on the default network, it was necessary to create a separate bridge network.
```bash
$ docker network create reddit
$ docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
$ docker run -d --network=reddit --network-alias=post ivandebian/post:1.0
$ docker run -d --network=reddit --network-alias=comment ivandebian/comment:1.0
$ docker run -d --network=reddit -p 9292:9292 ivandebian/ui:1.0
```
The addresses for container interaction are set via ENV variables inside Dockerfiles.
We can override ENV using the -e flag OR aliasses via env.list file: 

```bash
$ docker run -d --network=reddit --network-alias=post_db2 --network-alias=comment_db2 mongo:latest

$ docker run -d --network=reddit --network-alias=post2 -e POST_DATABASE_HOST=post_db2 weisdd/post:1.0

$ docker run -d --network=reddit --network-alias=comment2 -e COMMENT_DATABASE_HOST=comment_db2 weisdd/comment:1.0

$ docker run -d --network=reddit -p 9292:9292 -e POST_SERVICE_HOST=post2 -e COMMENT_SERVICE_HOST=comment2 weisdd/ui:1.0
```

To optimize the image I used https://hadolint.github.io/hadolint/


## Running on local machine
* Run docker-machine on local machine in Virtualbox
  - `docker-machine create --driver virtualbox default`
  - ```bash
    docker-machine env default
    export DOCKER_TLS_VERIFY="1"
    export DOCKER_HOST="tcp://192.168.99.99:2376"
    export DOCKER_CERT_PATH="/home/ivan/.docker/machine/machines/default"
    export DOCKER_MACHINE_NAME="default"
    # Run this command to configure your shell: 
    # eval $(docker-machine env default)
    ```
* Connect by ssh `docker-machine ssh default`


## 17 (docker-3)
Let's start the container using the none-driver.
> docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig
```cmd
lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```
Let's start the container in the network space of the docker-host
> docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig
```cmd
docker0   Link encap:Ethernet  HWaddr 02:42:07:E1:E1:9B  
          inet addr:172.17.0.1  Bcast:172.17.255.255  Mask:255.255.0.0
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

ens4      Link encap:Ethernet  HWaddr 42:01:0A:84:00:0D  
          inet addr:10.132.0.13  Bcast:10.132.0.13  Mask:255.255.255.255
          inet6 addr: fe80::4001:aff:fe84:d%32599/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1460  Metric:1
          RX packets:1652 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1586 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:8088302 (7.7 MiB)  TX bytes:226618 (221.3 KiB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1%32599/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```
Let's run it several times (2-4)
> docker run --network host -d nginx

Only one container starts. Because the port is busy

> sudo ln -s /var/run/docker/netns /var/run/netns
> sudo ip netns

* default
Thus, we can view the currently existing net-namespaces

Create docker networks
> docker network create back_net --subnet=10.0.2.0/24

> docker network create front_net --subnet=10.0.1.0/24

```docker
docker run -d --network=front_net -p 9292:9292 --name ui ivandebian/ui:1.0 && \
docker run -d --network=back_net --network-alias=comment ivandebian/comment:1.0 && \
docker run -d --network=back_net --network-alias=post ivandebian/post:1.0 && \
docker run -d --network=back_net --network-alias=post_db --network-alias=comment_db mongo:latest
```
Docker, when initializing a container, can only connect 1 to it
network. Therefore, you need to place containers post and comment on both networks.
```docker
docker network connect front_net post
docker network connect front_net comment
```

Stopping old copies of containers
> docker kill $(docker ps -q)

* Docker-compose

Installing Docker-compose in ubuntu & debian
 ```bash
 sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
 ```
 ```bash
 export USERNAME=ivandebian
 docker-compose up -d
 docker-compose ps
 ```

 1. The project name can be set via the `container_name` parameter in docker-compose.yml
 ```yaml
 container_name: name
 ```

 2. The project name can be set via the `project_name` parameter in docker-compose.yml

 3. Add variable COMPOSE_PROJECT_NAME = project_name
 4. Run with the -p switch `docker-compose project_name up -d`