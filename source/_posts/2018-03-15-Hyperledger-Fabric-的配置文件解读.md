---
title: Hyperledger Fabric 的配置文件解读
date: 2018-03-15 14:38:14
tags:
- Hyperledger Fabric
- 区块链
---
## Crypto Generator

x.509 相关的文件主要包含两个东西：证书和 signing keys。

cryptogen 使用的配置文件是`crypto-config.yaml`。

x.509 的根证书是`ca-cert`。它把 peers 和 orderers 绑定到一个 Org 里面。在这个网络里，每个组织都有签发自己的证书的能力，可以用这个 ca 来签发其他证书给节点和 client。

签发交易用的是私钥（keystore），验证交易用的是公钥（signcerts）。

```yaml
OrdererOrgs:
  # 这里的 Name 是 MemberShip 的 ID，大致就是一个法律实体作为会员。
  - Name: Orderer
    Domain: example.com
    Specs:
      # orderer docker 容器的名字 
      - Hostname: orderer
PeerOrgs:
  - Name: Org1
    # 组织1的完整 domain 看起来像 orderer 的子 domain 一样，很不好。 
    Domain: org1.example.com
    # 这里的容器名就不是用 Hostname 指定出来的，而是用 spec 推导出来的了。具体还是看文档，这里就是规定这个组织里有多少个 peer，peer 用什么名字。现在这个名字就是 peer0，peer1 的形式。当然都可以改。
    Template:
      Count: 2
      # Start: 5
      # Hostname: {{.Prefix}}{{.Index}} # default
    # 暂时不明白这个 Users 到底指的是什么
    Users:
      Count: 1

  - Name: Org2
    Domain: org2.example.com
    Template:
      Count: 2
    Users:
      Count: 1
```

跑完这个工具生成的材料都在`crypto-config`这个文件夹下，它总会归属于 ordererOrganzations 和 peerOrganizations。这两个文件夹下的子文件夹就是由拓扑决定的几个域文件夹。每个域下必有 ca、msp、peers/orderers、tlsca 和 users 五个文件夹。

## configtxgen 相关

`configtxgen`需要使用的配置文件是`configtx.yaml`，解说文件大致如下：

```yaml
---
################################################################################
#
#   Profile
#
#   - Different configuration profiles may be encoded here to be specified
#   as parameters to the configtxgen tool
#
################################################################################

# 在这里不同的 profile 可以让 configtxgen 作为命令行参数来读取
Profiles:
    # 这就是 profile 的名字
    # 针对创世区块的 profile
    TwoOrgsOrdererGenesis:
        Orderer:
            <<: *OrdererDefaults
            Organizations:
                # 这里引用了下面的 &OrdererOrg
                - *OrdererOrg
        Consortiums:
            SampleConsortium:
                Organizations:
                    # 这里引用了下面的 &Org1
                    - *Org1
                    - *Org2
    # 针对 channel 的 profile
    TwoOrgsChannel:
        # 引用了同一个联盟
        Consortium: SampleConsortium
        Application:
            <<: *ApplicationDefaults
            Organizations:
                - *Org1
                - *Org2

################################################################################
#
#   Section: Organizations
#
#   - This section defines the different organizational identities which will
#   be referenced later in the configuration.
#
################################################################################
Organizations:

    # SampleOrg defines an MSP using the sampleconfig.  It should never be used
    # in production but may be used as a template for other definitions
    - &OrdererOrg
        # DefaultOrg defines the organization which is used in the sampleconfig
        # of the fabric.git development environment
        Name: OrdererOrg

        # ID to load the MSP definition as
        ID: OrdererMSP

        # 这里差不多是硬编码了这个组织的 MSP 目录。
        # MSPDir is the filesystem path which contains the MSP configuration
        MSPDir: crypto-config/ordererOrganizations/example.com/msp

    - &Org1
        # DefaultOrg defines the organization which is used in the sampleconfig
        # of the fabric.git development environment
        Name: Org1MSP

        # ID to load the MSP definition as
        # 对比上下两个组织，name 可以和 id 一样，也可以和 id 不一样。
        ID: Org1MSP

        MSPDir: crypto-config/peerOrganizations/org1.example.com/msp

        AnchorPeers:
            # AnchorPeers defines the location of peers which can be used
            # for cross org gossip communication.  Note, this value is only
            # encoded in the genesis block in the Application section context
            - Host: peer0.org1.example.com
              Port: 7051

    - &Org2
        # DefaultOrg defines the organization which is used in the sampleconfig
        # of the fabric.git development environment
        Name: Org2MSP

        # ID to load the MSP definition as
        ID: Org2MSP

        MSPDir: crypto-config/peerOrganizations/org2.example.com/msp

        AnchorPeers:
            # AnchorPeers defines the location of peers which can be used
            # for cross org gossip communication.  Note, this value is only
            # encoded in the genesis block in the Application section context
            - Host: peer0.org2.example.com
              Port: 7051

################################################################################
#
#   SECTION: Orderer
#
#   - This section defines the values to encode into a config transaction or
#   genesis block for orderer related parameters
#
################################################################################
Orderer: &OrdererDefaults

    # Orderer Type: The orderer implementation to start
    # Available types are "solo" and "kafka"
    OrdererType: solo

    Addresses:
        - orderer.example.com:7050

    # Batch Timeout: The amount of time to wait before creating a batch
    BatchTimeout: 2s

    # Batch Size: Controls the number of messages batched into a block
    BatchSize:

        # Max Message Count: The maximum number of messages to permit in a batch
        MaxMessageCount: 10

        # Absolute Max Bytes: The absolute maximum number of bytes allowed for
        # the serialized messages in a batch.
        AbsoluteMaxBytes: 99 MB

        # Preferred Max Bytes: The preferred maximum number of bytes allowed for
        # the serialized messages in a batch. A message larger than the preferred
        # max bytes will result in a batch larger than preferred max bytes.
        PreferredMaxBytes: 512 KB

    Kafka:
        # Brokers: A list of Kafka brokers to which the orderer connects
        # NOTE: Use IP:port notation
        Brokers:
            - 127.0.0.1:9092

    # Organizations is the list of orgs which are defined as participants on
    # the orderer side of the network
    Organizations:

################################################################################
#
#   SECTION: Application
#
#   - This section defines the values to encode into a config transaction or
#   genesis block for application related parameters
#
################################################################################
Application: &ApplicationDefaults

    # Organizations is the list of orgs which are defined as participants on
    # the application side of the network
    Organizations:
```

