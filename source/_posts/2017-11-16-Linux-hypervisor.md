---
title: Linux hypervisor
date: 2017-11-16 14:46:24
tags:
- Linux
- 虚拟化
- hypervisor
---
&emsp;&emsp;hypervisor 可以被认为等于 virtual hardware。他们的出现，可以有效减少硬件服务器数量。

![此处输入图片的描述][1]

&emsp;&emsp;常见的 hypervisor 分成两类：

 1. 直接运行在硬件上的，基于内核的虚拟机。 OS as hypervisor。典型例子是 KVM。KVM 是被集成到 Linux 内核之中的完整虚拟化解决方案。
 2. 运行于另一个操作系统之上。典型的例子是 QEMU 和 WINE。

&emsp;&emsp;hypervisor的实现，总是要映射一些磁盘设备和网络设备的。
 
  [1]: https://www.ibm.com/developerworks/cn/linux/l-hypervisor/figure1.gif