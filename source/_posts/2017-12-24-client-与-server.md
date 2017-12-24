---
title: client 与 server
date: 2017-12-24 14:29:59
tags:
- JVM
---

# client 模式 #

默认的jit编译器，c1。
默认的gc：serial-serial old。
需要更短的启动时间和初始堆大小，能做更保守的优化。
默认-Xms是1M，-Xmx是64M。
适合 GUI 程序。

# server 模式 #

默认的jit编译器，c2。
默认的gc：ps-serial old即 PS MarkSweep（可以启用parallel old）。
需要更长的启动时间和更大的堆大小，能够做更有深度的优化。
默认-Xms是128M，-Xmx是1024M。
适合长时间运转的程序。