## docker-compose 的配置文件分析

服务的定义依赖关系大概是 peer-base.yaml -> docker-compose-base.yaml -> docker-compose-cli.yaml。

### 常见环境变量前缀

Orderer 相关的环境变量开头是`ORDERER_GENERAL_`。

Peer 相关的环境变量开头是`CORE_PEER_`。

其他环境变量开头是`CORE_`。

### peer-base.yaml

启动 chaincode 容器都是在本**网桥**网络里启动的。

它的工作目录是`/opt/gopath/src/github.com/hyperledger/fabric/peer`。二进制的可执行文件应该都在 gopath 下。

它的工作路径里有二进制的 peer 文件，所以可以直接`peer node start`启动。

它的所谓的 vm enpoint 看起来就是容器服务治理的思路，用 port 来做 endpoint 的端点`CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock`。

```yaml
# 这个文件夹是纯净的，与 example 组织无关。
version: '2'

services:
  peer-base:
    image: hyperledger/fabric-peer:$IMAGE_TAG
    environment:
      - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
      # 用默认的网桥网络来启动链码容器。
      # the following setting starts chaincode containers on the same
      # bridge network as the peers
      # https://docs.docker.com/compose/networking/
      - CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=${COMPOSE_PROJECT_NAME}_byfn
      #- CORE_LOGGING_LEVEL=ERROR
      - CORE_LOGGING_LEVEL=DEBUG
      - CORE_PEER_TLS_ENABLED=true
      - CORE_PEER_GOSSIP_USELEADERELECTION=true
      - CORE_PEER_GOSSIP_ORGLEADER=false
      - CORE_PEER_PROFILE_ENABLED=true
      - CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt
      - CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key
      - CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt
    working_dir: /opt/gopath/src/github.com/hyperledger/fabric/peer
    command: peer node start
```

### docker-compose-base.yaml

