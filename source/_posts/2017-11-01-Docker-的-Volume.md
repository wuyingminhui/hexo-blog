---
title: Docker 的 Volume
date: 2017-11-01 12:31:35
tags:
- Docker
---

> Docker镜像是由多个文件系统（只读层）叠加而成。当我们启动一个容器的时候，Docker会加载只读镜像层并在其上（译者注：镜像栈顶部）添加一个读写层。如果运行中的容器修改了现有的一个已经存在的文件，那该文件将会从读写层下面的只读层复制到读写层，该文件的只读版本仍然存在，只是已经被读写层中该文件的副本所隐藏。当删除Docker容器，并通过该镜像重新启动时，之前的更改将会丢失。在Docker中，只读层及在顶部的读写层的组合被称为Union File System（联合文件系统）。

&emsp;&emsp;换言之，删除容器的时候要记得顺便删除数据卷，例如：

```bash
# 删除全部容器连带的数据卷
docker ps -aq | xargs docker rm -f -v
# 删除遗留而不用的容器
docker volume prune
```

&emsp;&emsp;Volume 必须在容器初始化时就创建，也就意味着，只能在 docker run 或者 Dockerfile 里面指定数据卷。

>$ docker run -it --name container-test -h CONTAINER -v /data debian /bin/bash
root@CONTAINER:/# ls /data
root@CONTAINER:/# 

&emsp;&emsp;单参数的情况下，把一个 /data 目录挂载到了容器中（可以认为之前这个容器中并不存在这个目录）。如果使用 docker inspect 的方式来查看容器的内容，则可以看到：

> $ docker inspect -f {{.Volumes}} container-test