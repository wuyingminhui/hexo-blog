---
title: DAG 执行框架优于 MapReduce 的地方在哪里？
date: 2018-01-28 18:07:31
tags:
- 大数据
- Spark
- Storm
- MapReduce
---
有个同学问我什么是 DAG 框架。我感觉隐隐约约听过，但又讲不清楚它的概念。

上网搜了一下，我们常见的新大数据执行框架如 Spark、Storm，还有一个我没听过的 Tez，都算 DAG 任务执行框架。他们的主要优点是，可以用 DAG 事先通晓整个任务的全部步骤，然后进行转换优化。如 Tez 就可以把多个任务转换为一个大任务，而 Spark 则可以把相关联的 Map 直接串联起来， 免得多次写回 hdfs（看来 hdfs 也很慢）。传统的 MapReduce 框架为什么不能理解这种优化空间的存在，在任务运行的时候好像一个盲人一样，是个很有意思的话题。

Quora 上的一个相关的[问答][1]。


  [1]: https://www.quora.com/What-are-the-advantages-of-DAG-directed-acyclic-graph-execution-of-big-data-algorithms-over-MapReduce-I-know-that-Apache-Spark-Storm-and-Tez-use-the-DAG-execution-model-over-MapReduce-Why-Are-there-any-disadvantages