```yaml
version: '2'

services:
  # orderer 的配置
  orderer.example.com:
    container_name: orderer.example.com
    image: hyperledger/fabric-orderer:$IMAGE_TAG
    environment:
      - ORDERER_GENERAL_LOGLEVEL=debug
      - ORDERER_GENERAL_LISTENADDRESS=0.0.0.0
      - ORDERER_GENERAL_GENESISMETHOD=file
      # 这个给 orderer 准备的创世区块，看下面的 volumes 的映射
      - ORDERER_GENERAL_GENESISFILE=/var/hyperledger/orderer/orderer.genesis.block
      - ORDERER_GENERAL_LOCALMSPID=OrdererMSP
      - ORDERER_GENERAL_LOCALMSPDIR=/var/hyperledger/orderer/msp
      # enabled TLS
      - ORDERER_GENERAL_TLS_ENABLED=true
      # 服务器的 key
      - ORDERER_GENERAL_TLS_PRIVATEKEY=/var/hyperledger/orderer/tls/server.key
      # 服务器的证书
      - ORDERER_GENERAL_TLS_CERTIFICATE=/var/hyperledger/orderer/tls/server.crt
      # ca 的证书
      - ORDERER_GENERAL_TLS_ROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]
    working_dir: /opt/gopath/src/github.com/hyperledger/fabric
    # 启动命令，不像 peer，不再需要加参数了。
    command: orderer
    volumes:
    # 对创世区块的映射  
    - ../channel-artifacts/genesis.block:/var/hyperledger/orderer/orderer.genesis.block
    # 对 msp 文件夹的映射
    - ../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp:/var/hyperledger/orderer/msp
    # 对 tls 文件夹的映射
    - ../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/:/var/hyperledger/orderer/tls
    # 注意，这一步需要的命名卷，实际上就是要在 docker-compose-cli 里被顶层 volume 实例化
    - orderer.example.com:/var/hyperledger/production/orderer
    ports:
      - 7050:7050

  peer0.org1.example.com:
    # 经典的继承语法
    container_name: peer0.org1.example.com
    extends:
      file: peer-base.yaml
      service: peer-base
    environment:
      - CORE_PEER_ID=peer0.org1.example.com
      - CORE_PEER_ADDRESS=peer0.org1.example.com:7051
      # 外部的流言地址，和本机的 peer 地址一样
      - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org1.example.com:7051
      - CORE_PEER_LOCALMSPID=Org1MSP
    volumes:
        - /var/run/:/host/var/run/
        # peer 容器必备：MSP 与 TLS 文件夹
        - ../crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp:/etc/hyperledger/fabric/msp
        - ../crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls:/etc/hyperledger/fabric/tls
        - peer0.org1.example.com:/var/hyperledger/production
    ports:
      - 7051:7051
      - 7053:7053

  peer1.org1.example.com:
    container_name: peer1.org1.example.com
    extends:
      file: peer-base.yaml
      service: peer-base
    environment:
      - CORE_PEER_ID=peer1.org1.example.com
      - CORE_PEER_ADDRESS=peer1.org1.example.com:7051
      - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer1.org1.example.com:7051
      - CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org1.example.com:7051
      - CORE_PEER_LOCALMSPID=Org1MSP
    volumes:
        - /var/run/:/host/var/run/
        - ../crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp:/etc/hyperledger/fabric/msp
        - ../crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls:/etc/hyperledger/fabric/tls
        - peer1.org1.example.com:/var/hyperledger/production

    ports:
      - 8051:7051
      - 8053:7053

  peer0.org2.example.com:
    container_name: peer0.org2.example.com
    extends:
      file: peer-base.yaml
      service: peer-base
    environment:
      - CORE_PEER_ID=peer0.org2.example.com
      - CORE_PEER_ADDRESS=peer0.org2.example.com:7051
      - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org2.example.com:7051
      - CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org2.example.com:7051
      - CORE_PEER_LOCALMSPID=Org2MSP
    volumes:
        - /var/run/:/host/var/run/
        - ../crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp:/etc/hyperledger/fabric/msp
        - ../crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls:/etc/hyperledger/fabric/tls
        - peer0.org2.example.com:/var/hyperledger/production
    ports:
      - 9051:7051
      - 9053:7053
  # 所有节点的变化：
  # 1 修改 service name。
  # 2 修改 container_name
  # 3 修改本 peer 地址
  # 4 修改 gossip 相关，实际上还是本机地址
  peer1.org2.example.com:
    container_name: peer1.org2.example.com
    extends:
      file: peer-base.yaml
      service: peer-base
    environment:
      - CORE_PEER_ID=peer1.org2.example.com
      - CORE_PEER_ADDRESS=peer1.org2.example.com:7051
      - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer1.org2.example.com:7051
      - CORE_PEER_GOSSIP_BOOTSTRAP=peer1.org2.example.com:7051
      - CORE_PEER_LOCALMSPID=Org2MSP
    volumes:
        - /var/run/:/host/var/run/
        - ../crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/msp:/etc/hyperledger/fabric/msp
        - ../crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls:/etc/hyperledger/fabric/tls
        - peer1.org2.example.com:/var/hyperledger/production
    ports:
      - 10051:7051
      - 10053:7053
```

