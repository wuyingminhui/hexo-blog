---
title: Docker 的 Volume
date: 2017-11-01 12:31:35
tags:
- Docker
---



&emsp;&emsp;Volume 必须在容器初始化时就创建，也就意味着，只能在 docker run 或者 Dockerfile 里面指定数据卷。

## 使用 docker run 的方式 ##

>$ docker run -it --name container-test -h CONTAINER -v /data debian /bin/bash
root@CONTAINER:/# ls /data
root@CONTAINER:/# 

&emsp;&emsp;单参数的情况下，把一个 /data 目录挂载到了容器中（可以认为之前这个容器中并不存在这个目录）。如果使用 docker inspect 的方式来查看容器的内容，则可以看到：

> $ docker inspect -f {{.Volumes}} container-test

&emsp;&emsp;输出:
 
>map[/data:/var/lib/docker/vfs/dir/cde167197ccc3e138a14f1a4f...b32cec92e79059437a9] 

&emsp;&emsp;注意看，是container path 在前， host path 在后。
&emsp;&emsp;如果我们在 host 主机上修改本地目录:
    
> $ sudo touch /var/lib/docker/vfs/dir/cde167197ccc3e13814f...b32ce9059437a9/test-file

&emsp;&emsp;则可以在容器中看到:

 > $ root@CONTAINER:/# ls /data
test-file

对应的 Dockerfile 版本是，注意，这里依然是单参数的：

>FROM debian:wheezy
VOLUME /data

但是

>但还有另一件只有-v参数能够做到而Dockerfile是做不到的事情就是在容器上挂载指定的主机目录。例如：
$ docker run -v /home/adrian/data:/data debian ls /data

>该命令将挂载主机的/home/adrian/data目录到容器内的/data目录上。任何在/home/adrian/data目录的文件都将会出现在容器内。这对于在主机和容器之间共享文件是非常有帮助的，例如挂载需要编译的源代码。为了保证可移植性（并不是所有的系统的主机目录都是可以用的），挂载主机目录不需要从Dockerfile指定。当使用-v参数时，镜像目录下的任何文件都不会被复制到Volume中。（译者注：Volume会复制到镜像目录，镜像不会复制到卷）

&emsp;&emsp;此处存疑。

&emsp;&emsp;容器的 Volume 不是为了持久化自己的状态。docker 自己的可读写层的状态另有存储的地方。Volume 是为了把容器及容器产生的数据分离出来。

&emsp;&emsp;Volume可以使用以下两种方式创建：

 - 在Dockerfile中指定VOLUME /some/dir
 - 执行docker run -v /some/dir命令来指定

&emsp;&emsp;无论哪种方式都是做了同样的事情。它们告诉Docker在主机上创建一个目录（默认情况下是在**/var/lib/docker**下），然后将其挂载到指定的路径（例子中是：/some/dir）。当删除使用该Volume的容器时，Volume本身不会受到影响，它可以一直存在下去。

&emsp;&emsp;双参数的 docker run 的语法，和 docker inspect 的语法顺序是相反的：

>docker run -v /host/path:/some/path ...

&emsp;&emsp;也就是说 docker run -v -p 的选项后接的参数都是从外到内的，而 docker inspect 的显示结果，则是从内到外的。

&emsp;&emsp;本文参考了[《深入理解Docker Volume（一）》][1], [《深入理解Docker Volume（二）》][2]


  [1]: http://dockone.io/article/128
  [2]: http://dockone.io/article/129