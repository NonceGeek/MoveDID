---
title: "MoveDID VC Specification"
slug: "/movedid/movedid-vc-specification"
hidden: false
sidebar_position: 4
hide_table_of_contents: true
---

# MoveDID Verfiable Credential Specification

## 1 W3C & VC Data Model

> 可驗證數字憑證（Verifiable Credentials: VC）是安全數字身份世界裡的下一個前沿領域。它們解決瞭如今我們在文件和身份方面所面臨的許多問題。
>
> 這是一項相對較新的技術，在將其與現實場景聯繫時存在一定的困難，這篇文章旨在削弱這一困難。文章提出的使用案例是可以應用可驗證數字憑證（VC）的一些潛在領域，擁有巨大的發展空間。具體來說，我們希望商業領袖、企業家和開發人員能夠以這篇文章為參考，創造一些突破性的解決方案，使社會受益。
>
> —— https://web3caff.com/zh_tc/archives/19572

[Verifiable Credentials Data Model](https://www.w3.org/TR/vc-data-model-2.0/) is also a member of the W3C standards. Regarding the concept of VC, we can refer to the description in the specification:

> This section is non-normative.
> 
> In the physical world, a credential might consist of:
> 
> Information related to identifying the subject of the credential (for example, a photo, name, or identification number)
> Information related to the issuing authority (for example, a city government, national agency, or certification body)
> Information related to the type of credential (for example, a Dutch passport, an American driving license, or a health > insurance card)
> Information related to specific properties asserted by the issuing authority about the subject (for example, nationality, date of birth, or the classes of vehicle they're qualified to drive)
> Evidence by which a subject was demonstrated to have satisfied the qualifications required for issuance of the credential (for example, a measurement, proof of citizenship, or test result)
> Information related to constraints on the credential (for example, validity period, or terms of use).
> A verifiable credential can represent all the same information that a physical credential represents. Adding technologies such as digital signatures can make verifiable credentials more tamper-evident and trustworthy than their physical counterparts.
> 
> Holders of verifiable credentials can generate verifiable presentations and then share these verifiable presentations with verifiers to prove they possess verifiable credentials with specific characteristics.
> 
> Both verifiable credentials and verifiable presentations can be transmitted rapidly, making them more convenient than their physical counterparts when establishing trust at a distance.
> 
> While this specification attempts to improve the ease of expressing digital credentials, it also aims to balance this goal with several privacy-preserving goals. The persistence of digital information, and the ease with which disparate sources of digital data can be collected and correlated, comprise a privacy concern that the use of verifiable and easily machine-readable credentials threatens to make worse. This document outlines and attempts to address several of these issues in Section 8. Privacy Considerations. Examples of how to use this data model using privacy-enhancing technologies, such as zero-knowledge proofs, are also provided throughout this document.
> 
> The word "verifiable" in the terms verifiable credential and verifiable presentation refers to the characteristic of a credential or presentation as being able to be verified by a verifier, as defined in this document. Verifiability of a credential does not imply the truth of claims encoded therein. Instead, upon establishing the authenticity and currency of a verifiable credential or verifiable presentation, a verifier validates the included claims using their own business rules before relying on them. Such reliance only occurs after evaluating the issuer, the proof, the subject, and the claims against one or more verifier policies.
>
> —— https://www.w3.org/TR/vc-data-model-2.0/#what-is-a-verifiable-credential

## 2 The Simplest Implementation of VC

Many Verifiable Credential designs prioritize "privacy protection." However, we believe that solving privacy protection challenges may provide intellectual satisfaction for technical personnel, but from a "commercial implementation" perspective, it's not something that should be considered when implementing the MVP (Minimum Viable Product) version of the VC Model.

![ecosystem](https://p.ipic.vip/0vun6p.png)

This diagram effectively illustrates the simplest model of Verifiable Credentials, including three roles and one object:

> Issuer, Holder, Verifier, and Verifiable Data Registry

Therefore, if we consider "privacy issues" as optional in the simplest implementation of VC, then by adding the Holder Address as a field in the property_map based on the [Aptos Token Standard](https://aptos.dev/en/build/smart-contracts/aptos-token), we have implemented the VC model on Move!

We have already attempted this in the latest version of the MoveDID contract:

> https://explorer.movementlabs.xyz/account/0x61b96051f553d767d7e6dfcc04b04c28d793c8af3d07d3a43b4e2f8f4ca04c9f/modules/run/init/init?network=mainnet

When users initialize their DID, an NFT Token is automatically minted as a VC. This VC has a unique identifier, and the Minter's Address is recorded in the property_map.










 