### 对 Cli 容器而言

在cli 容器内的的Gopath 就是普通的 /opt/gopath。

在容器内有四个已经写好的目录，要映射到本地目录上才能用，映射关系大致是：

./../chaincode/:/opt/gopath/src/github.com/hyperledger/fabric/examples/chaincode/go
./scripts:/opt/gopath/src/github.com/hyperledger/fabric/peer/scripts/：脚本的位置，这里应该可以放一些让容器外的控制命令操纵整个 fabric 的脚本。
./channel-artifacts:/opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts：当然这就是 channel 的器物所在地了。 本身的相关文件的放置地。

```yaml
version: '2'

# 官方文档的释义，大义是顶级的 volume 元素是为了在不同的 service 之间共享 volume 而准备的。
# You can mount a host path as part of a definition for a single service, and there is no need to define it in the top level volumes key.
# But, if you want to reuse a volume across multiple services, then define a named volume in the top-level volumes key. Use named volumes with services, swarms, and stack files.
volumes:
  # 这个语法相当于声明了若干个命名卷。不同的容器之间把相同的卷挂载到自己本地的路径里，就相当于打通了两个容器的数据共享。
  # 注意，命名卷的开头并不是路径形式的，所以不要求当前的 host 有这个名字的绝对路径或者相对路径。
  orderer.example.com:
  peer0.org1.example.com:
  peer1.org1.example.com:
  peer0.org2.example.com:
  peer1.org2.example.com:

# 一个顶级网络名称，供服务之间引用
networks:
  byfn:

services:
  orderer.example.com:
    extends:
      file:   base/docker-compose-base.yaml
      service: orderer.example.com
    # 在这里虽然可以覆盖 container name，但有必要么？
    container_name: orderer.example.com
    networks:
      # 这是要加入的网络名称
      - byfn

  peer0.org1.example.com:
    container_name: peer0.org1.example.com
    extends:
      file:  base/docker-compose-base.yaml
      service: peer0.org1.example.com
    networks:
      - byfn

  peer1.org1.example.com:
    container_name: peer1.org1.example.com
    extends:
      file:  base/docker-compose-base.yaml
      service: peer1.org1.example.com
    networks:
      - byfn

  peer0.org2.example.com:
    container_name: peer0.org2.example.com
    extends:
      file:  base/docker-compose-base.yaml
      service: peer0.org2.example.com
    networks:
      - byfn

  peer1.org2.example.com:
    container_name: peer1.org2.example.com
    extends:
      file:  base/docker-compose-base.yaml
      service: peer1.org2.example.com
    networks:
      - byfn

  cli:
    container_name: cli
    # 这里不继承任何配置文件，而是直接使用镜像初始化容器
    image: hyperledger/fabric-tools:$IMAGE_TAG
    tty: true
    environment:
      - GOPATH=/opt/gopath
      - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
      - CORE_LOGGING_LEVEL=DEBUG
      - CORE_PEER_ID=cli
      - CORE_PEER_ADDRESS=peer0.org1.example.com:7051
      - CORE_PEER_LOCALMSPID=Org1MSP
      - CORE_PEER_TLS_ENABLED=true
      - CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
      - CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
      - CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
      - CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    working_dir: /opt/gopath/src/github.com/hyperledger/fabric/peer
    command: /bin/bash -c './scripts/script.sh ${CHANNEL_NAME} ${DELAY}; sleep $TIMEOUT'
    volumes:
        # host 上路径: 容器内路径
        # 映射本机的运行时配置文件到容器内。
        - /var/run/:/host/var/run/
        # ：这就是链码的主要位置了，看来这个目录也是镜像里就写死的，要写自定义的链码也只能从这里安装进去。
        - ./../chaincode/:/opt/gopath/src/github.com/hyperledger/fabric/examples/chaincode/go
        - ./crypto-config:/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/
        - ./scripts:/opt/gopath/src/github.com/hyperledger/fabric/peer/scripts/
        - ./channel-artifacts:/opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts
    depends_on:
      # 等这些 service 启动完了，再启动自己这个 service。
      - orderer.example.com
      - peer0.org1.example.com
      - peer1.org1.example.com
      - peer0.org2.example.com
      - peer1.org2.example.com
    networks:
      - byfn
```