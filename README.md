# MoveDID

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fmovebit%2Fmaterials%2Fmain%2Fshields.json)](https://github.com/NonceGeek/MoveDID/blob/main/MoveDID-Audit-Report.pdf)

![move-did (1)](https://p.ipic.vip/azpoeq.png)

MoveDID is a DID protocol that is implemented Aptos.The vision of MoveDID is to be the foundation for the next generation of large-scale Web3 finance and Web3 society. MoveDID could be used for 3 types of subjects: human, organization, and bot.
The implementation follows the [did@w3c](https://www.w3.org/TR/did-core/)

! Important Links:

> Homepage:
>
> https://movedid.build
>
> Manager dApp:
>
> https://manager.movedid.build
>
> https://github.com/NonceGeek/scaffold-move
>
> Docs:
>
> https://docs.movedid.build
>
> Twitter:
> https://twitter.com/Move_DID
>
> Deck:
>
> https://github.com/NonceGeek/MoveDID/blob/main/MoveDID-Deck-EN.pdf
>
> Demo Video:
>
> https://youtu.be/LOuQo1XjSxE

! Linked Repos:

> scaffold-move:
> 
> https://github.com/NonceGeek/scaffold-move
>
> homepage:
>
> https://github.com/NonceGeek/MoveDID-Homepage
>
> web3_move_ex sdk:
>
> https://github.com/NonceGeek/web3_move_ex

## Dev Modules on Move Chains

* Aptos:

> https://explorer.aptoslabs.com/account/0x65f4a0954aa6e68d2381ff98b7676df2fe57beee3ca37a4a8a57fa621c1db872/modules

## 🏆 Prizes

Dorahack Aptos Grant DAO Prize 2nd: 

> https://dorahacks.io/zh/aptos/2/top

## Parts

* did contracts:
  The did contracts in MOVE Lang.

  * [x] aptos ( audited)

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
aptos move run --function-id 1f9aa0aa17a3c8b02546df9353cdbee47f14bcaf25f5524492a17a8ab8c906ee::addr_aggregator::add_addr --args u64:0 --args String:a5928A4b811b6F850e633Dfb9f9c4B50247565a9 --args String:Ethereum --args String:Test --profile
```
* step 0x09: update addr for add new type 

## Guide of New Module Addition

0x01: add new chain type module file, like addr_eth.move; add constant variable  and implement update_addr fun.

example: 

```Rust
//eth addr type
const ADDR_TYPE_ETH: u64 = 0;

//eth addr length
const ETH_ADDR_LEGNTH: u64 = 40;

// err enum
const ERR_INVALID_ETH_ADDR: u64 = 2001;

public fun update_addr(addr_info: &mut AddrInfo, signature : &mut String) {
    ...
}
```

0x02: continue the second step, put the third step update_addr to the specify chain's update_*_addr fun.

example: 
```Rust
public entry fun update_eth_addr(acct: &signer,
      addr: String, signature : String) acquires AddrAggregator {
      ...
       while (i < length) {
         let addr_info = vector::borrow_mut<AddrInfo>(&mut addr_aggr.addr_infos, i);

         if (addr_info::equal_addr(addr_info, addr)) {
            addr_eth::update_addr(addr_info, &mut signature);
            break
         };
         i = i + 1;
      };
      ...
}  
```
