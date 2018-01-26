---
title: 什么情况下 Scala 应该省略 Return 关键字
date: 2018-01-26 10:49:37
tags:
- Scala
---

&emsp;&emsp;[一个很有意思的回答][1]。

&emsp;&emsp;总体而言，如果我们能够分得清什么 last expression，我们就能推导出和编译器一样的返回类型结果。否则，我们应该显式地加上 return，这样既指定了实际返回类型，也指定了控制流上的返回点。

  [1]: https://stackoverflow.com/questions/12560463/return-in-scala#comment16919103_12560463
