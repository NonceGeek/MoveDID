# MoveDID
see docs in:

> https://did.noncegeek.com

DID protocol compatible with Aptos/Sui/Starcoin, including Contracts,Demo & SDK.
The implementation follows the [did@w3c](https://www.w3.org/TR/did-core/)

see example in:

> https://github.com/NonceGeek/move_sdk_ex_liveview_example

## Dev Modules on Move Chains

* Aptos:

> 1f9aa0aa17a3c8b02546df9353cdbee47f14bcaf25f5524492a17a8ab8c906ee
> 
> https://explorer.aptoslabs.com/account/0x1f9aa0aa17a3c8b02546df9353cdbee47f14bcaf25f5524492a17a8ab8c906ee/modules

## Parts

* did contracts:
  The did contracts in MOVE Lang.

  * [ ] aptos
  * [ ] starcoin
  * [ ] sui

* SBT as Verifiable Credential

  The VC implementation by SBT.

* did sdks

  The sdks for did & vc impl by Elixir/Javascript.
  
* did dApp example
  
  The dApp example show how the contract works.

## Compilation & Deployment Guide

### Aptos

> Aptos CLI version >=1.0.0

see the latest guide in:

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

* step 0x03: get faucet

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

* step 0x06: init addr_aggr

```
aptos move run --function-id 1f9aa0aa17a3c8b02546df9353cdbee47f14bcaf25f5524492a17a8ab8c906ee::addr_aggregator::create_addr_aggregator --profile $PROFILE
```

* step 0x07: init endpoint_aggr

```
aptos move run --function-id 1f9aa0aa17a3c8b02546df9353cdbee47f14bcaf25f5524492a17a8ab8c906ee::addr_aggregator::create_endpoint_aggregator --profile $PROFILE
```

* step 0x08: add addr

```
aptos move run --function-id 1f9aa0aa17a3c8b02546df9353cdbee47f14bcaf25f5524492a17a8ab8c906ee::addr_aggregator::add_addr --args u64:1 --args String:a5928A4b811b6F850e633Dfb9f9c4B50247565a9 --args String:Ethereum --args String:Test --profile
```
