---
title: Docker in Docker
date: 2017-10-31 15:11:53
tags:
- Docker 
- ubuntu
---
## 官方博客里提供的DinD 的解决方案 ##

&emsp;&emsp;在遥远的年代，需要很多其他的东西来辅助生成一个 docker in docker 的例子，但如今一个 --privileged 的 flag 就搞定一切了。

&emsp;&emsp;当前版本正确的 DinD 方案，是这样启动一个 DinD 容器:

```bash
 docker run --privileged -d docker:dind
```
&emsp;&emsp;exec 进入这个容器：

```bash
docker exec -it agitated_curran /bin/sh
```

&emsp;&emsp;然后在容器里再跑一个容器：

```bash
docker run -it ubuntu /bin/bash
```

##Docker in Docker 为什么难？##

这有一篇博客[《~jpetazzo/Using Docker-in-Docker for your CI or testing environment? Think twice.》][1]，专门解释这个问题。总体看下来，有方便的地方，但也会让 Linux 安全机制和文件系统产生混乱。

&emsp;&emsp;~~因为某个特殊的 Unix domain 套接字在容器内是不可复用的。~~

##以下步骤未完全成功##

&emsp;&emsp;映射多端口启动 ubuntu 容器：

```
docker run --privileged=true -it -p 8080:8080 -p 80:80 -v /var/run/docker.sock:/var/run/docker.sock ubuntu /bin/bash
```
&emsp;&emsp;容器内再安装容器并启动：

```bash
apt-get update

apt-get -y install sudo

sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update

sudo apt-get -y install docker-ce

service docker start

docker run hello-world
```


  [1]: http://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/
