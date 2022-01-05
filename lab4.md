author: Arun Tiwari
summary: Docker Workshop 
id: lab4
layout: page
title: "Docker Workshop"
permalink: /labs/docker-beginner
categories: codelab,markdown
environments: Web
status: Published
feedback link: https://github.com/arunstiwari/docker-workshop-lab
analytics account: Google Analytics ID

# Managing Docker Images  

## Docker Image Management
Duration: 0:07:00
### What is Docker layer?
1. `Docker` uses layers to build images and how image building can sped up with the caching 
2. Docker images are perfect for application development as well. 
3. The image itself is a self-contained version of the application, which includes everything it needs in order to be run
4. When we create a new image using a Dockerfile, it will create more layers on top of the existing image you have built from
5. When we run the image as a container from a Dockerfile, we are creating a readable and writable layers on top of an existing group of read-only layers. This writable layer is known as `container layer`
6. `Note:  Layers are created when the RUN, ADD and COPY commands are used. All other commands in Dockerfile create intermediate layers which are of 0B in size and so don't increase the size of Docker image`
7. We can use the `docker history` command and the `image name or ID` to see the layers used to create the image
```shell
$ docker history <image_name | image_id> 
```
8. `docker image inspect` command is useful in providing further details on where the layers of our images are located 
```shell
$ docker image inspect <image_id>
```
9. Exercise 1: Understanding the advantage of using caching to see how the build time is reduced due to its use 
   1. Step 1: Create a Dockerfile with the following content
   ```shell
   FROM alpine 
   RUN apk update 
   RUN apk add wget 
    ```
   2. Step 2: Build the docker image using the following command
   ```shell
    $ docker build -t basic-app .
   [+] Building 11.1s (8/8) FINISHED                                                                                                                        
    => [internal] load build definition from Dockerfile                                                                                                0.0s
    => => transferring dockerfile: 181B                                                                                                                0.0s
    => [internal] load .dockerignore                                                                                                                   0.0s
    => => transferring context: 44B                                                                                                                    0.0s
    => [internal] load metadata for docker.io/library/alpine:latest                                                                                    6.2s
    => [auth] library/alpine:pull token for registry-1.docker.io                                                                                       0.0s
    => [1/3] FROM docker.io/library/alpine@sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300                                     1.1s
    => => resolve docker.io/library/alpine@sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300                                     0.0s
    => => sha256:c74f1b1166784193ea6c8f9440263b9be6cae07dfe35e32a5df7a31358ac2060 528B / 528B                                                          0.0s
    => => sha256:8e1d7573f448dc8d0ca13293b1768959a2528ff04be704f1f3d35fd3dbf6da3d 1.49kB / 1.49kB                                                      0.0s
    => => sha256:9b3977197b4f2147bdd31e1271f811319dcd5c2fc595f14e81f5351ab6275b99 2.72MB / 2.72MB                                                      0.9s
    => => sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300 1.64kB / 1.64kB                                                      0.0s
    => => extracting sha256:9b3977197b4f2147bdd31e1271f811319dcd5c2fc595f14e81f5351ab6275b99                                                           0.1s
    => [2/3] RUN apk update                                                                                                                            3.0s
    => [3/3] RUN apk add wget                                                                                                                          0.6s
    => exporting to image                                                                                                                              0.0s
    => => exporting layers                                                                                                                             0.0s
    => => writing image sha256:d2fb533b0ecf8e6acc0c3ed58c892c0a76e6563a86870c1771cb301fb039f3b9                                                        0.0s
    => => naming to docker.io/library/basic-app                                       
    ```
   3. Step 3: Use docker history command to see different layers of image
   ```shell
    $ docker history basic-app
   IMAGE          CREATED              CREATED BY                                      SIZE      COMMENT
    d2fb533b0ecf   About a minute ago   RUN /bin/sh -c apk add wget # buildkit          2.22MB    buildkit.dockerfile.v0
    <missing>      About a minute ago   RUN /bin/sh -c apk update # buildkit            2.27MB    buildkit.dockerfile.v0
    <missing>      About a minute ago   LABEL version=1.0                               0B        buildkit.dockerfile.v0
    <missing>      About a minute ago   LABEL maintainer=arunstiwari                    0B        buildkit.dockerfile.v0
    <missing>      5 weeks ago          /bin/sh -c #(nop)  CMD ["/bin/sh"]              0B        
    <missing>      5 weeks ago          /bin/sh -c #(nop) ADD file:df538113122843069…   5.33MB

    ```
   4. Step 4: Run the build again without making any changes
   ```shell
    $ docker build -t basic-app . 
   [+] Building 1.9s (7/7) FINISHED                                                                                                                         
    => [internal] load build definition from Dockerfile                                                                                                0.0s
    => => transferring dockerfile: 37B                                                                                                                 0.0s
    => [internal] load .dockerignore                                                                                                                   0.0s
    => => transferring context: 34B                                                                                                                    0.0s
    => [internal] load metadata for docker.io/library/alpine:latest                                                                                    1.8s
    => [1/3] FROM docker.io/library/alpine@sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300                                     0.0s
    => CACHED [2/3] RUN apk update                                                                                                                     0.0s
    => CACHED [3/3] RUN apk add wget                                                                                                                   0.0s
    => exporting to image                                                                                                                              0.0s
    => => exporting layers                                                                                                                             0.0s
    => => writing image sha256:d2fb533b0ecf8e6acc0c3ed58c892c0a76e6563a86870c1771cb301fb039f3b9                                                        0.0s
    => => naming to docker.io/library/basic-app            
    ```
   + The output shows that the build is done using the layers stored in the Docker image cache, thereby speeding up our build 
   6. Let us assume that we require to install `curl` package as part of our image creation. 
      1. Let us add the following line to the Dockerfile from Step 1:
      ```shell
      FROM alpine 
      RUN apk update 
      RUN apk add wget curl 
      ```
   7. Let us build the image again using the following command
   ```shell
    $ docker build -t basic-app .
   [+] Building 2.7s (7/7) FINISHED                                                                                                                         
    => [internal] load build definition from Dockerfile                                                                                                0.0s
    => => transferring dockerfile: 186B                                                                                                                0.0s
    => [internal] load .dockerignore                                                                                                                   0.0s
    => => transferring context: 34B                                                                                                                    0.0s
    => [internal] load metadata for docker.io/library/alpine:latest                                                                                    1.8s
    => [1/3] FROM docker.io/library/alpine@sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300                                     0.0s
    => CACHED [2/3] RUN apk update                                                                                                                     0.0s
    => [3/3] RUN apk add wget curl                                                                                                                     0.8s
    => exporting to image                                                                                                                              0.0s
    => => exporting layers                                                                                                                             0.0s
    => => writing image sha256:16eb2d31e2ea5a5788cef62c7e11a26a8cc3304c2d0bcc764c1750e238b7bbf2                                                        0.0s
    => => naming to docker.io/library/basic-app
    ```
   8. Execute the `docker images` command and we can see that image named `<none>` which is a dangling image 
      1. `Note: Dangling images, represented by <none> in our image list, are caused when a layer has no relationship to any image on our system `
      2. We can remove the dangling image using the following command
      ```shell
       $ docker image prune 
      ```


