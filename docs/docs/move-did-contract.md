---
title: "MoveDID Contract"
slug: "/move-did-contract"
sidebar_position: 1
hidden: true
hide_table_of_contents: false
---
# MoveDID Contract

See Source Files in:

> https://github.com/NonceGeek/MoveDID/tree/main/did-aptos

## 0x01 ABI Documentation of MoveDID

In the Aptos Move contract(modules), methods marked as `public entry fun` are publicly accessible.

The main entry in the MoveDID contract  are two modules: 

the `addr_aggregator` module and the `service_aggregator` module.

### 1.1 Addr Aggregator

Namespace: `my_addr::addr_aggregator`

#### 1.1.1 Functions about Addr Aggregator

* `create_addr_aggregator(acct: &signer, type: u64, description: String)`

  **func description:**

  Create the resource addr aggregator. The struct of addr aggregator:

  ```rust
  struct AddrAggregator has key {
    key_addr: address,
    addr_infos_map: Table<String, AddrInfo>,
    addrs: vector<String>,
    type: u64,
    description: String,
    max_id: u64,
    add_addr_event_set: AddAddrEventSet,
    update_addr_signature_event_set: UpdateAddrSignatureEventSet,
    update_addr_event_set: UpdateAddrEventSet,
    delete_addr_event_set: DeleteAddrEventSet,
  }
  ```

  **params description:**

  * **description:** the description of did.
  * **type:** to distinct diffrent subjects of did: `HUMAN -- 0, ORG -- 1, ROBOT --  2`.

* `update_addr_aggregator_description(acct: &signer, description: String)`

  **params description:**

  * **description:** the description of did.

#### 1.1.2 Functions about Addr

* `add_addr(acct: &signer, addr_type: u64, addr: String, pubkey: String, chains: vector<String>, description: String)`

  **func description:**

  Add a new addr. The addr without signature can be used as deposit address,

  **params description:**

  * **addr_type:** `Ethereum -- 0, Aptos --1`.
  * **addr:** the address you would like to add to did, it should be begin with `0x`.
  * **pubkey:** using in key-pairs that can not recovery pubkey from signature.
  * **chains:** where do you use this addr on? for example: `["ethereum", "polygon"]`
  * **description: **the description of the addr you added.

* `update_eth_addr(acct: &signer, addr: String, signature: String) `

  **func description:**

  Update the eth addr that add by `add_addr`, the msg can be saw in `AddrAggregator` resource.

  The address updated with sig could use in more scenes.

* `update_aptos_addr(acct: &signer, addr: String, signature: String)`

  **func description:**

  same as `update-eth-addr`.

* `update_addr_info_with_chains_and_description(acct: &signer, addr: String, chains: vector<String>, description: String)`

  **func description:**

  update addr info with the chains and description. 

* `update_addr_info_for_non_verification(acct: &signer, addr: String, chains: vector<String>, description: String)`

  **func description:**

  It's able to update the addr info that is non verification, such as the token receiver address.

* `delete_addr(acct: &signer, addr: String)`

  **func description:**

  delete addr that is added.

* `batch_add_addrs(acct: &signer, addrs: vector<String>, addr_infos: vector<AddrInfo>)`

  **func description:**

  add addrs in batch way!

### 1.2 Service Aggregator

Namespace: `my_addr::service_aggregator`

* `create_service_aggregator(acct: &signer)`

  **func description:**

  Create the resource addr aggregator. The struct of addr aggregator:

  ```rust
  struct Service has store, copy, drop {
    url: String,
    description: String,
    verification_url: String
  }
  
  struct ServiceAggregator has key {
    key_addr: address,
    services_map: Table<String, Service>,
    names: vector<String>,
    add_service_event_set: AddServiceEventSet,
    update_service_event_set: UpdateServiceEventSet,
    delete_service_event_set: DeleteServiceEventSet,
  }
  ```

* `add_service(acct: &signer, url: String, description: String, verification_url: String`)

  **func description:**

  Add a new service. It's optional to verify the service by msg and verification_url. For example, verify the github account by gist with msg.

  **params description:**

  * **url:** the link of service url.

  * **description:** the description of service
  * **verification_url:** the link of verification of url, the key addr is the msg for payload.

* `update_service(acct: &signer, url: String, new_description: String, new_url: String, new_verification_url: String)`

  **func description:**

  Update the eth service that indexed by the url.

* `delete_service(acct: &signer, url: String)`

  **func description:**

  delete service that is added.
  
* `batch_add_services(acct: &signer, names: vector<String>, services: vector<Service> )`

### 1.3 Addr-*

Namespace: `my_addr::addr-*`, such as:`my_addr:addr-aptos`

Impl `addr-*` module to support more type of address!

* `update_addr(addr_info: &mut AddrInfo, signature: &mut String)`

  type: `public func`

  update addr with signature.

* `update_*_addr(acct: &signer, addr: String, signature: String)`

  update addr func that can be called by signer.

### 1.4 Init

Namespace:`my_addr::init`

* `init(acct: &signer, type: u64, description: String)`

  **func description:**

  Init addr_aggregator and service_aggregator in one func.

## 0x02 Quick Deployment Guide

> Aptos CLI version >=1.0.0

see the latest official guide in:

> https://aptos.dev/cli-tools/aptos-cli-tool/use-aptos-cli

* step 0x01: run a local testnet

```
aptos node run-local-testnet --with-faucet
```

* step 0x02: create an account

```
aptos init --profile local --rest-url http://localhost:8080 --faucet-url http://localhost:8081
export PROFILE=local
```

Tips -- reset local network

```
aptos node run-local-testnet --with-faucet --force-restart
```

* step 0x03: get faucet(devnet)

```
aptos account fund-with-faucet --profile $PROFILE --account $PROFILE
```

* step 0x04: compile contract

```
aptos move compile --package-dir [path]/MoveDID/did-aptos --named-addresses my_addr=$PROFILE
```

* step 0x05: deploy

```
aptos move publish --package-dir [path]/MoveDID/did-aptos --named-addresses my_addr=$PROFILE --profile $PROFILE
```

## 0x03 Prover of MoveDID

see in all the files that ended with `spec.move`.