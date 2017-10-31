---
title: Docker in Docker
date: 2017-10-31 15:11:53
tags:
- Docker 
- ubuntu
---


&emsp;&emsp;以下步骤未完全成功：
## 映射多端口启动 ubuntu 容器##

```
docker run --privileged=true -it -p 8080:8080 -p 80:80 -v /var/run/docker.sock:/var/run/docker.sock ubuntu /bin/bash
```
## 容器内再安装容器并启动： ##
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
