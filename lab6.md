author: Arun Tiwari
summary: Docker Workshop 
id: lab6
layout: page
title: "Docker Workshop"
permalink: /labs/docker-beginner
categories: codelab,markdown
environments: Web
status: Published
feedback link: https://github.com/arunstiwari/docker-workshop-lab
analytics account: Google Analytics ID

# Docker Compose    

## Docker Compose Introduction 
Duration: 0:07:00
### Introduction
1. Imagine you are developing an online shop with frontend, backend, payment, and ordering microservices.
2. Each microservice is implemented with the most appropriate programming language before being built, packaged and configured. 
3. Complex applications are designed to run in separate containers in the  Docker ecosystem.
4. Different containers require multiple `Dockerfiles` to define `Docker images` 
5. They also need complex commands to configure, run and troubleshoot applications. 
6. All this can be achieved using `Docker compose`, a tool for defining and managing applications in multiple containers.
7. Complex applications such as YAML files can be configured and run with a single command in Docker Compose.
8. It is suitable for various environments, including development, testing, Continuous Integration (CI) pipelines and production. 

### Docker Compose Features 
1. Isolation 
   1. It allows us to run multiple instances of your complex application in complete isolation
   2. This feature makes it much easier to run multiple copies of the same application stack on developer machines, CI servers, or shared hosts. 
   3. Therefore, sharing resources increases utilization while decreasing operational complexity. 
2. Stateful Data management
   1. It manages the volumes of your containers so that they do not lose their data from previous runs 
   2. This feature makes it easier to create and operate applications that store their state on disks, such as databases 
3. Iterative design
   1. It works with an explicitly defined configuration that consists of multiple containers
   2. The containers in the configuration can be extended with new containers 

### Docker compose CLI 
1. Docker compose works with teh Docker Engine to create and manage multi-container applications
2. To interact with Docker Engine, Docker compose uses CLI tool named `docker-compose` 
3. On `Mac and Windows System`, docker-compose is already part of the `Docker desktop` 
4. On Linux system, we need to install the `docker-compose` CLI tool after installing the Docker engine 
5. We can install on Linux using the following command
```shell
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-componse-$()uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```
6. Next make the downloaded binary executable with the following command
```shell
$ sudo chmod +x /usr/local/bin/docker-compose
```
7. Test the CLI installation with the following command in the Terminal on all operating systems 
```shell
$ docker-compose version 
```

## Docker Compose CLI Commands
### Docker compose CLI commands 
1. Three essential commands to manage the lifecycle of applications
2. `docker-compose up`
   1. Creates and starts the containers defined in the configuration. 
   2. To run the containers in the background in `detached` mode, we can use the `-d or --detach` flag 
3. `docker-compose ps`
   1. Lists the containers and their status information
4. `docker-compose down`
   1. This command stops and removes all the resources, including containers, networks, images and volumes

## Docker Compose File 
### Structures of the Docker Compose File 
1. Configuration file used for docker-compose is known as `docker-compose.yaml`
2. Look at the official documentation at the url `https://docs.docker.com/compose/compose-file/`
3. It consists of four main sections as shown below
```yaml
version: 3
services:
   - ...
networks:
  - ...
volumes:
  - ... 
```

   1. `version:` - This section defines the syntax version for the `docker-compose` file, and currently, the latest syntax version is 3 
   2. `services:` - This section describes the Docker containers that will be built if needed and will be started by `docker-compose`
      1. For services section, there are two ways to create containers 
      2. First option is to build the container, and the second option is to use `Docker images` from the registry 
   3. `networks:` - This section describes the networks that will be used by the services 
   4. `volumes:` - This section describes the data volumes that will be mounted to the containers in services 
   

## Exercise - 1
### Getting Started with Docker compose 
1. `Problem Statement: ` - Web servers in containers require operational tasks before starting, such as configuration, file downloads, or dependency installations. 
   1. Using `docker compose` let us define those operations as `multi-container` applications and run them with a single command. 

