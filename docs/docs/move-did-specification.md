---
title: "MoveDID Specification"
slug: "/move-did-specification"
hidden: false
sidebar_position: 4
hide_table_of_contents: true
---

# MoveDID Specification

## 1 W3C 与 DID 规范

> 為解決網絡應用中不同平台、技術和開發者帶來的不相容問題，保障網絡資訊流通得順利完整，萬維網聯盟（W3C）制定了一系列標準並督促網絡應用開發者和內容提供者遵循這些標準。標準的內容包括使用語言的規範，開發中使用的導則和解釋引擎的行為等等。W3C也制定了包括[XML](https://zh.m.wikipedia.org/wiki/XML)和[CSS](https://zh.m.wikipedia.org/wiki/CSS)等的眾多影響深遠的標準規範。
>
> —— [Wikipedia](https://zh.m.wikipedia.org/zh-hk/%E4%B8%87%E7%BB%B4%E7%BD%91%E8%81%94%E7%9B%9F)

[Decentralized Identifiers（DID）](https://www.w3.org/TR/did-core)是 W3C 标准中的一员，关于 DID 的概念我们可以查看规范中的描述：

> 作为个人和组织，我们中的许多人在各种各样的环境中使用全球唯一标识符。 它们充当通信地址（电话号码、电子邮件地址、社交媒体上的用户名）、身份证号码（用于护照、驾驶执照、税号、健康保险）和产品标识符（序列号、条形码、RFID）。 URI（统一资源标识符）用于 Web 上的资源，您在浏览器中查看的每个网页都有一个全球唯一的 URL（统一资源定位符）。
>
> 这些全球唯一标识符中的绝大多数不在我们的控制之下。 它们由外部权威机构发布，这些权威机构决定它们指的是谁或什么以及何时可以撤销。 它们仅在某些情况下有用，并且仅被某些非我们选择的机构认可。 它们可能会随着组织的失败而消失或不再有效。 他们可能会不必要地泄露个人信息。 在许多情况下，它们可能会被恶意第三方以欺诈方式复制和断言，这通常被称为“身份盗用”。
>
> 本规范中定义的分散标识符（DID）是一种新型的全球唯一标识符。 它们旨在使个人和组织能够使用他们信任的系统生成自己的标识符。 这些新标识符使实体能够通过使用数字签名等加密证明进行身份验证来证明对其的控制。
>
> —— https://www.w3.org/TR/did-core/#introduction

## 2 DID Document

DID Document 是 DID 规范的核心。DID Document 是由 Address Aggregator 和 Service Aggregator 组成的 JSON 文档。

DID Documents 的例子可见：

> https://www.w3.org/TR/did-core/#did-documents
>
> https://www.w3.org/TR/did-core/#example-usage-of-the-service-property

一个抽象的例子：

```json
{
  "@context": [
		……
  ],
  "verification_method": [
    {
      "id": "did:example:123#key-0",
      "type": "EcdsaSecp256k1VerificationKey2019",
      "address": "0x0",
      "public_key": "0x0" 
    }
  ],
  "service": [
    {
    "id":"did:example:123#linked-domain",
    "name": "LinkedDomains", 
    "url": "https://bar.example.com"
  }]
}
```

## 3 Address 的升级

### 3.1 添加 chains 字段

### 3.2 msg - signature 验证机制



## 4 Service 的升级

然而，w3c 仅是定义了 Service 最基本的格式，在生产环境中，我们需要对 Service 的玩法进行扩展。

### 4.1 支持扩展性 URL

service 的 url 可能适用于 Address Aggregator  中的所有地址，也可能只针对固定的某个地址，因此有必要对 URL 进行扩展：

```bash
https://example.com/{{addr_0 | addr_1 | addr_2}}
```

如果是针对 Address Aggregator 中的所有地址，则可以用：

```bash
https://example.com/{{addrs}}
```

### 4.2 加入 verification_url 字段

和 Address 的验证同理，加入 verification_url，确保 Service User 的确就是 DID Owner 在部分情况下是必要的。例如，我们可以通过 gist verification 的方式对 Github Account 和 DID Owner 的关系进行认证：

```json
{
  "id":"did:example:123#Github",
  "name": "Github", 
  "url": "https://github.com/leeduckgo",
  "verification_url": "https://gist.github.com/leeduckgo/9813ca9e206bbda1afb413ecea331063"
}
```







 
