## 1 什么是Moveflow

MoveFlow 是建立在 Move 生态系统之上的加密资产流支付协议，它可以实现即时、无缝和不间断的支付流。

### 1.1 赋能加密支付

MoveFlow 有广泛的应用领域，包括实时工资支付、代币空投和解锁、订阅和按使用量付费模式等。

* 实时工资支付：流支付可以帮助公司更顺畅地管理现金流，使员工能够实时收到他们的工资。

* 代币空投和解锁：在解锁项目代币的过程中，可以使用流支付来设置分期释放计划，让投资者可以持续地收到代币。一旦流支付创建，就不可以更改，这减少了投资者遭遇突然撤退的风险。

* 订阅和按使用量付费模式：用户不再需要支付月费，而是在使用服务时进行付款，并在不再使用时停止付款，避免不必要的损失。

### 1.2 DeFi 基础设施

流支付还可以作为 DeFi 开发的基础设施，为 DeFi 带来更多有趣的产品和应用。基于Move生态系统，接收权和发送权的resource可以NFT化，作为有价值资产应用于更多的DeFi领域。

## 2 Moveflow SDK的介绍和安装

### 2.1 Moveflow SDK介绍

Moveflow SDK主要服务于第三方Dapp应用开发，独立开发者，前端等多个对象。用户对象可以方便快捷地跟合约进行交互操作，而无需考虑底层合约的实现方式。

Moveflow SDK提供有流支付的交互接口和查询接口，两种类型接口相互配合完成所有流支付的相关操作。

交互接口列表如下：
* create
* withdraw
* pause
* resume
* close
* extend

查询接口列表如下：
* getStreamById
* withdrawable
* incoming
* outgoing

### 2.2 Moveflow SDK的安装

使用yarn安装Moveflow SDK。

```bash
yarn add @moveflow/sdk.js
```

在代码中导入文件后，可以创建`sdk`实例。

```
import { SDK,TESTNET_CONFIG } from '@moveflow/sdk.js';
    
const sdk = new SDK(TESTNET_CONFIG);
```

## 3 流支付的交互接口解析和使用

### 3.1 创建流

该接口可以创建一条支付流，并且返回交易结果。

```
const payload = sdk.stream.create({
  name : 'test',
  remark : 'test',
  recipientAddr: '0x20f0cbe21cb340fe56500e0889cad03f8a9e54a33e3c4acfc24ce2bdfabc4180',
  depositAmount: 1,
  startTime: start_time,
  stopTime: stop_time,
  coinType: CoinsMapping.APTOS,
  interval: 1,
  canPause: true,
  closeable: true,
  recipientModifiable: true,

})

const txid = await SignAndSubmitTransaction(payload)
```

需要输入的参数有：

* name: 支付流名称。

* remark: 支付流描述。

* recipientAddr: 支付流接收者地址。

* depositAmount: 总共存入的Coin数量。

* startTime: 支付流开始时间，单位为秒。

* stopTime: 支付流结束时间，单位为秒。

* coinType: 支付流的币种，默认为APT。

* interval: 支付周期间隔，默认为1秒。

* canPause: 支付流是否支持暂停，默认为true。

* closeable: 支付流是否支持关闭，默认为true。

* recipientModifiable: 支付流是否支持修改接收者地址, 默认为false。


### 3.2 从支付流中提取Coin

 支付流的接收者从一条支付流中提取Coin。可提取的Coin数量从上次提取时间起算到当前时间，每满一个提取周期获得相应数量的coin提取权限。

```

const payload = sdk.stream.withdraw({
  id： 30，
  coinType: AptosCoin,
})

const response = await SignAndSubmitTransaction(payload)
```

需要输入的参数有：

* id: 支付流的Id。

* coinType: 支付流的币种，默认为APT。

**获取支付流的Id**

接收者从支付流中提取Coin时需要指定支付流的id，支付流id是一条支付流的唯一标识。Moveflow SDK有单独的接口帮助获取所需要支付流id。

查询接收者的所有输入支付流：通过地址参数，查询该地址作为接收者的所有支付流Id。（详见4.3）

查询发送者的所有输出支付流：通过地址参数，查询该地址作为发送者的所有支付流Id。（详见4.4）

### 3.3 关闭支付流

该接口会审核接口调用权限，只有支付流的发送者才能关闭这条支付流。关闭支付流后，接收者将受到其可提取的Coin，剩余Coin会退回给发送者。

```
const payload = sdk.stream.close({ id: 29 })

const txid = await SignAndSubmitTransaction(payload)
```

需要输入的参数有：

* id: 支付流的Id。

### 3.4 暂停支付流

该接口可以暂停一条支付流，暂停期间接收者不会累积可提取Coin。

