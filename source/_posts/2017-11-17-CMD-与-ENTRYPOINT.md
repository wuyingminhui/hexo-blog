---
title: CMD 与 ENTRYPOINT
date: 2017-11-17 15:21:44
tags:
- Docker
---
&emsp;&emsp;CMD 与 ENTRYPOINT 都是为了让容器工作得像可执行文件一样，接受参数，产生特定的输出存在的--**容器命令化工具**。如果没有这些工具，那么`docker run -it abc:v0.0.1 /bin/bash` 的最后一个参数就会变成启动命令。如果有CMD，它的命令也会被 docker run 结尾的参数命令锁覆盖，原本的命令不会作为 startup command 执行;如果有 ENTRYPOINT，docker run 结尾的参数命令会作为 ENTRYPOINT 的命令执行; CMD 还可以为 ENTRYPOINT 提供参数。

&emsp;&emsp;比较奇怪的地方是,如果使用了非 /bin/bash 的 startup command，docker run 的时候就不能 /bin/bash 进去了。

&emsp;&emsp;一个容器最好只有一个 CMD，一个 ENTRYPOINT。子容器的 CMD 会覆盖父容器的 CMD。

&emsp;&emsp;CMD 可以为 ENTRYPOINT 提供参数。

&emsp;&emsp;他们都有 exec 和 SHELL 两种工作模式。

&emsp;&emsp;例如以下的例子，可以用 `docker run -it d8c80106de01` tty 接管上去：

```bash
CMD nohup geth --mine --minerthreads=1  --identity "Ehtereum1" --rpc --rpcapi admin,eth,miner,debug,personal,txpool,web3,net --rpcport "8545" --datadir /home/ethereum/datadir --port "30303" --nodiscover --rpccorsdomain "*" --networkid 1024 --gasprice 1 --ws --wsport 8546 --wsaddr 0.0.0.0 --wsorigins "*" --wsapi admin,eth,miner,debug,personal,txpool,web3,net /home/ethereum/miner.out&

ENTRYPOINT /bin/bash
```

&emsp;&emsp;因为最后一个命令使用了 `/bin/bash` 所以容器最终成为了一个 bash 命令。

&emsp;&emsp;如果使用 sshd 的话，还可以 ssh 进去。在启动容器的时候直接打开端口映射`docker run  -it -p 52022:22 d8c80106de01`,然后在内部打开 sshd `/usr/sbin/sshd`（不知道为什么是直接写`ENTRYPOINT /usr/sbin/sshd
`不能正常工作），在本地直接用端口去 ssh 即可`ssh -p 52022 root@localhost`。如果容器内部没有打开 sshd，则需要 `exec`（低版本使用`attach` ）进去了。