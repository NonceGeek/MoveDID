# MoveDID
see docs in:

> https://did.noncegeek.com

DID protocol compatible with Aptos/Sui/Starcoin, including Contracts,Demo & SDK.
The implementation follows the [did@w3c](https://www.w3.org/TR/did-core/)

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

see the latest guide in:

> https://aptos.dev/cli-tools/aptos-cli-tool/use-aptos-cli

* step 0x01: run a local testnet

```
aptos node run-local-testnet --with-faucet
```

* step 0x02: create an account

```
aptos init --profile local --rest-url http://localhost:8080 --faucet-url
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

// TODO