## Exercise 2 -  Increase Build Speed and Reduce Layers 
### Optimizing the Build Speed and Image Size 
1. Let us first clear up all the images on your system using the following command
```shell
$ dockr rmi -f $(docker images -a -q)
```
 + `-f - this option force any removals needed`
 + `-a -> show all running and stopped containers`
 + `-q -> show the container image hash value and nothing else`
3. Create a Dockerfile with the following content
```shell
FROM alpine 
RUN apk update 
RUN apk add wget curl

RUN wget -O test.txt https://github.com/arunstiwari/xxxx/100MB.bin

CMD mkdir /var/www/
CMD mkdir /var/www/html/

WORKDIR /var/www/html/

COPY Dockerfile.tar.gz /tmp/ 
RUN tar -zxvf /tmp/Dockerfile.tar.gz -C /var/www/html/
RUN rm /tmp/Dockerfile.tar.gz

RUN cat Dockerfile
```
4. Create a `TAR` file to be added to our image using the following command
```shell
$ tar zcvf Dockerfile.tar.gz Dockerfile
```
5. Build a new image using the following command
6. 
```shell
$ time docker build -t basic-app . 
```
7. `time` command at the start of the code allow us to gauge the time it takes to build our image 
8. Run the `docker history` command
```shell
$ docker history basic-app
```
9. We can see that there are around `12 layers`. Let us try to reduce the layer by combining the `two RUN commands` and `two mkdir command` 
```shell
FROM alpine 
RUN apk update && apk add wget curl 

RUN wget -O test.txt https://github.com/arunstiwari/xxxx/100MB.bin

CMD mkdir -p /var/www/html/

WORKDIR /var/www/html/

COPY Dockerfile.tar.gz /tmp/ 
RUN tar -zxvf /tmp/Dockerfile.tar.gz -C /var/www/html/
RUN rm /tmp/Dockerfile.tar.gz

RUN cat Dockerfile
```
10. Executing the `docker history` command shows that number of layers have been reduced from `12 to 9`. 
11. Let us further combine the `COPY, RUN and unzip ` command using the `ADD` command without needing to run the lines that unzip and remove the .tar file 
12. The modified Dockerfile looks like as below:
```shell
FROM alpine 
RUN apk update && apk add wget curl 

RUN wget -O test.txt https://github.com/arunstiwari/xxxx/100MB.bin

CMD mkdir -p /var/www/html/

WORKDIR /var/www/html/

ADD Dockerfile.tar.gz /var/www/html/ 

RUN cat Dockerfile
```
13. Let us run the `docker history` command, and this time we can see that image layers have been reduced from 9 to 8 
14. There is still one issue with the building of this image, which is the `apk update` and `installing of wget and curl` as well as `downloading the content from website` takes a lot of time
    1. This can work if we have to build the image one or two times, but if we have to repeatedly build this, the better approach will be to abstract a base image which will cover the above things and then child image can inherit from this base image 
    2. Let us create a new directory called `base-image` and within this create a `Dockerfile` with the following content
    ```shell
    FROM alpine 
    RUN apk update && apk add wget curl

    RUN wget -O test.txt https://github.com/arunstiwari/xxxx/100MB.bin  
    ```
    3. Build the new base image from this `Dockerfile` as shown below
    ```shell
    $ docker build -t basic-base . 
    ```
    4. Next remove the three lines from the initial Dockerfile and replace it with the following content
    ```shell
    FROM basic-base
    CMD mkdir -p /var/www/html/
    
    WORKDIR /var/www/html/
    
    ADD Dockerfile.tar.gz /var/www/html/
    
    RUN cat Dockerfile
    ```
    5. If we execute the docker build command as shown below, we can see that it runs lot quicker 
    ```shell
    $ time docker built -t basic-app . 
    ```
    6. Let us execute the `docker history ` command
    ```shell
     $ docker history basic-app 
    
    IMAGE          CREATED          CREATED BY                                      SIZE      COMMENT
    eb4b4b85311f   2 minutes ago    RUN /bin/sh -c cat Dockerfile # buildkit        0B        buildkit.dockerfile.v0
    <missing>      2 minutes ago    ADD Dockerfile.tar.gz /var/www/html/ # build…   439B      buildkit.dockerfile.v0
    <missing>      2 minutes ago    WORKDIR /var/www/html/                          0B        buildkit.dockerfile.v0
    <missing>      2 minutes ago    CMD ["/bin/sh" "-c" "mkdir -p /var/www/html/…   0B        buildkit.dockerfile.v0
    <missing>      2 minutes ago    LABEL version=1.0                               0B        buildkit.dockerfile.v0
    <missing>      2 minutes ago    LABEL maintainer=arunstiwari                    0B        buildkit.dockerfile.v0
    <missing>      10 minutes ago   RUN /bin/sh -c wget -O test.txt https://gith…   196kB     buildkit.dockerfile.v0
    <missing>      10 minutes ago   RUN /bin/sh -c apk update && apk add wget cu…   6.54MB    buildkit.dockerfile.v0
    <missing>      10 minutes ago   LABEL version=1.0                               0B        buildkit.dockerfile.v0
    <missing>      10 minutes ago   LABEL maintainer=arunstiwari                    0B        buildkit.dockerfile.v0
    <missing>      5 weeks ago      /bin/sh -c #(nop)  CMD ["/bin/sh"]              0B        
    <missing>      5 weeks ago      /bin/sh -c #(nop) ADD file:df538113122843069…   5.33MB

    ```
    7. Let us run the container using the following command
    ```shell
    $ docker run -it basic-app sh 
    ```
    7. Use the vi text editor to create a new text file called `prod_test_data.txt` and add some text to it like `This is test file`
    8. Exit out of the container and then execute the command 
    ```shell
     $ docker ps -a 
    ```
    9. Run the `docker commit` command with the `container ID` to create a new image that will include all those changes
    ```shell
     $ docker commit <container_id> basic-app-test    
    ```
    10. Next execute the `docker history basic-app-test` command and we can see that an extra layer where we added the sample production data is showing in the output
    ```shell
    $ docker history basic-app-test
    ddafde6292cf   9 seconds ago    sh                                              54B       
    eb4b4b85311f   3 minutes ago    RUN /bin/sh -c cat Dockerfile # buildkit        0B        buildkit.dockerfile.v0
    <missing>      3 minutes ago    ADD Dockerfile.tar.gz /var/www/html/ # build…   439B      buildkit.dockerfile.v0
    <missing>      3 minutes ago    WORKDIR /var/www/html/                          0B        buildkit.dockerfile.v0
    <missing>      3 minutes ago    CMD ["/bin/sh" "-c" "mkdir -p /var/www/html/…   0B        buildkit.dockerfile.v0
    <missing>      3 minutes ago    LABEL version=1.0                               0B        buildkit.dockerfile.v0
    <missing>      3 minutes ago    LABEL maintainer=arunstiwari                    0B        buildkit.dockerfile.v0
    <missing>      12 minutes ago   RUN /bin/sh -c wget -O test.txt https://gith…   196kB     buildkit.dockerfile.v0
    <missing>      12 minutes ago   RUN /bin/sh -c apk update && apk add wget cu…   6.54MB    buildkit.dockerfile.v0
    <missing>      12 minutes ago   LABEL version=1.0                               0B        buildkit.dockerfile.v0
    <missing>      12 minutes ago   LABEL maintainer=arunstiwari                    0B        buildkit.dockerfile.v0
    <missing>      5 weeks ago      /bin/sh -c #(nop)  CMD ["/bin/sh"]              0B        
    <missing>      5 weeks ago      /bin/sh -c #(nop) ADD file:df538113122843069…   5.33MB

    ```
    11. We can see a new layer has been added to the existing layer 


