author: Arun Tiwari
summary: Docker Workshop 
id: lab2
layout: page
title: "Docker Workshop"
permalink: /labs/docker-beginner
categories: codelab,markdown
environments: Web
status: Published
feedback link: https://github.com/arunstiwari/docker-workshop-lab
analytics account: Google Analytics ID

# Docker Basics 

## Running Docker Containers 
Duration: 0:07:00

###  Running Hello World Containers
1. Execute the following command in the terminal
```shell
$ docker run hello-world 
```
2. Next execute the following command
```shell
$ docker ps 
```
3. View the docker images in the local system using the following command
```shell
$ docker images 
```

## Managing Docker Containers
### Docker container Management basic Commands 
1. In the container journey, we require to pull, start, stop and remove the container from our environments
2. Look at how to use the `docker pull` command which fetches the docker image from the docker repository 
```shell
$ docker pull ubuntu:18.04 


```
3. In the output one can see that Docker is downloading all the layers of the base image 

4. We can see the images on our local system using the following command
```shell
$ docker images 
```
6. We can also inspect the image using the following command
```shell
$ docker inspect <image_id> 
```
7. Now let us run the docker image using the following command
```shell
$ docker run -d ubuntu:18.04 
```

8. Let us check the status of the container using the following command
```shell
$ docker ps -a  
```
9. We can see that the container is `stopped and exited`. This is primarily because the primary process inside the container is `/bin/bash` which is a shell. 
   1. Bash shell cannot run without being executed in an interactive mode since it expects text input and output from a user 
10. Let's run the `docker run` command again in an interactive mode using the `-i -t ` flags 
```shell
$ docker run -i -t -d --name ubuntu1 ubuntu:18.0.4
```
    1. -t flag is used to allocate a `psuedo-tty` handler to the container. Essentially `psuedo-tty` handler will link the `user's terminal` to the interactive bash shell running inside the container
12. Execute the following command again to check the container status 
```shell
$ docker ps -a
```
13. Now we have got the container up and running, and we can run the commands inside this container using the `exec` command 
```shell
$ docker exec -it ubuntu1 /bin/bash 
```
14. You are inside the container. We may have limited tools in this container as `container is supposed to be minimal in comparison to vm`
15. Let us create a file `hello-world.txt` with following content inside the container
```shell
# echo "Hello World from ubuntu1" > hello-world.txt 
```
16. Next exit out of the container by typing `exit` on the command prompt
 
17. Let us view the `hello-world.txt` file without even entering the `container ubuntu1` using the following command
```shell
$ docker exec -it ubuntu1 cat hello-world.txt 
```
18. Next let us create a second `ubuntu` container with name as `ubuntu2`
```shell
$ docker run -d -i -t --name ubuntu2 ubuntu:18.0.4
```
19. Stop the `ubuntu2` container
```shell
$ docker stop ubuntu2 
```
20. See the docker process status using the following command
```shell
$ docker ps -a
```
21. Use the `docker start or docker restart` command to restart the container instance
```shell
$ docker start ubuntu2 
```
22. Verify the container status using the following command
```shell
$ docker ps 
```
23. Let us finally remove the container using the following command
```shell
$ docker stop ubuntu2
$ docker rm <container_name> or <container_id>
```
24. We can delete the docker image using the following command
```shell
$ docker rmi <image_id>
```
25. To streamline the process of cleaning up of your environments, Docker provides a prune command that will automatically remove old containers and base images 
```shell
$ docker system prune -fa 
```


