---
title: Hyperledger Fabric MSP 相关问题
date: 2018-03-15 16:29:15
tags:
- Hyperledger Fabric
- 区块链
---
## MSP 相关

MSP 把签发和验证证书、用户质询的过程给抽象化了。MSP 可以完全定制化实体（identity）的记号，和这些实体被治理的规则。

一个 Fabric 区块链可以被一个或多个 MSP 治理。这提供了会员制操作的模块化，和不同会员制标准的互操作性。

在 Fabric 中，签名验证（signature verification）是 authentication。

每一个 peer 和 orderer 都需要局部设置 MSP 配置（实际上就是需要配置证书和 signing keys）。每个 MSP 必须有个 MSP ID 来引用这个 MSP。实际上如果我们仔细观察 crypto-config 这个文件夹，就会发现组织域、peer、admin 和一般 user，凡是有 identity 的，都有 msp 的配置。而 MSP 的全套配置必然包括：

- admincerts
- cacerts
- tlscacerts

如果可以发起和验证签名，还需要有：

- keystore
- signcerts

用户可以使用 Openssl（这个大概是没人用的）、cryptogen 和[Hyperledger Fabric CA][1]来生成用来配置 MSP 的**证书和 signing keys**。

在每个节点的配置文件里面（对 peer 节点是 core.yaml 对orderer 节点则是 orderer.yaml）指定 mspconfig 文件夹的路径和节点的 MSP 的 ID。mspconfig 文件夹的路径必须是相对于`FABRIC_CFG_PATH`的路径，在 peer 上用`mspConfigPath`参数表示，在 orderer 上用`LocalMSPDir`参数表示。MSP ID 在 peer 上用`localMspId`表示，在 orderer 上用`LocalMSPID`表示（注意大小写不同）。这些参数可以被环境变量给覆写掉，对于 peer 用`CORE_PEER_LOCALMSPID`，对于 orderer 用`ORDERER_GENERAL_LOCALMSPID`。当 orderer 启动了以后，必须把“系统 channel”的创世区块提供给 orderer。

只有手动操作才能重新配置一个“本地”MSP，而且要求那个 peer 或者 orderer 进程重启。未来可能会提供在线动态的重配置。

在 mspconfig 文件夹下可以用一个 config.yaml 文件来定义组织化单元。大概是这样：

```yaml
OrganizationalUnitIdentifiers:
  - Certificate: "cacerts/cacert1.pem"
    OrganizationalUnitIdentifier: "commercial"
  - Certificate: "cacerts/cacert2.pem"
    OrganizationalUnitIdentifier: "administrators"
```

有一种特殊的分法，把签发事务、查询 peer 的 identity 称作 client，而把背书和提交事务的节点被称作 peer。问题是默认的情况下一个 peer 容器就是 peer 了，也不需要专门的 config 来配置。所以我想应该只是专门使用 client 来区分、鉴别 identity。

```yaml
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: "cacerts/cacert.pem"
    # 不同的 OUIdentifier 都需要这个字段。MSP 的 administrator 还必须是 client
    OrganizationalUnitIdentifier: "client"
  PeerOUIdentifier:
    Certificate: "cacerts/cacert.pem"

    OrganizationalUnitIdentifier: "peer"
```
正如我们前面看到的，orderer 在启动的时候，需要得到一个“系统频道”的创世区块，这个创世区块必须包含全网络中出现的所有 MSP 的验证参数。这些验证参数包括：“verification parameters consist of the MSP identifier, the root of trust certificates, intermediate CA and admin certificates, as well as OU specifications and CRLs”。
这样 orderer 才能处理频道创建请求（channel creation requests）。

而对于应用程序频道而言，只有治理那个频道的 MSP 的验证组件必须被包含在那个频道的创世区块中。在 peer 加入频道以前，应用程序有义务把正确的 MSP 配置信息包含在创世区块之中。

要修改一个频道里的 MSP，要一个有那个频道 administrator 证书的拥有者，创建一个`config_update`对象，然后把这个对象在频道里公布。**这是通过 configuration block 来实现的吗？**

MSP 的最佳实践有：

- 一个组织拥有多个 MSP。
    
这是一个组织下面有多个分支机构的时候才会用到的设计方法。

- 多个组织共用一个 MSP。

什么情况下会让一个联盟中的多个组织共用一个 MSP 呢？除非它们极为相似吧。

- client 要和 peers 分开。怎么做到的呢？

- 要有独立的 admin 和 CA 证书。

- 把中间 CA 放到黑名单里面。

- CA 和 TLS CA 放在不同的文件夹下。

  [1]: http://hyperledger-fabric-ca.readthedocs.io/en/latest/