### Solutions 
1. Step 1: Create a folder named `server-compose` and then navigate to the directory 
```shell
$ mkdir server-compose 
$ cd server-compose 
```
2. Create  a folder with the name `init` and navigate into it 
```shell
$ mkdir init 
$ cd init 
```
3. Create a `prepare.sh` file with the following content
```shell
#!/usr/bin/env sh
rm /data/index.html 
echo "<h1>Welcome from Docker compose!</h1>" >> /data/index.html
echo "<img src='http://bit.ly/mobylogo' />" >> /data/index.html
```
4. Create a `Dockerfile` with the following content
```shell
FROM busybox 
ADD prepare.sh /usr/bin/prepare.sh
RUN chmod +x /usr/bin/prepare.sh 
ENTRYPOINT ["sh", "/usr/bin/prepare.sh"]
```
5. Change the directory to the parent folder with the `cd ..` command and create a `docker-compose.yaml` with the following content
```yaml
version: "3"
services:
  init:
    build:
      context: ./init
    volumes:
       - static:/data

  server:
    image: nginx 
    volumes:
       - static:/usr/share/nginx/html
    ports:
       - "8080:80"

volumes:
  static:
```
6. This `docker-compose` file creates one volume named `static` and two services with the name `init` and `server` 
   1. The volume is mounted to both the containers 
   2. In addition to it, the server has published port 8080, connecting to container port 80 
7. Start the application with the following command in detach mode 
```shell
$ docker-compose up --detach 

[+] Building 48.6s (9/9) FINISHED                                                                                                                        
 => [internal] load build definition from Dockerfile                                                                                                0.0s
 => => transferring dockerfile: 158B                                                                                                                0.0s
 => [internal] load .dockerignore                                                                                                                   0.0s
 => => transferring context: 2B                                                                                                                     0.0s
 => [internal] load metadata for docker.io/library/busybox:latest                                                                                  47.2s
 => [auth] library/busybox:pull token for registry-1.docker.io                                                                                      0.0s
 => [1/3] FROM docker.io/library/busybox@sha256:5acba83a746c7608ed544dc1533b87c737a0b0fb730301639a0179f9344b1678                                    1.1s
 => => resolve docker.io/library/busybox@sha256:5acba83a746c7608ed544dc1533b87c737a0b0fb730301639a0179f9344b1678                                    0.0s
 => => sha256:5acba83a746c7608ed544dc1533b87c737a0b0fb730301639a0179f9344b1678 2.29kB / 2.29kB                                                      0.0s
 => => sha256:a77fe109c026308f149d36484d795b42efe0fd29b332be9071f63e1634c36ac9 527B / 527B                                                          0.0s
 => => sha256:71a676dd070f4b701c3272e566d84951362f1326ea07d5bbad119d1c4f6b3d02 1.47kB / 1.47kB                                                      0.0s
 => => sha256:a01966dde7f8d5ba10b6d87e776c7c8fb5a5f6bfa678874bd28b33b1fc6dba34 828.50kB / 828.50kB                                                  1.0s
 => => extracting sha256:a01966dde7f8d5ba10b6d87e776c7c8fb5a5f6bfa678874bd28b33b1fc6dba34                                                           0.1s
 => [internal] load build context                                                                                                                   0.0s
 => => transferring context: 205B                                                                                                                   0.0s
 => [2/3] ADD prepare.sh /usr/bin/prepare.sh                                                                                                        0.0s
 => [3/3] RUN chmod +x /usr/bin/prepare.sh                                                                                                          0.1s
 => exporting to image                                                                                                                              0.0s
 => => exporting layers                                                                                                                             0.0s
 => => writing image sha256:eeb6cd29580c023bdec66fa919109e7fd51734d9c0de399ef16b884d7c2b9dfa                                                        0.0s
 => => naming to docker.io/library/server-compose_init                                                                                              0.0s

Use 'docker scan' to run Snyk tests against images to find vulnerabilities and learn how to fix them
[+] Running 4/4
 ⠿ Network server-compose_default     Created                                                                                                       0.0s
 ⠿ Volume "server-compose_static"     Created                                                                                                       0.0s
 ⠿ Container server-compose_server_1  Started                                                                                                       0.4s
 ⠿ Container server-compose_init_1    Started               
```
8. View the status of the application using the following command
```shell
$ docker-compose ps 
NAME                      COMMAND                  SERVICE             STATUS              PORTS
server-compose_init_1     "sh /usr/bin/prepare…"   init                exited (0)          
server-compose_server_1   "/docker-entrypoint.…"   server              running             0.0.0.0:8080->80/tcp

```
9. Open the browser and the url `http://localhost:8080/`
10. Let us stop the containers and remove all the resources using the following command
```shell
$ docker-compose down 
```

