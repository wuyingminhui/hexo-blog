---
title: Hyperledger Fabric 网络的启动步骤
date: 2017-10-27 19:54:07
tags:
- 区块链
- Hyperledger Fabric
---

&emsp;&emsp;本文是截至日前（2017.10.27）时对官方教程和自我实验的重新梳理。

&emsp;&emsp;Hyperledger Fabric 可以说是 Hyperledger 的拳头项目。虽然同为  Apache 的顶级项目，但大部分其他项目都以 Fabric 为基础。它是顶级项目中的顶级项目，可以认为是0级项目。

- docker 要有高于 17.06.2-ce 的版本。docker-compose 要有 1.14.0 及以上的版本。当然当前的高版本的 docker 已经自带了高版本的 docker-compose，这通常不用担心。

 
- 安装1.9+ 的 Golang。应该预期这样的结果：

> echo $GOPATH

> /Users/xxx/go

- 如果这个结果出不来，考虑当前 Shell 的环境变量没有正确设置：

> export GOPATH=$HOME/go

> export PATH=\$PATH:$GOPATH/bin

- 要用一个很特别的 nodejs 版本。6.9以上，却不能用8.x。npm 也有特别的版本要求：

> npm install npm@3.10.10 -g


- 要用一个很反直觉的 python 版本，python 2.7（也就是不能用 ubuntu 自带的）。
- 开始下载范例网络：

> git clone https://github.com/hyperledger/fabric-samples.git
cd fabric-samples

- 在 fabric-samples 目录下，用这个命令下载必须的镜像和二进制库：

> curl -sSL https://goo.gl/Q3YRTi | bash

&emsp;&emsp;实际上，这会在目录中替我们下载：

> cryptogen（配置密码学相关材料的二进制工具）
configtxgen（配置频道交易事务相关材料的二进制工具）
configtxlator（配置的转译器）
peer （peer 的操纵工具）

- 我们还可以把这些工具的路径加入 PATH 中：

> export PATH=<path to download location>/bin:$PATH

- 在 first-network 的文件夹内，依次执行：

> 生成密码学文件：
> ../bin/cryptogen generate --config=./crypto-config.yaml
> 
>重映射当前路径为 fabric 相关环境变量：
>export FABRIC_CFG_PATH=\$PWD
>
>根据双组织排序器的配置，生成创世区块：
>../bin/configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
>
>指定当前频道名称(自定义频道不在各种 yml 文件里面，而在这里面)：
>export CHANNEL_NAME=mychannel
>
>根据频道名称，生成频道的事务文件：
>../bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID \$CHANNEL_NAME
>
>生成组织一与组织二的 MSP，注意**锚平等**节点必须配置好了：
>../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID \$CHANNEL_NAME -asOrg Org1MSP
>../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP

- 注释掉 docker-compose-cli.yaml 里的这一行：
 
>  #command: /bin/bash -c './scripts/script.sh \${CHANNEL_NAME} \${DELAY}; sleep $TIMEOUT'

- 启动容器：

> CHANNEL_NAME=$CHANNEL_NAME TIMEOUT=10000 docker-compose -f docker-compose-cli.yaml up -d

- 进入 cli 容器，只有在 cli 容器里，才能进行 channel 相关的操作：

> docker exec -it cli bash

- 在容器内：

> 又要重新命名频道名为环境变量：
> export CHANNEL_NAME=mychannel
>
> 生成频道区块：
> peer channel create -o orderer.example.com:7050 -c \$CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
>
> 把当前的 org1 的 peer0 加入这个频道(注意此时已经有四个核心的环境变量被注入到容器内部了)：
> peer channel join -b mychannel.block
>
> 把智能合约装到当前的四个peer 里的一个(哪一个？是仅仅 peer0吗？有待再实验 )：
> peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02
>
> 初始化一个合约，初始化合约会为 peer node 生成一个专门拿来跑智能合约的安全容器(即 dev-xxx 的容器)：
>    peer chaincode instantiate -o orderer.example.com:7050 --tls \$CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C \$CHANNEL_NAME -n mycc -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('Org1MSP.member','Org2MSP.member')"
>
> 测试初始合约的状态：
> peer chaincode query -C \$CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'
>
> 第一次 invoke 这个 chaincode：
> peer chaincode invoke -o orderer.example.com:7050  --tls \$CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem  -C \$CHANNEL_NAME -n mycc -c '{"Args":["invoke","a","b","10"]}'
>
> 再次查询:
> peer chaincode query -C \$CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

- 容器之外

> 优雅关闭网络：
> docker-compose -f docker-compose-cli.yaml down
>
> 去除无用的 docker 容器:
> docker rm -f $(docker ps -aq)
>
> 在容器外查看特定容器的日志：
> sudo docker logs -f peer0
> \# control + c will exit the process
> sudo docker logs -f orderer0
>
> 专门删除与 chaincode 有关的镜像
> docker rmi -f (docker images | grep peer[0-9]-peer[0-9] | awk '{print3}')













