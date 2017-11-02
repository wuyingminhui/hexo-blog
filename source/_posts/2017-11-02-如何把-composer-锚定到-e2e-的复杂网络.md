---
title: 如何把 composer 锚定到 e2e 的复杂网络
date: 2017-11-02 17:21:27
tags:
- Hyperledger
- Composer
- Explorer
---

1. 下载并进入/blockchain-explorer 项目。
2. cd fabric-docker-compose-svt。
3. download_images.sh（不要让 start.sh 代劳，要用特定的版本）。
4. ./start.sh
5. 建立这个隐藏文件夹 /Users/magicliang/.composer-credentials，如果里面有内容要先清空。
6. 把公私钥导入这个文件夹，注意最后一个 keystore 的私钥可能会变化：

```bash
composer identity import -p explorer -u PeerAdmin -c /Users/magicliang/Desktop/Programming/git/blockchain-explorer-cp/fabric-docker-compose-svt/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem -k /Users/magicliang/Desktop/Programming/git/blockchain-explorer-cp/fabric-docker-compose-svt/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/b28b23d7887f9257884953470d04b6207c9187878ad758807505cf3cfe9ea8ee_s
```

7.在已经制作好的网络的 dist 文件夹下执行：

```bash
composer network deploy -a charity-network.bna -p explorer -i PeerAdmin -s randomString
```

8.开启 compose-rest-server：

>$ composer-rest-server
? Enter your Connection Profile Name: explorer
? Enter your Business Network name : charity-network
? Enter your enrollment ID : admin
? Enter your enrollment secret : adminpw
? Specify if you want namespaces in the generated REST API: never use namespaces
? Specify if you want to enable authentication for the REST API using Passport: No
? Specify if you want to enable event publication over WebSockets: Yes
? Specify if you want to enable TLS security for the REST API: No
