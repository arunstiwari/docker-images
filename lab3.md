author: Arun Tiwari
summary: Docker Workshop 
id: lab3
layout: page
title: "Docker Workshop"
permalink: /labs/docker-beginner
categories: codelab,markdown
environments: Web
status: Published
feedback link: https://github.com/arunstiwari/docker-workshop-lab
analytics account: Google Analytics ID

# Dockerfile 

## Introduction
Duration: 0:07:00
### What is a Dockerfile?
1. A `Dockerfile` is a text file that contains instructions on how to create a Docker image
2. `Instructions` that we write in a `Dockerfile` is called `directives`
3. `Dockerfile` is a mechanism for creating a customer Docker image as per an application requirement

### Dockerfile Format 
+ The format of a Dockerfile is as follows:
```text
# This is a comment 
DIRECTIVE argument 
```
+ All lines starting with `#` is a comment 
+ `Directive` is not case sensitive in Dockerfile, however best practice is write all directives in uppercase.
+ A `Dockerfile` can contain multiple lines of comments and directives. These lines will be executed in order by the `Docker Engine` while building the Docker image 
+ If we are using ubuntu versions later than 18.04, there will be a prompt to enter time zone. We can suppress the prompt with argument shown below:
```shell
DEBIAN_FRONTEND = non_interactive
```

### Common Directives in Dockerfile
+ Directive is a command that is used to create a Docker image. 
+ Let us look at the five important directives
  1. The `FROM` directive
     1. `Dockerfile` usually starts with the `FROM` directive. Used to specify the parent image of our custom Docker image
     2. A `FROM` directive has the following format:
     ```text
     FROM <image>:<tag>
     ```
     3. e.g. if we want to build the docker image from ubuntu version 20.04, we can write the FROM directive as 
     ```text
     FROM ubuntu:20.04
     ```
     4. If we want to build the docker image from scratch, we can use the following command
     ```text
     FROM scratch
     ```
     
  2. The `LABEL` directive
     1. A `LABEL` is a key-value pair that can be used to add metadata to a Docker image. 
     2. These labels can be used to organize the Docker images properly
     3. A `LABEL` directive has the following format:
     ```text
        LABEL <key>=<value>   
     ```
     4. A Dockerfile can have multiple labels, adhering to the preceding key-value format:
     ```text
      LABEL maintainer=arunstiwari@gmail.com
      LABEL version=1.0
      LABEL environment=dev 
     ```
     5. Labels on an existing Docker image can be viewed with the `docker image inspect` command 
     
  3. The `RUN` directive
     1. This directive is used to execute the commands during the image build time 
     2. This will create a new layer on top of the existing layer, execute the specified command, and commit the results to the newly created layer 
     3. This directive is used to install the required packages, update the packages, create users and groups, and so on 
     4. The `RUN` directive has the following format:
     ```text
        RUN <command>
     ```
     5. `<command>` specifies the shell command you want to execute as part of the image build process. 
     6. A Dockerfile can have multiple `RUN` directives adhering to the preceding format 
     7. Following e.g. shows the installation of `nginx` server 
     ```text
      RUN apt-get update 
      RUN apt-get install nginx -y 
     ```
     8. We can add multiple shell commands to a single `RUN` directive by separating them with the `&&` symbol
     ```text
      RUN apt-get update && apt-get install nginx -y
     ```
  4. The `CMD` directive
     1. This directive is used to provide the default initialization command that will be executed when a container is created from the Docker image
     2. A Dockerfile can execute only one `CMD` directive
     3. If there is more than one `CMD` directive in the `Dockerfile`, Docker will execute only the last one 
     4. The `CMD` directive has the following format:
     ```text
      CMD ["executable", "param1", "param2", "param3", ...]
     ```
     5. Following example is used to echo `Hello World` as the output of a Docker container
     ```text
      CMD ["echo", "Hello world"]
     ```
     6. The preceding `CMD` directive will produce the following output when we run the Docker container with the `docker container run <image>` command 
     ```shell
      $ docker container run <image> echo 
      "Hello Docker !!!"
     ```
     ### Difference between RUN and CMD
     1. Both the `RUN` and `CMD` directives will be used to execute a shell command. 
     2. The main difference between these two directives is that the command provided with the RUN directive will be executed during the image build process, while the command provided with the CMD directive will be executed once a container is launched from the built image 
     3. Dockerfile can have multiple RUN directives, but there can be only one CMD directive. 
     4. If we have multiple CMD directives, then all others except the last one will be ignored.
     5. RUN directive is used to install a software package during the Docker image build process and the CMD directive is used to start the software package once a container is launched from the built image 
     
  5. The `ENTRYPOINT` directive
     1. This directive is used to provide the default initialization command that will be executed when a container is created from the Docker image 
     2. Difference between `CMD` and `ENTRYPOINT` directive is that unlike the CMD directive, we cannot override the `ENTRYPOINT` command using the command-line parameters sent with the `docker container run` command 
     3. This directive has the following format:
     ```text
      ENTRYPOINT ["executable", "param1", "param2", "param3", ...]
     ```
     4. `Note: The --entrypoint flag can be sent with the docker container run` command to override the default ENTRYPOINT of the image
     5. Following example shows the default command as `echo` and default parameter as `Hello` using the `ENTRYPOINT` directive. We have also provided `World` as the additional parameter using the `CMD` directive
     ```text
      ENTRYPOINT ["echo", "Hello"]
      CMD ["World"]
     ```
     6. Now when we run the container, we will get output as 
     ```shell
      $ docker container run <image>
      Hello World
     ```
     7. However if we launch the Docker image with additional command line parameters, the output message will be 
     ```shell
      $ docker container run <image> "Docker"
      Hello Docker
     ```
