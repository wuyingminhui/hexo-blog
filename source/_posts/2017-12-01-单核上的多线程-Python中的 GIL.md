---
title: 单核上的多线程-Python中的 GIL
date: 2017-12-01 23:41:19
tags:
- Python
---

&emsp;&emsp;GIL （Global Interpreter Lock）的存在虽然无法利用多核，但是可以勉强让系统在在单核上，任何一个线程使用过多时间片/主动放弃 CPU 的时候，让其他线程上下文切入进来。算是尽量跑满CPU吧。Python中的对象很多都是默认线程安全的，GIL的这种不可见的特性，让很多旧的程序依赖起 GIL，以至于无法从Python中移除掉它。GIL 的存在，让 Python 特别适合跑 Nodejs 爬虫一样的 IO 密集型（IO-bound）任务，反而不适合跑CPU 密集型任务（CPU-bound）。但实际上这种混蛋多线程的形式，恐怕还不如 EventLoop 的 Nodejs，因为多了很多 Context Switch 的代价。