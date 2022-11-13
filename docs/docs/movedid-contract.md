---
title: "MoveDID Contract"
slug: "/movedid-contract"
hidden: true
hide_table_of_contents: false
---
# MoveDID Contract

## 0x01 ABI Documentation of MoveDID

In the Aptos Move contract(modules), methods marked as `public entry fun` are publicly accessible.

The main entry in the MoveDID contract  are two modules: 

the `addr_aggregator` module and the `endpoint_aggregator` module.

### 1.1 Addr Aggregator

* `create_addr_aggregator(acct: &signer, type: u64, description: String)`

  **func description:**

  Create the resource addr aggregator. The struct of addr aggregator:

  ```rust
  struct AddrAggregator has key {
    key_addr: address,
    addr_infos: vector<AddrInfo>,
    type: u64,
    description: String,
    max_id: u64,
  }
  struct AddrInfo has store, copy, drop {
    addr: String,
    description: String,
    chains: vector<String>,
    msg: String,
    signature: vector<u8>,
    created_at: u64,
    updated_at: u64,
    id: u64,
    addr_type: u64,
  }
  ```

  **params description:**

  * **description:** the description of did.
  * **type:** to distinct diffrent subjects of did: `HUMAN -- 0, ORG -- 1, ROBOT --  2`.

* `add_addr(acct: &signer, addr_type: u64, addr: String,chains: vector<String>, description: String)`

  **func description:**

  Add a new addr. The addr without signature can be used as deposit address,

  **params description:**

  * **addr_type:** `Ethereum -- 0, Aptos --1`.
  * **addr:** the address you would like to add to did.
  * **chains:** where do you use this addr on? for example: `["ethereum", "polygon"]`
  * **description: **the description of the addr you added.

* `update_eth_addr(acct: &signer, addr: String, signature: String) `

  **func description:**

  Update the eth addr that add by `add_addr`, the msg can be saw in `AddrAggregator` resource.

  The address updated with sig could use in more scenes.

* `update_aptos_addr(acct: &signer, addr: String, signature: String, pubkey: String)`

  **func description:**

  same as `update-eth-addr`.

* `delete_addr(acct: &signer, addr: String)`

  **func description:**

  delete addr that is added.

### 1.2 Endpoint Aggregator

* `create_endpoint_aggregator(acct: &signer)`

  **func description:**

  Create the resource addr aggregator. The struct of addr aggregator:

  ```rust
  struct Endpoint has store, copy, drop {
    url: String,
    description: String,
    msg: String,
    verification_url: String
  }
  struct EndpointAggregator has key {
    key_addr: address,
    endpoints: vector<Endpoint>
  }
  ```

* `add_endpoint(acct: &signer, url: String, description: String, verification_url: String`)

  **func description:**

  Add a new endpoint. It's optional to verify the endpoint by msg and verification_url. For example, verify the github account by gist with msg.

  **params description:**

  * **description:** the description of endpoint
  * **verification_url:** the link of verification of url, the key addr is the msg for payload.

* `update_endpoint(acct: &signer, url: String, new_description: String,new_url: String, new_verification_url: String)`

  **func description:**

  Update the eth endpoint that indexed by the url.

* `delete_endpoint(acct: &signer, url: String)`

  **func description:**

  delete endpoint that is added.

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

## 0x03 How to Append Module Dynamic?

## 0x04 Source Code Analysis

## 0x05 Prover of MoveDID