## Create First Dockerfile 
1. Let us create a `Dockerfile` with the following content 
```text
# This is my first Docker image 
FROM ubuntu 
LABEL maintainer=arunstiwari@gmail.com
RUN apt-get update
CMD ["The Docker workshop"]
ENTRYPOINT ["echo", "You are reading"]
```

### Docker image 
1. A docker image is a binary file consisting of multiple layers based on the instructions provided in the Dockerfile
2. These layers are stacked on top of one another, and each layer is dependent on the previous layer
3. Each of the layers is a result of the changes from the layer below it 
4. All the layers of the Docker image are read-only 
5. Once we create a Docker container from a Docker image, a new writable layer will be created on top of other read-only layers, which will contain all the modifications made to the container filesystem 

6. The `docker image build` command will create a Docker image from the Dockerfile. The layers of the Docker image will be mapped to the directives provided in the Dockerfile 
7. The `docker image build` command has following format 
```shell
$ docker image build <context> 
```
8. Execute the command from the directory where the Dockerfile is located.
```shell
$ docker image build . 

[+] Building 8.0s (6/6) FINISHED                                                                                                                         
 => [internal] load build definition from Dockerfile                                                                                                0.0s
 => => transferring dockerfile: 212B                                                                                                                0.0s
 => [internal] load .dockerignore                                                                                                                   0.0s
 => => transferring context: 34B                                                                                                                    0.0s
 => [internal] load metadata for docker.io/library/ubuntu:latest                                                                                    0.0s
 => [1/2] FROM docker.io/library/ubuntu                                                                                                             0.0s
 => [2/2] RUN apt-get update                                                                                                                        7.8s
 => exporting to image                                                                                                                              0.1s
 => => exporting layers                                                                                                                             0.1s
 => => writing image sha256:4b8edb92cc2d2e4cabe1933c4958496c2524c3761a37f646ae1a39d60897db47          
```
9. Let us look at the `list of images` using the following command
```shell
$ docker image list 
REPOSITORY                    TAG                IMAGE ID       CREATED              SIZE
<none>                        <none>             4b8edb92cc2d   About a minute ago   92.8MB
...
```
10. Let us build the image again using the following command 
```shell
$ docker image build . 

[+] Building 0.1s (6/6) FINISHED                                                                                                                         
 => [internal] load build definition from Dockerfile                                                                                                0.0s
 => => transferring dockerfile: 37B                                                                                                                 0.0s
 => [internal] load .dockerignore                                                                                                                   0.0s
 => => transferring context: 32B                                                                                                                    0.0s
 => [internal] load metadata for docker.io/library/ubuntu:latest                                                                                    0.0s
 => [1/2] FROM docker.io/library/ubuntu                                                                                                             0.0s
 => CACHED [2/2] RUN apt-get update                                                                                                                 0.0s
 => exporting to image                                                                                                                              0.0s
 => => exporting layers                                                                                                                             0.0s
 => => writing image sha256:4b8edb92cc2d2e4cabe1933c4958496c2524c3761a37f646ae1a39d60897db47  
```
11. This time the `image build process` was instantaneous and the reason for this is `cache`. 
    1. Since we did not change any content of the `Dockerfile`, the Docker daemon took advantage of the cache and reused the existing layers from the local image cache to accelerate the build process 
    2. We can see that the cache was used this time with the `Using cache` lines available in the preceding output 

