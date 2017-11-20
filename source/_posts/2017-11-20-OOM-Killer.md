---
title: OOM Killer
date: 2017-11-20 16:48:04
tags:
- Linux
---

&emsp;&emsp;Linux 内核有个 OOM Killer 的机制，可以在系统内存不足的时候，通过主动杀死一些进程来释放更多的内存空间。

&emsp;&emsp;很多时候，我们可以 ping 通一台服务器，但无法 ssh 上去，因为 sshd 被 OOM Killer 杀掉了。ping 能 ping 通，是因为处在内核态协议栈还能工作，发出回送报文。sshd 则因为是用户态进程，直接被干掉了。

&emsp;&emsp;关闭再打开 OOM Killer 的方法：

```bash
echo "0" > /proc/sys/vm/oom-kill
echo "1″ > /proc/sys/vm/oom-kill 
```

&emsp;&emsp;OOM Killer 决定是否要杀死一个进程，主要看两个指标：
1. /proc/PID/oom_score 的分数
2. /proc/PID/oom_adj 

&emsp;&emsp;可以通过以下方法强制内核不得杀死某个进程：

```bash
pgrep -f "/usr/sbin/sshd" | while read PID;do echo -17 > /proc/$PID/oom_adj;done
```

参考文档：
1. [关于OOM-killer][1]
2. 这里有一篇[《OOM Killer》][2]讨论它的工作细节。
3. [Linux 下 OOM Killer 机制的详解][3]
4. [Linux内核OOM机制的详细分析][4]


  [1]: http://blog.csdn.net/tenfyguo/article/details/9409743
  [2]: https://linux-mm.org/OOM_Killer
  [3]: http://www.360doc.com/content/11/1119/18/7492958_165786637.shtml
  [4]: http://laoxu.blog.51cto.com/4120547/1267097/