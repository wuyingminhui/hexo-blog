---
title: Scala 泛型中的协变（covariant）与逆变(contravariant)符号
date: 2018-01-19 17:10:31
tags:
- Scala
- 泛型
---

&emsp;&emsp;看到这个问题[《+- Signs in Generic Declaration in Scala》][1]下面有一个很有意思的答案：

> "+" and "-" mean covariant and contravariant types respectively. In short, it means that:

> PartialFunction[-A1, +B1] <: PartialFunction[-A2, +B2] only if A1 :> A2 and B1 <: B2, where <: is subtyping relationship.

&emsp;&emsp;简而言之，`-`意味着逆变成立，`+`意味着协变成立。

  [1]: https://stackoverflow.com/questions/27627782/signs-in-generic-declaration-in-scala