## Exercise - 2 
### Configuration Services with Docker Compose 
1. Services in Docker compose are configured by environment variables.
2. Create a Docker compose application that is configured by different methods of setting variables 


### Solution:
1. Step 1: Create a folder named `server-with-configuration` and navigate to the folder using the `cd` command
```shell
$ mkdir server-with-configuration
$ cd server-with-configuration
```
2. Step 2: Create a `print.env` file and added the following content
```shell
ENV_FROM_ENV_FILE_1=HELLO
ENV_FROM_ENV_FILE_2=WORLD
```
3. Step 3: Create a file with the name `docker-compose.yaml` and add the following content
```yaml
version: "3"
services:
  print:
    image: busybox:latest
    command: sh -c 'sleep 5 && env'
    env_file:
      - print.env
    environment:
      - ENV_FROM_COMPOSE_FILE=HELLO
      - ENV_FROM_SHELL
```
4. Step 4: Execute the following command
```shell
$ export ENV_FROM_SHELL=WORLD 
```
5. Step 5: Execute the following command
```shell
$ docker-compose up 
[+] Running 1/1
 ⠿ Container server-with-configuration_print_1  Recreated                                                                                           0.1s
Attaching to print_1
print_1  | HOSTNAME=8768e99d0146
print_1  | SHLVL=1
print_1  | HOME=/root
print_1  | PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
print_1  | ENV_FROM_ENV_FILE_1=HELLO
print_1  | ENV_FROM_ENV_FILE_2=WORLD
print_1  | ENV_FROM_COMPOSE_FILE=HELLO
print_1  | ENV_FROM_SHELL=WORLD
print_1  | PWD=/
print_1 exited with code 0

```

## Service Dependency
### Service Dependency
1. Although Containers are designed as independent microservices, creating services that depend on each other is highly expected
2. For instance, let's assume you have a two tier application with database and backend components, such as a PostgreSQL database and a Java backend
3. Create a directory `service-dependency`
4. Create a file named `docker-compose.yaml` with the following content
```shell
version: "3"
services:
  init:
    image: busybox:latest
  pre:
    image: busybox:latest
    depends_on:
      - "init"
  main:
    image: busybox:latest
    depends_on:
      - "pre"
```
5. In this file, the `main` container depends on the `pre:` container, whereas the `pre` container depends on `init` container
6. Docker compose starts the containers in the order of `init`, `pre` and `main` containeri
7. Step 6:

## Exercise - Dockerizing a Java Application 
### Dockerize the Java Application 
1. Clone the git repository ` https://github.com/arunstiwari/docker-workshop-microservice.git`
2. This is a source code for `Customer API` which fetches and add customer records to/from the database which in this case is `Postgres Database` 
3. Look at the content of the `Dockerfile`
```shell
FROM openjdk:19-jdk-oracle
WORKDIR	 /home/customerservice
COPY target/customerservice.jar customerservice.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "customerservice.jar"]

```
4. First execute the following command to create the `jar` file as shown below
```shell
$ mvn clean package -DskipTests=true 
```

### Create a Docker compose file
1. Create a `docker-compose.yaml` with the following content
```yaml
version: "3"
services:
  db:
    image: 'postgres:13.1-alpine'
    container_name: db
    volumes:
      - db_data:/var/lib/postgresql/data/
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=docker
  app:
    build:
      context: .
    container_name: app
    ports:
      - 9080:8080
    environment:
      - SPRING_DATASOURCE_URL=jdbc:postgresql://db:5432/postgres
      - SPRING_DATASOURCE_USERNAME=postgres
      - SPRING_DATASOURCE_PASSWORD=docker
      - SPRING_JPA_HIBERNATE_DDL_AUTO=update
      - SPRING_SERVER_PORT=8080
    depends_on:
      - db

volumes:
  db_data:

```
2. Next execute the following command to start the `application stack `
3. Open the `Postman app` and post a `json request` on the url `http://localhost:9080/customers/` 
```json
{
    "name": "Customer-1",
    "age": 35,
    "gender": "MALE"
}
```
4. From the postman fire a `GET request on the url http://localhost:9080/customers/` and you will get the response back 