## Create Base Docker Images 
### Creating base docker image from the existing basic-app image 
1. Execute the following `docker run` command to run the container and also log in to it 
```shell
$ docker run -it basic-app sh 
```
2. Next let us run the `tar command ` on the running container to create a backup of the system
   1. To limit the information you have in the new image, exclude the `.proc, .tmp, .mnt, .dev and .sys` directories and create everything under the `basebackup.tar.gz` file 
   ```shell
    $ tar -czf basebackup.tar.gz --exclude=backup.tar.gz --exclude=proc --exclude=tmp --exclude=mnt --exclude=dev --exclude=sys /
    ```
   2. To ensure that you have the data in your backup `basebackup.tar.gz`, run the `du command` as shown below
   ```shell
    $ du -sh basebackup.tar.gz
    ```
   3. Copy the `tar` file onto your development system with the `docker cp` command, using the container ID of the running container
   4. Following command will copy the tar to `/tmp` directory
   ```shell
    $ docker cp <container_id>:/var/www/html/basebackup.tar.gz /tmp/
    ```
   5. Next create a new image with the `docker import` command as shown below
   ```shell
    $ cat /tmp/basebackup.tar.gz | docker import -  mynew-base 
    ```
   6. Verify whether the new image has been created or not using the following command
   ```shell
    $ docker images mynew-base 
    ```
   7. Execute the `docker history` command 
   ```shell
    $ docker history mynew-base 
    ```
   8. This shows the way to create a new base image 
   