12. Let us tag our image with `IMAGE ID 4b8edb92cc2d` as `my-tagged-image:v1.0`
```shell
$ docker image tag 4b8edb92cc2d my-tagged-image:v1.0
```
13. Let us execute the following command to see the image information
```shell
$ docker image list 

REPOSITORY                    TAG                IMAGE ID       CREATED          SIZE
my-tagged-image               v1.0               4b8edb92cc2d   12 minutes ago   92.8MB
...
```
14. We can also tag an image during the build process by specifying the -t flag :
```shell
$ docker image build -t my-tagged-image:v2.0 .
```
15. Let us run the container from this image using the following command
```shell
$ docker container run my-tagged-image:v1.0 

You are reading The Docker workshop
```

## Othe Dockerfile Directives
1. Besides the common directives we have seen earlier, there are advanced directives that is used to create more advanced Docker images 
2. Let us look at the important advanced directives
   1. The ENV directive
      1. This directive is used to set environment variables
      2. Environment variables are used by applications and processes to get information about the environment in which a process runs 
      3. One example would be PATH environment variable, which lists the directories to search for executable files 
      4. Environment variables are defined as key-value pairs as per the following format:
      ```text
       ENV <key> <value>
      ```
      5. The `PATH` environment variable is set with the following value: 
      ```text
        $PATH:/usr/local/myapp/bin/
      ```
      6. Hence, it can be set using the ENV directive as follows:
      ```text
       ENV PATH $PATH:/usr/local/myapp/bin/
      ```
      7. We can set multiple environment variables in the same line separated by spaces. However, in this form, the `key` and `value` should be separated by the `=` symbol: 
      ```text
       ENV <key>=<value> <key>=<value> ...
      ```
      8. Let us set two environment variables using the `ENV` directive as shown below:
      ```text
       ENV PATH $PATH:/usr/local/myapp/bin/ VERSION=1.0.0
      ```
      9. Once an environment variable is set with the `ENV` directive in the `Dockerfile`, this variable is available in all subsequent Docker image layers. 
         1. This variable is even available in the Docker containers launched from this Docker image
   2. The ARG directive
      1. This directive is used to define variables that the user can pass at build time. 
      2. This directive is the only directive that can precede the `FROM` directive in the `Dockerfile`
      3. Users can pass values using `--build-arg <var-name>=<value>`, as shown here, while building the Docker image 
      ```shell
       $ docker image build -t <image>:<tag> --build-arg <varname>=<value> . 
      ```
      4. This directive has the following format:
      ```text
       ARG <varname>
      ```
      5. There can be multiple `ARG` directives in a `Dockerfile` as follows:
      ```text
       ARG USER 
       ARG VERSION 
      ```
      6. The `ARG` directive can also have an optional default value defined. This default value will be used if no value is passed at build time
      ```text
       ARG USER=TestUser 
       ARG VERSION=1.0.0
      ```
      7. Unlike the `ENV` variables, `ARG` variables are not accessible from the running container. They are only available during the build process
      8. Let's create a Dockerfile with the following content 
      ```text
       # ENV and ARG example
       ARG TAG=latest
       FROM ubuntu:$TAG
       LABEL maintainer=arunstiwari@gmail.com
       ENV VERSION=1.0 APP_DIR=/usr/local/app/bin
       CMD ["env"] 
      ```
      9. Let us build the image with the following command as shown below:
      ```shell
       $  docker image build -t arg-env-ex --build-arg TAG=19.04 . 
        [+] Building 13.4s (6/6) FINISHED                                                                                                                        
        => [internal] load build definition from Dockerfile                                                                                                0.0s
        => => transferring dockerfile: 191B                                                                                                                0.0s
        => [internal] load .dockerignore                                                                                                                   0.0s
        => => transferring context: 34B                                                                                                                    0.0s
        => [internal] load metadata for docker.io/library/ubuntu:19.04                                                                                     6.9s
        => [auth] library/ubuntu:pull token for registry-1.docker.io                                                                                       0.0s
        => [1/1] FROM docker.io/library/ubuntu:19.04@sha256:2adeae829bf27a3399a0e7db8ae38d5adb89bcaf1bbef378240bc0e6724e8344                               6.4s
        => => resolve docker.io/library/ubuntu:19.04@sha256:2adeae829bf27a3399a0e7db8ae38d5adb89bcaf1bbef378240bc0e6724e8344                               0.0s
        => => sha256:a55088cd5dc4ddefb4c30267d79196ee7e0b09ab273696bb32954cdc96c34800 30.81kB / 30.81kB                                                    1.7s
        => => sha256:7f1b9a27d159d75a27bf268dc94e86433ce6c7840992325466a3ab2be6bc01ab 863B / 863B                                                          2.1s
        => => sha256:2adeae829bf27a3399a0e7db8ae38d5adb89bcaf1bbef378240bc0e6724e8344 1.42kB / 1.42kB                                                      0.0s
        => => sha256:e4f396e90bcc1f4487f981b5621414ab8ac9d1a75dd3a1571758ca4e09c6bc32 1.15kB / 1.15kB                                                      0.0s
        => => sha256:0595a5e7607f131088dcf242a8ccef3a2b2f05545e15f15aa66dd277462b734d 3.41kB / 3.41kB                                                      0.0s
        => => sha256:50e8a48a550c9ae0c880412c6c2525816866742e8df3485270f9658865d35f47 26.38MB / 26.38MB                                                    5.4s
        => => sha256:152e29618af7e9bf7b60d7c96ea6570603851e3bafe5b5c05df675a3e2e81b38 187B / 187B                                                          4.8s
        => => extracting sha256:50e8a48a550c9ae0c880412c6c2525816866742e8df3485270f9658865d35f47                                                           0.7s
        => => extracting sha256:a55088cd5dc4ddefb4c30267d79196ee7e0b09ab273696bb32954cdc96c34800                                                           0.0s
        => => extracting sha256:7f1b9a27d159d75a27bf268dc94e86433ce6c7840992325466a3ab2be6bc01ab                                                           0.0s
        => => extracting sha256:152e29618af7e9bf7b60d7c96ea6570603851e3bafe5b5c05df675a3e2e81b38                                                           0.0s
        => exporting to image                                                                                                                              0.0s
        => => exporting layers                                                                                                                             0.0s
        => => writing image sha256:fc09d4ae4a937076d1b98a05cc6cacac9fb40f5e7f93f9712ca0f7895f2044a4                                                        0.0s
        => => naming to docker.io/library/arg-env-ex     
      ```
      10. Here while building the image we have overridden the value of `Build args`
      11. Next let us run the container with the following command:
      ```shell
        $ docker container run arg-env-ex 
         PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
         HOSTNAME=7838ea6cf39a
         VERSION=1.0
         APP_DIR=/usr/local/app/bin
         HOME=/root
      ```
      12. Let us override the ENV variable while running the container. Use the following command to run the container
      ```shell
       $ docker container run -e VERSION=1.1 arg-env-ex
         PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
         HOSTNAME=7838ea6cf39a
         VERSION=1.1
         APP_DIR=/usr/local/app/bin
         HOME=/root 
      ```
   3. The WORKDIR directive
      1. This directive is used to specify the current working directory of the Docker container
      2. Any subsequent `ADD, CMD, COPY, ENTRYPOINT and RUN` directives will be executed in this directory
      3. This directive has the following format:
      ```text
        WORKDIR /path/to/workdir
      ```
      4. If this specified directory does not exist, Docker will create this directory and make it the current working directory, which means this directive executes both the `mkdir` and `cd` commands implicitly
      5. There can be multiple `WORKDIR` directives in the Dockerfile. If a relative path is provided in a subsequent `WORKDIR` directive, that will be relative to the working directory set by the previous `WORKDIR` directive
      ```text
       WORKDIR /one
      WORKDIR two
      WORKDIR three
      RUN pwd 
      ```
      6. The output of the `pwd` command will be `/one/two/three`
   4. The COPY directive
      1. This directive is used to copy files and folders from the local filesystem to the Docker image during the build process 
      2. This directive takes two arguments - the first one is the `source path` from the local filesystem, and the second one is the `destination path` on the image filesystem
      ```text
       COPY <source> <destination>
      ```
      3. Wildcards can also be specified to copy all files that match the given pattern. E.g. is shown below 
      ```text
       COPY *.html /var/www/html/
      ```
      4. In addition to copying files, the `--chown` flag can be used with the `COPY` directive to specify the user and group ownership of the files 
      ```text
       COPY  --chown=myuser:mygroup *.html /var/www/html/
      ```
   5. The ADD directive
      1. This directive is similar to the `COPY` directive and has the following format:
      ```text
       ADD <source> <destination>
      ```
      2. In addition to the functionality provided by the `COPY` directive, the `ADD` directive also allows us to use `URL` as the <source> parameter
      ```text
       ADD http://sample.com/test.txt /tmp/test.txt 
      ```
      3. In the last example, the `ADD` directive will download the `test.txt` file from the url and `copy` it to the target directory 
      4. Another feature of the `ADD` directive is automatically extracting the compressed files. If we add a compressed file (gzip, bzip2, tar and so on) to the `<source>` parameter, the `ADD` directive will extract the archive and copy the content to the image filesystem
      ```text
       ADD html.tar.gz /var/www/html 
      ```
      5. Exercise: Let us deploy custom HTML files to the Apache Web server. 
         1. We will use `Ubuntu` as the base image and install Apache on top of it 
         2. Next we will copy our index.html to the Docker imag eand download the docker logo from the https://www.docker.com website to be used with the custom index.html file
         3. Let us create a new directory `exercise-1` and create an `index.html` file in it 
         4. The content of the `index.html` file is as below:
         ```html
         <html>
          <body>
           <h1>Welcome to Docker workshop</h1>
           <img src="logo.png" height="350" width="500"
         </body>
         </html>
         ```
         5. Next create `Dockerfile` with the following content:
         ```text
         # WORKDIR, COPY and ADD example 
         FROM ubuntu:latest
         ENV DEBIAN_FRONTEND noninteractive 
         RUN apt-get update && apt-get install apache2 -y 
         WORKDIR /var/www/html/
         COPY index.html . 
         ADD https://www.docker.com/sites/default/files/d8/2019-07/Moby-logo.png ./logo.png 
         CMD ["ls"]
         ```
         6. Let us build the docker image using the following command
         ```shell
          $ docker image build -t copy-add-ex .
         ```
         7. Next run the docker image using the following command
         ```shell
          $ docker container run copy-add-ex 
          ```
         8. From the output we can see that both the `index.html` and `logo.png` files are available in the `/var/www/html/` directory
   6. The USER directive
      1. Docker will use the `root` user as the default user of a Docker container
      2. We can use the `USER` directive to change this default behaviour and specify a `non-root` user as the default `user` of a Docker container 
      3. Running the container as `non-root user` improves the security of the container
      4. The username specified with the `USER` directive will be used to run all the subsequent `RUN, CMD and ENTRYPOINT` directives in the Dockerfile
      5. This directive takes the following format:
      ```shell
       USER <user>
      ```
      6. In addition to the `username` we can also specify the optional `group` name to run the Docker container 
      ```shell
       USER <user>:<group>
      ```
      7. We need to make sure that the `<user>` and the `<group>` values are valid user and group names
      8. Exercise: Create a Docker image to run the Apache web server. The container should run as a non-root user due to security reasons. 
         1. Step 1: Use `USER` directive in the `Dockerfile` to set the default user 
         2. Step 2: Install the `Apache web server` and change the user to `wwww-data` (Note: www-data user is the default user for the Apache web server on Ubuntu)
         3. Step 3: Finally execute the `whoami` command to verify the current user by printing the `username` 
      9. Solution:
         1. Create a `Dockerfile` as shown below:
         ```text
         # USER directive example
          ARG TAG=lates 
         FROM ubuntu:$TAG
         ENV DEBIAN_FRONTEND noninteractive
         RUN apt-get update && apt-get install apache2 -y
         WORKDIR /var/www/html/
         USER www-data
         CMD ["whoami"]
         ```
         2. Next let us build the docker image using the following command
         ```shell
          $ docker image build -t user-ex .
         [+] Building 0.1s (7/7) FINISHED                                                                                                                         
         => [internal] load build definition from Dockerfile                                                                                                0.0s
         => => transferring dockerfile: 236B                                                                                                                0.0s
         => [internal] load .dockerignore                                                                                                                   0.0s
         => => transferring context: 2B                                                                                                                     0.0s
         => [internal] load metadata for docker.io/library/ubuntu:latest                                                                                    0.0s
         => [1/3] FROM docker.io/library/ubuntu:latest                                                                                                      0.0s
         => CACHED [2/3] RUN apt-get update && apt-get install apache2 -y                                                                                   0.0s
         => CACHED [3/3] WORKDIR /var/www/html/                                                                                                             0.0s
         => exporting to image                                                                                                                              0.0s
         => => exporting layers                                                                                                                             0.0s
         => => writing image sha256:2142d353f834cdf8d569681b5339dcb05539178835ae05a50585beaa8a6ae5ce                                                        0.0s
         => => naming to docker.io/library/user-ex          
         ```
         3. Run the container using the following command
         ```shell
          $ docker container run user-ex
          www-data  
         ```
   7. The VOLUME directive
      1. In Docker, the data (for example, files, executables, etc.) generated and used by Docker containers will be stored within the container filesystem.
      2. When we delete the container, all the data will be lost 
      3. This issue can be resolved by using the concept of `Volumes`
      4. `Volumes` are used to persist the data and share the data between containers
      5. The `VOLUME` directive is used within `Dockerfile` to create Docker volumes. 
      6. Once a `VOLUME` is created in the Docker container, a mapping directory will be created in the underlying host machine. 
      7. All the file changes to the volume mount of the Docker container will be copied to the mapped directory of the host machine 
      8. The `VOLUME` directive generally takes a JSON array as the parameter:
      ````shell
       VOLUME ["/path/to/volume"]
      ````
      9. We can specify the plain string with multiple paths:
      ```shell
      VOLUME /path/to/volume1 /path/to/volume2
      ```
      10. Exercise: Create a Docker container to run the Apache web server. Provision a mechanism to store the log files so that we do not loose the Apache log files in case of Docker container failure
      11. Solution: 
          1. Step 1: Persist the log files by mounting the Apache log path to the underlying Docker host 
          2. Step 2: Create a Dockerfile as shown below:
          ```shell
           # VOLUME directive example
          ARG TAG=latest
          FROM ubuntu:$TAG
          ENV DEBIAN_FRONTEND noninteractive
          RUN apt-get update && apt-get install apache2 -y
          WORKDIR /var/www/html/
          VOLUME ["/var/log/apache2"]
          CMD ["whoami"]
          ```
          3. Step 3: Build the Docker image
          ```shell
           $ docker image build -t volume-ex .
          ```
          4. Step 4: Run the container
          ```shell
          $ docker container run -i --tty --name volume-ex volume-ex /bin/bash 
          ```
          5. Next navigate to the `/var/log/apache2` directory as shown below:
          ```shell
           $ docker container run -i --tty --name volume-ex volume-ex /bin/bash 
          root@d2a58435e9e3:/var/www/html# cd /var/log/apache2/
          root@d2a58435e9e3:/var/log/apache2# ls -l
          total 0
          -rw-r----- 1 root adm 0 Dec 30 11:47 access.log
          -rw-r----- 1 root adm 0 Dec 30 11:47 error.log
          -rw-r----- 1 root adm 0 Dec 30 11:47 other_vhosts_access.log
          ```
          6. Inspect `volume container volume-ex` to view the mount information
          ```shell
           $ docker container inspect volume-ex 
          ...
            "Mounts": [
            {
                "Type": "volume",
                "Name": "bbe0d4c414d1c07f4b8fed5c285a9740827cb9e70c1e3f0f59835ad67bb222b7",
                "Source": "/var/lib/docker/volumes/bbe0d4c414d1c07f4b8fed5c285a9740827cb9e70c1e3f0f59835ad67bb222b7/_data",
                "Destination": "/var/log/apache2",
                "Driver": "local",
                "Mode": "",
                "RW": true,
                "Propagation": ""
            }
          ],

          ...
          ```
          7. We can see the container is mounted to the host path of "/var/lib/docker/volumes/bbe0d4c414d1c07f4b8fed5c285a9740827cb9e70c1e3f0f59835ad67bb222b7/_data", which is defined as the `Mountpoint` field in the preceding output
         
   8. The EXPOSE directive
      1. This directive is used to inform Docker that the container is listening on the specified ports a runtime 
      2. We can use the `EXPOSE` directive to expose ports through either TCP or UDP protocols.
      3. This directive has the following format:
      ```shell
       $ EXPOSE <port>
      ```
      4. However, the ports exposed with the `EXPOSE` directive will only be accessible from within the other Docker containers. 
      5. To expose these ports outside the Docker container, we can publish the ports with the `-p` flag with the `docker container run` command:
      ```shell
       $ docker container run -p <host_port>:<container_port> <image>
      ```
      6. Exercise: Imagine that we have two containers. 
         1. One is a NodeJS web app container that should be accessed from outside via port 80. 
         2. The second one is the MySQL container, which should be accessed from the node app container via port 3306.
         3. In this scenario, we have to expose port 80 of the NodeJS app with the `EXPOSE` directive and use the `-p` flag with the `docker container run` command to expose it externally.
         4. However, for the MySQL container, we can only use the `EXPOSE` directive without the `-p` flag when running the container, as `3306` should only be accessible from the node app container
         5. In summary, the following statements define this directive:
            1. If we specify both the `EXPOSE` directive and `-p` flag, exposed ports will be accessible from other containers as well as externally
            2. If we specify `EXPOSE` directive without the `-p` flag, exposed ports will be accessible from other containers, but not externally
      7. Solution:
         1. 
   9. The HEALTHCHECK directive
      1. `Health checks` are used in `Docker` to check whether the containers are running healthily. 
      2. We can use `health checks` to make sure the application is running within the Docker container. 
      3. Unless there is a health check specified, there is no way for Docker to say whether a container is healthy. 
      4. `HEALTHCHECK` directive has the following format:
      ```shell
       HEALTHCHECK [OPTIONS] CMD command
      ```
      5. There can be only one `HEALTHCHECK` directive in a `Dockerfile`. If there is more than one `HEALTHCHECK` directive, only the last one will take effect.
      6. As an example, we can use the following directive to ensure that the container can receive traffic on the `http://localhost/` endpoint
      ```shell
       HEALTHCHECK CMD curl -f http://localhost/ || exit 1 
      ```
      7. The `exit` code at the end of the preceding command is used to specify the health status of the container. `O` and `1` are valid values for this field 
         1. O is used to denote a healthy container
         2. 1 is used to denote an unhealthy container
      8. We can specify the other parameters with the `HEALTHCHECK` directive, as follows:
         1. `--interval: ` This specifies the period between each health check (the default is 30s)
         2. `--timeout: ` If no success response is received within this period, the health check is considered failed (the default is 30s)
         3. `--start-period: ` The duration to wait before running the first health check. This is used to give a startup time for the container (the default is 0s)
         4. `--retries: ` The container will be considered unhealthy if the health check failed consecutively for the given number of retries (the default is 3)
      9. Let us look at the `HEALTHCHECK` directive example
      ```shell
      HEALTHCHECK --interval=1m --timeout=2s --start-period=2m --retries=3 CMD curl -f http://localhost/ || exit 1  
      ```
      10. Exercise: We need to dockerize the Apache web server to access the Apache home page from the web browser. Additionally, he has asked you to configure health checks to determine the health status of the Apache web server.
      11. Solution:
          1. Create a Dockerfile as shown below
          2. Build the Docker image using the following command
          ```shell
           $ docker image build -t healthcheck-expose-ex . 
          ```
          3. Run the container using the following command
          ```shell
           $ docker container run --rm -p 80:80 --name healthcheck-expose-ex -d healthcheck-expose-ex
          ```
          4. Execute the following command
          ```shell
           $ docker container list 
          CONTAINER ID   IMAGE                   COMMAND                  CREATED         STATUS                            PORTS                NAMES
          31edc71f268e   healthcheck-expose-ex   "apache2ctl -D FOREG…"   5 seconds ago   Up 4 seconds (health: starting)   0.0.0.0:80->80/tcp   healthcheck-expose-ex

          ```
          5. Execute the following command again
          ```shell
           $ docker container list 
           CONTAINER ID   IMAGE                   COMMAND                  CREATED         STATUS                            PORTS                NAMES
           31edc71f268e   healthcheck-expose-ex   "apache2ctl -D FOREG…"   30 seconds ago   Up 29 seconds (healthy)   0.0.0.0:80->80/tcp   healthcheck-expose-ex

          ```
   10. The ONBUILD directive
       1. This directive is used in the `Dockerfile` to create a reusable Docker image that will be used as the base for another `Docker image` 
       2. As an example, we can create a Docker image that contains all the pre-requisites such as dependencies and configurations, in order to run an application
       3. Next we can use the pre-requisites image as the parent image to run the application
       4. While creating the pre-requisites image, we can use the `ONBUILD` directive, which will include the instructions that should only be executed when this image is used as the parent image in another `Dockerfile` 
       5. `ONBUILD` instructions will not be executed while building the `Dockerfile` that contains the `ONBUILD` directive, but only when building the child image 
       6. The `ONBUILD` directive takes the following format:
       ```shell
        ONBUILD <instruction>
       ```
       7. Let us create a Dockerfile as shown below
       ```shell
        # ONBUILD example
        # Start with Ubuntu base image
       FROM ubuntu:18.04
    
       # Set labels
       LABEL maintainer=arunstiwari
       LABEL version=1.0
    
       # Set environment variables
       ENV DEBIAN_FRONTEND=noninteractive
    
       # Install Apache, PHP, and other packages
       RUN apt-get update && \
       apt-get -y install apache2 \
       php \
       curl
    
       # Copy all php files to the Docker image
       ONBUILD COPY *.html /var/www/html
       EXPOSE 80
    
       # Start Apache
       ENTRYPOINT ["apache2ctl", "-D", "FOREGROUND"]
       ```
       8. Build the docker image
       ```shell
        $ docker image build -t onbuild-parent .  
       ```
       9. Run the container
       ```shell
       $ docker container run -p 80:80 --name on-build-container -d on-build-container
       ```
       10. Open the browser and looka at the following url `http://127.0.0.1/`
       11. Now clean up the container. Stop the Docker container by using the following command
       ```shell
        $ docker container stop onbuild-parent-container
       ```
       12. Remove the Docker container with the following command
       13. Let us create another Docker image using `onbuild-parent-container` as the parent image to deploy a custom HTML home page 
       14. In an empty directory, create index.html file and Dockerfile 
       15. Create `index.html` with the following content
       ```html
        <html>
       <body>
         <h1>Learing Docker ONBUILD directive</h1>
       </body>
       </html>
       ```
       16. Create `Dockerfile` with the following content
       ```shell
        # ONBUILD Example 
       FROM onbuild-parent 
       ```
       17. This Dockerfile  has only one directive
       18. Build the docker image 
       ```shell
        $ docker image build -t onbuild-child .   
       ```
       19. Run the docker container
       ```shell
        $ docker container run -p 80:80 --name onbuild-child-container -d onbuild-child 
       ```
       20. We can see the `Apache home page` by browsing the page `http:127.0.0.1/` endpoint from your favourite web browser
       21. Exercise: Deploy a `PHP` welcome page that will greet visitors based on the date and time using the following logic 
           1. Dockerize the PHP application here, using the Apache web server installed on an Ubuntu base image 

