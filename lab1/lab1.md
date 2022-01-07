## Configuring Containers 
### Configuring Container 
1. We need to provide some configuration to the application running inside a container
2. The configuration is often used to allow one and the same container to run in very different environments, such as in development, test, staging or production environments
3. In Linux, the configuration values are often provided via environment variables
4. Application running inside a container is completely shielded from its host environment. Thus the environment variables that we see on the host are different from the ones that we see from within a container
5. Let us verify this by executing the following command in the terminal
```shell
$ export 

COMMAND_MODE=unix2003
DISPLAY=:0
GOOGLE_APPLICATION_CREDENTIALS=/Users/arunstiwari/Downloads/canvas-seat-327912-bc8a823b93f5.json
HOME=/Users/arunstiwari
HOMEBREW_CELLAR=/opt/homebrew/Cellar
HOMEBREW_PREFIX=/opt/homebrew
HOMEBREW_REPOSITORY=/opt/homebrew
INFOPATH=/opt/homebrew/share/info:
LC_CTYPE=en_IN.UTF-8
LESS=-R
LOGIN_SHELL=1
LOGNAME=arunstiwari
LSCOLORS=Gxfxcxdxbxegedabagacad
MANPATH=/opt/homebrew/share/man::
OLDPWD=/Users/arunstiwari/training/docker-images/lab6/server-compose
...
```
6. Next execute a `export command ` inside an `alpine container`  and look at the difference 
```shell
$ docker container run --rm -it alpine:latest /bin/sh 
/ # export
export HOME='/root'
export HOSTNAME='6a603bd1a1bf'
export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
export PWD='/'
export SHLVL='1'
export TERM='xterm'
/ #
```
7. We can see that the `environment variables` are not same from within the container

## Defining environment variables for containers
### Passing the parameter inline 
1. To pass the configuration values into the container at start time, we can use the `--env (or the short form, -e) `
2. Format for passing the parameter is `--env <key>=<value>` where `<key>` is the name of the environment variable and `<value>` represents the value 
3. Let us pass the environment variable to the `alpine container` using the following command
```shell
$ docker container run --rm -it --env LOG_DIR=/var/log/my-log alpine:latest /bin/sh 
/ # export
export HOME='/root'
export HOSTNAME='5b229592162f'
export LOG_DIR='/var/log/my-log'
export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
export PWD='/'
export SHLVL='1'
export TERM='xterm'
```
4. We can pass more thatn one environment variable to the container. Let us look at the command below 
```shell
$ docker container run --rm -it --env LOG_DIR=/var/log/my-log --env MAX_LOG_FILES=5 --env MAX_LOG_SIZE=1G alpine:latest /bin/sh 

/ # export
export HOME='/root'
export HOSTNAME='fe90608c70e4'
export LOG_DIR='/var/log/my-log'
export MAX_LOG_FILES='5'
export MAX_LOG_SIZE='1G'
export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
export PWD='/'
export SHLVL='1'
export TERM='xterm'
```

### Passing the environment variable using the configuration files 
1. Let us create a file called `development.config` with the following content
```shell
LOG_DIR=/var/log/my-log
MAX_LOG_FILES=5
MAX_LOG_SIZE=1G
```
2. Next execute the following command to start the `alpine container` and pass the environment variables using files 
```shell
$ docker container run --rm it --env-file ./development.config alpine:latest sh -c "export"

export HOME='/root'
export HOSTNAME='d2af58a2e9b0'
export LOG_DIR='/var/log/my-log'
export MAX_LOG_FILES='5'
export MAX_LOG_SIZE='1G'
export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
export PWD='/'
export SHLVL='1'
export TERM='xterm'
```

### Defining Environment variables in container images 
1. Sometimes we want to define some default value for an environment variable that must be present in each container instance of a given container image 
2. We can do so in the `Dockerfile` that is used to create that image by following these steps:
```shell
FROM alpine:latest 
ENV LOG_DIR=/var/log/my-log
ENV MAX_LOG_FILES=5
ENV MAX_LOG_SIZE=1G
```
3. Create a container image called `my-alpine` using the Dockerfile 
```shell
$ docker image build -t my-alpine . 
```
4. Next run a container instance from this image that outputs the environment variables defined inside the container, like this 
```shell
$ docker container run --rm -it my-alpine sh -c "export | grep LOG"

export LOG_DIR='/var/log/my-log'
export MAX_LOG_FILES='5'
export MAX_LOG_SIZE='1G'
```
5. We can override the default value at the runtime using the `--env` parameter as shown below
```shell
$ docker container run --rm -it --env MAX_LOG_FILES=20  my-alpine sh -c "export |  grep LOG"

export LOG_DIR='/var/log/my-log'
export MAX_LOG_FILES='20'
export MAX_LOG_SIZE='1G'
 
```
6. We can also override the default value using environment files with the `--env-file` parameter 

### Environment variables at build time 
1. Sometimes we want to have the possibility to define some environment variables that are valid at the time when we build a container image 
2. Imagine that you want to define a `BASE_IMAGE_VERSION` environment variable that shall then be used as a parameter in your Dockerfile 
3. Let us write a Dockerfile with the following content
```shell
ARG BASE_IMAGE_VERSION=12.7-stretch 
FROM node:${BASE_IMAGE_VERSION}
WORKDIR /app 
COPY package.json . 
RUN npm install 
COPY . . 
CMD npm start 
```
4. We are using the `ARG` directive to define a default value that is used each time we build an image from the `Dockerfile` 
5. If we want to create a special image for - say testing purpose, we can override this variable at image build time using the `--build-arg` parameter, as follows 
```shell
$ docker image build --build-arg BASE_IMAGE_VERSION=12.7-alpine -t my-node-app-test . 
```
6. In this case, the resulting `my-node-app-test:latest` image will be built from the `node:12.7-alpine` base image and not from the `node:12.7-stretch` image
7. Environment variables defined via `--env or --env-file` are valid at container runtime. It is normally used to configure an application running inside a container  
8. Variables defined with `ARG` in the `Dockerfile` or `--build-arg` in the `docker container build` command are valid at container image build time . This is used to parameterize the container image build process 