```
const payload = sdk.stream.pause({
    id: 29,
    coinType: AptosCoin,
})

const txid = await SignAndSubmitTransaction(payload)
```

需要输入的参数有：

* id: 支付流的Id。

* coinType: 支付流的币种，默认为APT。

### 3.5 恢复支付流

该接口对应于暂停支付流，可以将一条暂停状态的支付流恢复。恢复后接收者可以正常累积可提取Coin。

```
 const payload = sdk.stream.resume({
    id: 29,
    coinType: AptosCoin,
})

const txid = await SignAndSubmitTransaction(payload)
```

需要输入的参数有：

* id: 支付流的Id。

* coinType: 支付流的币种，默认为APT。

### 3.6 扩展支付流

如果支付流的发送者需要以原有支付参数增加新的代币数量，可以通过此接口延长原有支付流的结束时间，无需创建一个新的支付流。

```
const payload = sdk.stream.extend({
    id: 30,
    extraAmount: 300,
    stopTime: '1635724800',
    coinType: AptosCoin,
})

const txid = await SignAndSubmitTransaction(payload)
```

需要输入的参数有：

* id: 支付流的Id。

* extraAmount: 需要额外支持的代币数量。

* stopTime: 支付流新的结束时间，需要存入一定代币数量来延续支付流的支付时间。

* coinType: 支付流的币种，默认为APT。


## 4 流支付的查询接口的解析和使用

### 4.1 查询支付流信息

通过指定的支付流id获取支付流的信息。

```
const id = 30

const streams = await sdk.stream.getStreamById(id)

console.log("streams:", streams)
```

支付流的信息包括：

* status: 状态用于支付流的过滤，分为以下七种：Scheduled/Canceled/Streaming/Completed/Paused/Unknown/All

* createTime: 支付流的创建时间

* depositAmount: 支付流中存入的Coin数量

* streamId: 支付流的id

* interval: 支付周期，单位为s

* lastWithdrawTime: 上次提取Coin时间

* ratePerInterval: 每周期支付的Coin数量

* recipientId: 接收者地址

* remainingAmount: 支付流中还剩下的Coin数量，其与depositAmount的差额就是已被提取的Coin数量

* senderId: 发送者地址

* startTime: 开始时间

* stopTime: 结束时间

* withdrawnAmount: 以及接收的金额

* pauseInfo: 支付流的暂停信息，包括暂停状态，暂停开始时间，已暂停时间。

* name: 支付流的名称

* streamedAmount: 已经streamed的金额，从支付流开始到现在可以提取的代币数量

* withdrawableAmount: 接收者当前时间点可以提取的金额，等于streamedAmount减去withdrawnAmount

* escrowAddress: 代理金库地址

支付流信息结构体定义如下：

```
interface StreamInfo {
    status: StreamStatus,
    createTime: string,
    depositAmount: string, 
    streamId: string, 
    interval: string,
    lastWithdrawTime: string, 
    ratePerInterval: string,
    recipientId: string,
    remainingAmount: string, 
    senderId: string, 
    startTime: string, 
    stopTime: string,  
    withdrawnAmount: string, 
    pauseInfo: {
        accPausedTime: string,
        pauseAt: string,
        paused: boolean,
    },
    name: string, // stream's name
    streamedAmount: string,
    withdrawableAmount: string,
    escrowAddress: string,
}
```

### 4.2 查询支付流的可提取Coin数量

查询支付流的可提取Coin数量，也就是到当前时间点支付流已发送的Coin数量减去接收者已提取的Coin数量。

```
const id = 30

const res = await sdk.stream.withdrawable(_id)

console.log("withdrawable res:", res)
```

### 4.3 查询某地址的输入流

以某地址为入参，查询该地址作为接收者的所有支付流的信息。

```
const address = `0x20f0cbe21cb340fe56500e0889cad03f8a9e54a33e3c4acfc24ce2bdfabc4180`

const res = await sdk.stream.getIncomingStreams(address)

console.log("getIncomingStreams res:", res)
```

### 4.4 查询某地址的输出流

以某地址为入参，查询该地址作为发送者的所有支付流的信息。

```
const address = `0x20f0cbe21cb340fe56500e0889cad03f8a9e54a33e3c4acfc24ce2bdfabc4180`

const res = await sdk.stream.getOutgoingStreams(address)

console.log("getOutgoingStreams res:", res)
```

## 5 Demo展示
在可以体验demo展示：

> https://moveflow-aptos-sdk-demo.vercel.app/

Demo 源码：

> https://github.com/Move-Flow/sdk.js/tree/lyb/aptos-sdk/examples/demo

## 6 总结

目前Moveflow SDK为1.0版本，仅支持基于APTOS的合约基本交互。下一步的工作将提供更便捷易用的接口。目前还有若干不足，欢迎大家提出宝贵意见。