## Docker image naming and Tagging 
### Tags 
+ Tag is a label on the Docker image and should provide the user of the image with some useful information about the image or version of the image they are using 
+ There are two main methods for naming and tagging the Docker image
+ First Option 
  + You can use the `docker tag` command
  + docker tag format is as shown below
  ```shell
    $ docker tag <source_repository_name>:<tag> <target_repository_name>:tag
    ```
+ Second Option 
  + You can use the `-t option` when you build your image from a Dockerfile
  + When we name the image using the `docker build` command, the Dockerfile used will create your source, and then use the `-t` option to name the tag 
  + Format of this command is as shown below
  ```shell
    $ docker build -t <target_repository_name>:tag Dockerfile .
    ```
+ If we are pushing our image to a Docker hub, we also need to prefix our repository name with the Dockerhub username as shown below
```shell
$ docker build -t <dockerhub_user>/<target_repository_name>:tag Dockerfile 
```

### Exercise - Tagging Docker images  
1. Execute the following command
```shell
$ docker pull busybox 
```
2. Next execute the `docker images` command 
```shell
$ docker images 
```
3. Name and tag the image using the `tag` command as shown below
```shell
$ docker tag <image_id> new_busy_box:ver_1
```
4. Use the repository name and image tag to create a new version of the image
```shell
$ docker tag new_busy_box:ver_1 arunstiwari/busybox:ver_1.1
```
5. Run the `docker images command` to see the list of the image 
```shell
$ docker images 
```

