---
title: 把 Unix 的 Domain Socket 转成可本地访问的 TCP 端口
date: 2017-10-31 15:27:33
tags:
- Docker
- Socket
---

使用管道命令的做法：
----------

```bash
socat -d TCP-LISTEN:2376,range=127.0.0.1/32,reuseaddr,fork UNIX:/var/run/docker.sock
```
 

简洁的做法（使用守护进程而不是使用管道命令）
----------------------

```bash
docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 127.0.0.1:2375:2375 bobrik/socat TCP-LISTEN:2375,fork UNIX-CONNECT:/var/run/docker.sock
```

从容器内往外看的主机，对应外部主机就是 127.0.0.1的端口
ping docker.for.mac.localhost

通常结果是192.168.65.1。

值得参考的文：
1. http://brieflyx.me/2015/linux-tools/socat-introduction/