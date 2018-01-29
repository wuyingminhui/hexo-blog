---
title: Spark Standalone 模式启动的全过程
date: 2018-01-29 16:20:15
tags:
- Spark
---

把这个事情做成一个小 routine，免得以后每次都要看英文文档来搭 dev 环境

## 准备工作 ##

下载安装包，解压并进入根目录。

`./sbin/start-master.sh`。看 jps 果然已经有了一个 Master 进，文档里面说会打印出 spark 的 master url，但没打印出来。就去默认的`http://localhost:8080`上看即可：

```
URL: spark://magicliang:7077
REST URL: spark://magicliang:6066 (cluster mode)
```
这个6066在本地 telnet 不通，也是很神奇。

把这个 URL 拼接成 worker  的启动命令`./start-slave.sh spark://magicliang:7077`，然后可以看到以下这张图：

![](https://ws1.sinaimg.cn/large/66dd581fly1fnwjxcayiwj22720wo0zj.jpg)

文档里的给出的定义 worker 节点的方法：在 Spark 根目录下定义一个 conf/slaves 的文件，每一行写一个主机名。如果这个文件不存在（就是我们现在这个状况），则 worker 就会全部启动在 localhost 上。而 master 是通过 ssh 跟 worker 通信的。默认情况下，ssh 是并行执行，而且要求免密码登录。如果不能提供免密码，要配置一个环境变量 SPARK_SSH_FOREGROUND 并显式地为每个 worker 提供密码。

sbin 里自带了一大套脚本：

> sbin/start-master.sh - Starts a master instance on the machine the script is executed on.
sbin/start-slaves.sh - Starts a slave instance on each machine specified in the conf/slaves file.
sbin/start-slave.sh - Starts a slave instance on the machine the script is executed on.
sbin/start-all.sh - Starts both a master and a number of slaves as described above.
sbin/stop-master.sh - Stops the master that was started via the sbin/start-master.sh script.
sbin/stop-slaves.sh - Stops all slave instances on the machines specified in the conf/slaves file.
sbin/stop-all.sh - Stops both the master and the slaves as described above.

master 和 worker 相关脚本都支持以下参数：

> -h HOST, --host HOST  Hostname to listen on
-i HOST, --ip HOST  Hostname to listen on (deprecated, use -h or --host)
-p PORT, --port PORT    Port for service to listen on (default: 7077 for master, random for worker)
--webui-port PORT   Port for web UI (default: 8080 for master, 8081 for worker)
-c CORES, --cores CORES Total CPU cores to allow Spark applications to use on the machine (default: all available); only on worker
-m MEM, --memory MEM    Total amount of memory to allow Spark applications to use on the machine, in a format like 1000M or 2G (default: your machine's total RAM minus 1 GB); only on worker
-d DIR, --work-dir DIR  Directory to use for scratch space and job output logs (default: SPARK_HOME/work); only on worker
--properties-file FILE  Path to a custom Spark properties file to load (default: conf/spark-defaults.conf)

我们还可以通过在`conf/spark-env`里设置环境变量进一步配置集群。可以通过`conf/spark-env.sh.template`来设置初始的 worker 配置，然后把改过的配置拷贝到 worker 机器上去（**TODO: 换言之 Spark 也像 Hadoop 一样要求 Master 和 Worker 的目录结构同构？改天试试。**）。

## 把应用程序连接到集群上 ##

两个选择：

- 把`spark://magicliang:7077`传递给 SparkContext constructor。
- 直接开 Spark Shell 来连集群：`./bin/spark-shell --master spark://magicliang:7077`。这时候就会启动一个被修改过的 scala repl 环境

在 shell 环境里输入：

```scala
// 可以看到，在 Spark 中（还没有进入 Spark SQL 模块）默认的数据对象就是 Dataset
 val textFile = spark.read.textFile("README.md")
//18/01/28 20:21:17 WARN ObjectStore: Failed to get database global_temp, returning NoSuchObjectException
//textFile: org.apache.spark.sql.Dataset[String] = [value: string]

textFile.count() // Number of items in this Dataset
//res0: Long = 126 // May be different from yours as README.md will change over time, similar to other outputs

textFile.first() // First item in this Dataset
// 其实这里面第一个元素，就是第一行的意思
//res1: String = # Apache Spark

// 从侧面也可以看出，这里面数据集的单个元素是一行
val linesWithSpark = textFile.filter(line => line.contains("Spark"))
//linesWithSpark: org.apache.spark.sql.Dataset[String] = [value: string]
linesWithSpark.count()
//res1: Long = 20

// 寻找有最多词语的行
// Dataset 和 Dataset 之间可以直接做变换，不需要用到什么 converter。
// 这也是个用 reduce 化多为一的操作
textFile.map(line => line.split(" ").size).reduce((a, b) => if (a > b) a else b)
// res2: Int = 22
// 上一行代码也可以这样写：
textFile.map(line => line.split(" ").size).reduce((a, b) => Math.max(a, b))

// 经典的 wordcount 问题的一行解
val wordCounts = textFile.flatMap(line => line.split(" ")).groupByKey(identity).count()
// wordCounts: org.apache.spark.sql.Dataset[(String, Long)] = [value: string, count(1): bigint]

// 经典的收束解
wordCounts.collect()
res6: Array[(String, Long)] = Array((online,1), (graphs,1), (["Parallel,1), (["Building,1), (thread,1), (documentation,3), (command,,2), (abbreviated,1), (overview,1), (rich,1), (set,2), (-DskipTests,1), (name,1), (page](http://spark.apache.org/documentation.html).,1), (["Specifying,1), (stream,1), (run:,1), (not,1), (programs,2), (tests,2), (./dev/run-tests,1), (will,1), ([run,1), (particular,2), (option,1), (Alternatively,,1), (by,1), (must,1), (using,5), (you,4), (MLlib,1), (DataFrames,,1), (variable,1), (Note,1), (core,1), (more,1), (protocols,1), (guidance,2), (shell:,2), (can,7), (site,,1), (systems.,1), (Maven,1), ([building,1), (configure,1), (for,12), (README,1), (Interactive,2), (how,3), ([Configuration,1), (Hive,2), (system,1), (provides,1), (Hadoop-supported,1), (pre-built,1...

// 显式地指定一个数据集为全集群内的 in memory 缓存，也就是说，这个缓存不是默认生效的
linesWithSpark.cache()
//res7: linesWithSpark.type = [value: string]
```

最后一个缓存是特别有意思的地方。即使这些数据是分布在整个集群的各个地方的，Spark 也有办法把它缓存起来。

## 开始写一个小小的程序 ##

建一个新项目`sbt new sbt/scala-seed.g8`，输入项目名 first-app。

或者用 idea 建立一个项目。然后把相关代码写进去。

重点关注几个文件。

Dependencies.scala(这个文件就是下面文件里面 import 的对象)
```scala
import sbt._

object Dependencies {
  lazy val scalaTest = "org.scalatest" %% "scalatest" % "3.0.3"
}

```

build.sbt
```scala
import Dependencies._

lazy val root = (project in file(".")).
  settings(
    inThisBuild(List(
      organization := "com.magicliang",
      // 高版本的 scala 仓库里下载不到这个 spark-sql 模块
      scalaVersion := "2.11.8",
      version      := "0.1"
    )),
    name := "first-application",
    libraryDependencies += scalaTest % Test,
    libraryDependencies += "org.apache.spark" %% "spark-sql" % "2.2.1"
  )
```

具体的项目代码：
```scala
package com.magicliang

import org.apache.spark.sql.SparkSession


/**
  * @author liangchuan
  */
object SimpleApplication {

  println("hello world")

  // http://blog.csdn.net/csdn_chuxuezhe/article/details/75351762
  // 在 VM options 里增加 -Dspark.master=local 即可指定应用程序在本地单线程启动。
  // 暂时不知道为什么用 ide 启动只支持 local[k] 模式而不支持提交任务到 master url 的模式
  // https://spark.apache.org/docs/latest/submitting-applications.html spark 的几种启动模式参数，也可以在 submit 里指定
  // Spark 模式的总结：https://www.jianshu.com/p/65a3476757a5
  def main(args: Array[String]): Unit = {
    val logFile = "/Users/magicliang/Desktop/Programming/tools/spark-2.2.1-bin-hadoop2.7/README.md"
    val spark = SparkSession.builder.appName("SimpleApplication").getOrCreate()
    println("SparkSession created")
    val logData = spark.read.textFile(logFile).cache()
    println("Dataset created and cached")
    val numAs = logData.filter(line => line.contains("a")).count()
    val numBs = logData.filter(line => line.contains("b")).count()
    // 这里这个 s 开头字符串本身就是可替换字符串的前缀，没有它是不可以做到字符串替换的。
    println(s"Lines with a: $numAs, Lines with b: $numBs")
    Thread.sleep(20000)
    spark.stop()
  }

}
```

完整的目标工程见[此][1]。

sbt 部分的[参考链接][2]。


  [1]: https://github.com/magicliang/SparkStudy/tree/master/first-application
  [2]: https://www.scala-sbt.org/1.x/docs/Hello.html