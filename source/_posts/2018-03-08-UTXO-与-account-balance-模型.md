---
title: UTXO 与 account balance 模型
date: 2018-03-08 18:23:13
tags:
- 比特币
- 区块链
---
## UTXO 简介 ##

&emsp;&emsp;UTXO 的全称的 unspent transaction output，就是没有被人用过的可用资金。

&emsp;&emsp;这个模型是比特币首创的，被其他货币所模仿。以太坊天然的模型不是 UTXO 而是 account balance。

&emsp;&emsp;UTXO 必须配平，UTXO 的输入者必须上一个 UTXO 的输出者：

![UTXO的描述图][1]

&emsp;&emsp;这就把一个一个账户型数据库，转成了链式的交易数据库，交易要靠 merge 整个数据库的相关节点。

&emsp;&emsp;UTXO 的好处是：

- 更加好的隐私模型
- 更加强的并发范型（因为不会触发间隙锁了吗？）

## ZCash 的 UTXO ##

&emsp;&emsp;ZCash 也一样有 UTXO，但它的 UTXO 是加密过的，而且每个矿工那里还有一个专门的 UTXO 作废数据库。具体情况见[《不是程序员也能看懂的ZCash零知识证明》][2]。

##以太坊中的 account 模型##

&emsp;&emsp;以太坊没有使用 UTXO 模型，而使用 account balance 模型，他们把 account balance 模型称为 world state。account balance 模型比 UTXO 模型更加容易实现智能合约，且具有以下优点：

- 节省更多存储空间。
- 更高的可替代性 - UTXO 模型不适合拿来实现黑名单。
- 简单：账户模型更好编码也更好理解。

账户模型的缺点是，为了防止重放攻击，必须追踪交易的 nounce。

## Hyperledger Fabric 的 world state ##

 Fabric 的 world state 本身是由 transaction 叠加得来的，即它既存储了 transaction 记录，也存储了当前的世界状态。但他们并不明确地把他们的 world state 归纳为 UTXO 或者 accound balance 模型。
 
> How do I create assets?
A. Users can use chaincode (for business rules) and membership service (for digital tokens) to design assets, as well as the logic that manages them.

> There are two popular approaches to defining assets in most blockchain solutions: the stateless UTXO model, where account balances are encoded into past transaction records; and the account model, where account balances are kept in state storage space on the ledger.

> Each approach carries its own benefits and drawbacks. This blockchain technology does not advocate either one over the other. Instead, one of our first requirements was to ensure that both approaches can be easily implemented.

## Corda 使用 UTXO 模型 ##

对 Corda 而言，新的事务，就是把旧的 state 变为历史 state，而借此生成新的 state 的过程。

![](https://ws1.sinaimg.cn/large/66dd581fly1fnm5kbqb0cj21us156djl.jpg)

参考资料：

- [What are the pros and cons of Ethereum balances vs. UTXOs?][3]


  [1]: http://8btc.com/data/attachment/portal/201702/03/140447qe7vo3vt7g22slev.jpg
  [2]: https://zhuanlan.zhihu.com/p/24440530
  [3]: https://ethereum.stackexchange.com/questions/326/what-are-the-pros-and-cons-of-ethereum-balances-vs-utxos