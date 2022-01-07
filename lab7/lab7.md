## Docker Networking 
### Introduction 
1. Container networking understanding can be classified into two groups:
   1. Underlay networking
      1. It refers to the networking on the container host 
   2. Overlay networking
      1. It refers to the networking between containers on the same host or within different clusters
2. Docker supports many different types of network configuration out of the box that can be customized to suit the needs of your infrastructure and deployment strategy.
3. By default, Docker operates in a `bridge network mode`
4. A `bridge network` creates a single network interface on the host that acts as a bridge to another subnet configured on the host 
   1. All incoming (ingress) and outgoing (egress) network traffic travel between the container subnet and the host using the `bridge` network interface

## Exercise 1 
### Getting started with Docker networking
1. List networks that are currently configured in Docker environment using the following command:
```shell
$ docker network ls 
NETWORK ID     NAME                                DRIVER    SCOPE
5a2f2e16e2ba   bridge                              bridge    local
df4f98884a19   host                                host      local
b4972345c74e   none                                null      local

```
2. When creating a container using Docker without specifying a network or networking driver, Docker will create the container using a `bridge` network 
3. This network exists behind a `bridge` network interface configured in host OS 
4. `Note: There is no docker0 bridge on macOS` -  Because of the way networking is implemented in Docker Desktop for Mac, we cannot see `docker0` interface on the host. This interface is actually within the `virutal machine` 
5. Execute the command in the terminal, which will output all the network interfaces available in the environment 
```shell
$ ifconfig 
```
6. One of the network interface is the `docker0` which is a bridge interface 
7. Let us start the nginx container using the following command
```shell
$ docker container run -d --name webserver1 -p 8900:80  nginx:latest 
```
8. Next inspect the `webserver1` container using the following command
```shell
$ docker inspect webserver1
...
"Networks": {
                "bridge": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "5a2f2e16e2ba7402e111f31da575d6824be8aa79b5089d0c9b7820c81b75e218",
                    "EndpointID": "b6b7a00dc63b2cc40d20ab5d8ec8852a54f0796b774defff0ef39774bee96daf",
                    "Gateway": "172.17.0.1",
                    "IPAddress": "172.17.0.3",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:ac:11:00:03",
                    "DriverOpts": null
                }
            }
```
9. In the output the `NetworkID` matches the `ID` of the `default bridge network` when we run the command `docker network ls` 
10. Let us launch the another `nginx container ` using the following command
```shell
$ docker container run -d --name webserver2 -p 9900:80  nginx:latest
```
11. Let us enter the `webserver1 container` using the following command
```shell
$ docker exec -it webserver1 /bin/bash
```
12. Next let us install `ping and curl` utilty in the container which is required to ping to other container 
```shell
$ apt-get update 
$ apt-get install -y inetutils-ping curl 
```
13. Next let us ping the `webserver2 container` from inside `webserver1 container` using the following command
```shell
root@ec8aa6b14627:/# ping 172.17.0.4
PING 172.17.0.4 (172.17.0.4): 56 data bytes
64 bytes from 172.17.0.4: icmp_seq=0 ttl=64 time=0.524 ms
64 bytes from 172.17.0.4: icmp_seq=1 ttl=64 time=0.409 ms
64 bytes from 172.17.0.4: icmp_seq=2 ttl=64 time=0.331 ms
64 bytes from 172.17.0.4: icmp_seq=3 ttl=64 time=0.429 ms
^C--- 172.17.0.4 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.331/0.423/0.524/0.069 ms
```
14. Let us use `curl ` command to access the `nginx webserver` 
```shell
$ curl 172.17.0.4
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
15. The network connectivity between container instances using the native Docker bridge network 
16. However, when we deploy containers at scale, there is no easy way to know which IP address in the Docker network belongs to which container

## Native Docker DNS 
### Docker DNS 
1. Every time a new container instance terminates or respawns, Docker will give that container a new IP address
2. Due to this reason, in real production environment, we can't rely on containers having consistent IP addresses that they can use to talk to each other 
3. Like in traditional infrastructure scenario, where we have a DNS server that has `name-ip address mapping`, Docker too has a native DNS 
4. Docker DNS doesn't work on the default `Docker bridge` network, hence other networks must first be created to use it 

### Exercise - Working with Docker DNS 
1. Create a docker network `dnsnet` using the following command
```shell
$ docker network create dnsnet --subnet 192.168.54.0/24 --gateway 192.168.54.1 
a4fd1ed386bf5e2d23c3978fbec185fc0cf1de995d24648b79639ca3999ef719
```
2. Simply using the `docker network create dnsnet` command will create a network with a Docker allocated subnet and gateway 
3. See the local docker network using the following command
```shell
$ docker network ls  
NETWORK ID     NAME                                DRIVER    SCOPE
5a2f2e16e2ba   bridge                              bridge    local
a4fd1ed386bf   dnsnet                              bridge    local
df4f98884a19   host                                host      local
b4972345c74e   none                                null      local
```
4. Next let us inspect the `dnsnet` network
```shell
$ docker network inspect dnsnet
... 
{
        "Name": "dnsnet",
        "Id": "a4fd1ed386bf5e2d23c3978fbec185fc0cf1de995d24648b79639ca3999ef719",
        "Created": "2022-01-06T10:22:40.655890919Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "192.168.54.0/24",
                    "Gateway": "192.168.54.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
     ...   
```
5. Next let us execute the `docker run` command to start a new `alpinedns1` container within this network 
```shell
$ docker run -itd --network dnsnet --network-alias alpinedns1 --name alpinedns1 alpine:latest 
```
6. Similarly start the second `alpinedns2` container too 
```shell
$ docker run -itd --network dnsnet --network-alias alpinedns2 --name alpinedns2 alpine:latest
```
7. `Note: Difference between the -network-alias and --name flag is that --name flag is used to give the contaier a logical name to make it easy to start, stop and restart the container, whereas network-alias flag however is used to create a custom DNS entry for the container`
8. Use the `docker ps` command to see the container status 
```shell
$ docker ps 
CONTAINER ID   IMAGE                           COMMAND       CREATED          STATUS          PORTS     NAMES
25fe94f6068f   alpine:latest                   "/bin/sh"     6 seconds ago    Up 5 seconds              alpinedns2
09d3ee4e26ab   alpine:latest                   "/bin/sh"     43 seconds ago   Up 42 seconds             alpinedns1
```
9. Use `docker inspect ` command to verify that the IP addresses of the container instances are from within the range specified 
```shell
$ docker inspect alpinedns1
```
10. Run the `docker exec` command to access the shell in the `alpinedns1` container
```shell
$ docker exec -it alpinedns1 /bin/sh
/ # 
```
11. Next ping the `alpinedns2` container using the following command
```shell
/ # ping alpinedns2 
PING alpinedns2 (192.168.54.3): 56 data bytes
64 bytes from 192.168.54.3: seq=0 ttl=64 time=0.316 ms
64 bytes from 192.168.54.3: seq=1 ttl=64 time=0.358 ms
64 bytes from 192.168.54.3: seq=2 ttl=64 time=0.332 ms
^C
--- alpinedns2 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.316/0.335/0.358 ms
```
12. You can see the entry of the `hosts ` file 
```shell
/ # cat /etc/hosts 
127.0.0.1	localhost
::1	localhost ip6-localhost ip6-loopback
fe00::0	ip6-localnet
ff00::0	ip6-mcastprefix
ff02::1	ip6-allnodes
ff02::2	ip6-allrouters
192.168.54.2	09d3ee4e26ab
```
13. Now exit out of the `alpinedns1 container` and try to enter the `alpinedns2 container and ping the `alpinedns1` container
14. At the end stop and remove all the resources including the network 

## Docker Network Drivers 
### Docker Native Network Drivers
1. Docker provides network drivers that enable flexibility in how containers are created and deployed 
2. These network drivers allow containerized applications to run in almost any networking configuration that is supported directly on bare metal or virtualized servers 

### Types of Network Drivers
1. bridge
   1. Is the default network that Docker will run containers in 
   2. In a bridge network containers have network connectivity to other containers in the bridge subnet as well as outbound internet connectivity
   3. Generally used for simple TCP services that only expose simple ports or require communication with other containers that exist on the same host 
2. host 
   1. Containers running in the `host` networking mode have direct access to the host machine's network stack 
   2. This means that any ports that are exposed to the container are also exposed to the same ports on the host machine running the containers 
   3. Container also has visibility of all physical and virtual network interfaces running on the host 
   4. Generally preferred when running container instances that consume lots of bandwidth or leverage multiple protocols 
3. none 
   1. Provides no network connectivity to containers deployed in this network
   2. Container instances that are deployed in the `none` network only have a loopback interface and no access to the other network resources at all 
   3. Generally applications that operate on storage or disk workloads and don't require network connectivity are deployed on containers using the `none` network mode 
   4. Containers that are segregated from network connectivity for security reasons may also be deployed using this network driver
4. macvlan
   1. Used in scenarios where containerized applications require a MAC address and direct network connectivity to the underlay network
   2. Using a `macvlan` network, Docker will allocate a MAC address to your container instance via a physical interface on the host machine
   3. This makes your container appear as a physical host on the deployed network segment 
   4. Many cloud environments, such as AWS, Azure, do not allow `macvlan` networking to be configured on container instances 
   5. Using `macvlan` networking can easily lead to IP address exhaustion or IP address conflicts if not configured correctly.
   6. Generally used in very specific scenarios such as applications that monitor network traffic modes or other network intensive workloads
5. Overlay
   1. It is the mode used by Docker to handle the networking with a Swarm cluster 
   2. When a cluster is defined between the nodes, Docker will use the physical network linking the nodes together to define a logical network between containers running on the nodes 
   3. This allows containers to talk directly each other between cluster nodes 

## Lab 3 - Explore Docker Network
### Bridge network exploration
1. Let us inspect the `bridge` network by running the following command
```shell
$ docker network inspect bridge 
```
2. Observe the key parameters like `Scope, Subnet, and Gateway`.
3. From the output we can see that `Scope: Local`. This indicates that network is not shared between hosts in a Docker swarm cluster 
4. The `Subnet` value of this network under the `Config` section is `172.17.0.0/16`
5. This network is tied to the `host interface docker0`, which will serve as the `bridge` interface for the network

### Host network exploration
1. Let us inspect the `host` using the following command
```shell
$ docker network inspect host 

[
    {
        "Name": "host",
        "Id": "df4f98884a1910479f593f871624ca142e8230745d026ce4a8ab3b62c627899e",
        "Created": "2021-05-13T05:53:37.982985625Z",
        "Scope": "local",
        "Driver": "host",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": []
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
```
2. We can see that `driver` value is `host` and the `scope` is `local`
3. Execute the following command to run the container in `host` network
```shell
$ docker run -itd --network host --name hostnet1 alpine:latest 
```
4. Next inspect the container `hostnet1` using the following command
```shell
$ docker inspect hostnet1
...
"Networks": {
                "host": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "df4f98884a1910479f593f871624ca142e8230745d026ce4a8ab3b62c627899e",
                    "EndpointID": "e090df5f3735817c0f8aeb660f3aa370bf46ac119493356f4380fcc3fbbf8363",
                    "Gateway": "",
                    "IPAddress": "",
                    "IPPrefixLen": 0,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "",
                    "DriverOpts": null
                }
            }
...            
```
5. We can see that Docker does not assign an IP address or gateway to the container instance since it shares all network interfaces with the host machine directly
6. Let us enter the container using `exec` command as shown below
```shell
$ docker exec -it hostnet1 /bin/sh 
```
7. Next execute the `ifconfig` command to list the network interfaces in the container 
```shell
/ # ifconfig 
... 

docker0   Link encap:Ethernet  HWaddr 02:42:84:09:FD:A9
          inet addr:172.17.0.1  Bcast:172.17.255.255  Mask:255.255.0.0
          inet6 addr: fe80::42:84ff:fe09:fda9/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:105011 errors:0 dropped:0 overruns:0 frame:0
          TX packets:480487 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:794717551 (757.9 MiB)  TX bytes:525545774 (501.1 MiB)

eth0      Link encap:Ethernet  HWaddr 02:50:00:00:00:01
          inet addr:192.168.65.3  Bcast:192.168.65.255  Mask:255.255.255.0
          inet6 addr: fe80::50:ff:fe00:1/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:1096556 errors:0 dropped:0 overruns:0 frame:0
          TX packets:898551 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:983081748 (937.5 MiB)  TX bytes:847493950 (808.2 MiB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:52 errors:0 dropped:0 overruns:0 frame:0
          TX packets:52 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
...          
```
8. Let us understand more the shared networking model in Docker 
9. Start `nginx container` in host network mode using the following command
```shell
$ docker run -itd --network host --name hostnet2 nginx:latest 
```
10. Navigate to the `http://localhost:80` using browser to see the `nginx home page`
11. We can see that while starting the `nginx container` we did not require to do port mapping in `host network`
12. Let us start the another instance of `nginx container` in the same way as above
```shell
$ docker run -itd --network host --name hostnet3 nginx:latest 
```
13. We can see from the `docker ps -a` command that the second nginx container has exited and if we see the log of the `second nginx container` we can see that it stopped due to port unavailability
```shell
$ docker logs hostnet3
...
022/01/06 15:33:41 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
2022/01/06 15:33:41 [emerg] 1#1: bind() to [::]:80 failed (98: Address already in use)
nginx: [emerg] bind() to [::]:80 failed (98: Address already in use)
2022/01/06 15:33:41 [notice] 1#1: try again to bind() after 500ms
2022/01/06 15:33:41 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
2022/01/06 15:33:41 [emerg] 1#1: bind() to [::]:80 failed (98: Address already in use)
nginx: [emerg] bind() to [::]:80 failed (98: Address already in use)
2022/01/06 15:33:41 [notice] 1#1: try again to bind() after 500ms
2022/01/06 15:33:41 [emerg] 1#1: still could not bind()
nginx: [emerg] still could not bind()
```

### None network exploration
1. Investigate the `none` network next 
```shell
$ docker network inspect none
[
    {
        "Name": "none",
        "Id": "b4972345c74ee4dd74cb50e3248ee6673d50dbeee8760125e8a951d71b97b9a2",
        "Created": "2021-05-13T05:53:37.782835167Z",
        "Scope": "local",
        "Driver": "null",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": []
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
```
2. Similar to the `host` network, the `none` network is mostly empty
3. The value of `driver` is `null`
4. Let us start the `alpine container` in the `none network`
```shell
$ docker run -itd --network none --name nonenet alpine:latest 
```
5. Let us inspect the `nonenet` container
```shell
$ docker inspect nonenet
...
"Networks": {
                "none": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "b4972345c74ee4dd74cb50e3248ee6673d50dbeee8760125e8a951d71b97b9a2",
                    "EndpointID": "1268790577c3ddf81107c8c5ea200ee9b2fa0aa5f768b221a36cb06fa27429a3",
                    "Gateway": "",
                    "IPAddress": "",
                    "IPPrefixLen": 0,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "",
                    "DriverOpts": null
                }
            }
```
6. The output reveals that there is `no ip address and the gateway`
7. Let us enter the container using the following command
```shell
$ docker exec -it nonenet /bin/sh 
```
8. From within the container, let us execute the following command and we can see there is only one `loopback interface`
```shell
/ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: tunl0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
3: ip6tnl0@NONE: <NOARP> mtu 1452 qdisc noop state DOWN qlen 1000
    link/tunnel6 00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00 brd 00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00
```
9. Let us test the lack of network connectivity using the `ping` utilty, by trying to ping the Google DNS servers located at the IP address `8.8.8.8`
```shell
/ # ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8): 56 data bytes
ping: sendto: Network unreachable
```

### macvlan network exploration
1. 