### Exercise - Tagging the image during the image build process 
1. Create a basic image using Dockerfile and the `-t option` of the `docker build` to name and tag the image 
```shell
$ echo "FROM new_busybox:ver_1" > Dockerfile 
```
2. Execute the `docker build` command 
```shell
$ docker build -t new_busybox:ver_2 .
```
3. Execute the `docker images` command 
```shell
$ docker images 
```

### Automating the tagging using the git command 
1. Use the following command to automate the tagging.
```shell
$ docker build -t basic-app:$(git log -1 --format=%h) . 
```
2. Here we are making use of the `git commit id` as the `tagging version` 
3. Let us see how we can automate the tagging in the Dockerfile
4. Let us create a `Dockerfile` with the content as shown below
```shell
FROM basic-base 

ARG GIT_COMMIT=unknown
LABEL git-commit=$GIT_COMMIT 

CMD mkdir -p /var/www/html/

ADD Dockerfile.tar.gz /var/www/html/

RUN cat Dockerfile
```
5. Build the image using the `--build-arg option` with the `GIT_COMMIT` argument, which is now equal to the `git commit` hash value 
```shell
$ docker build -t basic-app --build-arg GIT_COMMIT=$(git log -1 --format=%h) . 
```

## Storing and Publishing Your Docker images 
### Storing Docker Image 
1. Docker repository is the place where we can store the Docker images. 
2. Repository are of public, private type. 
3. Docker Hub is the public repository for docker images where the companies and developers host their open-source images 
4. Other repository example can be `AWS ECR`, `GCR (Google Container Registry), etc.

### Exercise - Transporting Docker Images 

1. Use Case -  There are issues with the firewalls or other security measures on your network and we are required to copy an image directly from one system to another 
2. Move an image from one system to another system without using the registry 
3. Execute the `docker save` command with the `-o` option to save the image you created earlier 
```shell
$ docker save -o /tmp/basic-app.tar arunstiwari/basic-app:1.0.0 
```
4. We can see the packaged-up image in the `/tmp` directory. We are using the `.tar` as the extension of your filename as the `save` command creates a `tar` file of the image 
5. Use the `du` command to verify that the `basic-app.tar` file has data in it. 
```shell
$ du -sh /tmp/basic-app.tar 
```
6. Next we can move the image using the tool like `rsync, scp or cp`
7. Once we have moved the `tar file` to the other system, we can load the new image back as a Docker image using the `docker load` command 
```shell
$ docker load -i /tmp/basic-app.tar 
```


### Storing and Deleting Docker Images in Docker Hub 
1. First you tag the `docker image ` using your repository name as shown below
```shell
$ docker tag basic-app arunstiwari/basic-app:ver1 
```
2. Next login to the docker using the `docker login` command
```shell
$ docker login 
```
3. Next push your image to the repository using the `docker push` command
```shell
$ docker push arunstiwari/basic-app:ver1
```
4. You can login to the `DockerHub` and can see the new image pushed in your repository. 
5. You can delete the `repository and image` from the `Dockerhub` directly 

## Creating a Local Docker Registry
### Setting up local domain 
1. To setup your domain, add a domain for your local registry to your system hosts file 
2. On a Windows system, you will need to access the hosts file at 
```shell
C:\Windows\System32\drivers\etc\hosts 
```
3. On Linux or Mac, the host file is located at `/etc/hosts`
4. Open the `hosts` file and add the following line to the file, which will allow us to use the `dev.docker.local` domain instead of using localhost for your local registry 
```shell
127.0.0.1 dev.docker.local 
```
5. Pull the latest `registry` image down from the DockerHub 
```shell
$ docker pull registry 
```
6. Use the following command to run the registry container. 
```shell
$ docker run -d -p 5000:5000 --restart=always --volume <directory_name>:/var/lib/registry --name registry registry
```
7. We need the following command while tagging the image 
```shell
$ docker tag basic-app dev.docker.local:5000/basic-app:ver1
```
8. Now if we have to push the `docker image` to this local registry use the following command
```shell
$ docker push dev.docker.local:5000/basic-app:ver1
```
8. To pull the image from the local registry, use the following command
```shell
$ docker pull dev.docker.local:5000/basic-app:ver1
```
9. To delete the image from the local registry, use the following command
```shell
$ docker image remove dev.docker.local:5000/basic-app:ver1
```