module MyAddr::AddrAggregatorV5 {
   use StarcoinFramework::Vector;
   use StarcoinFramework::Signer;
   use StarcoinFramework::Option::{Self, Option};

   /// Msg should be change to timestamp later.
   struct AddrInfo has store, copy, drop {
      id: u64,
      addr: vector<u8>,
      description: vector<u8>,
      chain_name: vector<u8>,
      msg: vector<u8>,
      signature: vector<u8>
   }

   struct AddrAggregator has key {
      key_addr: address,
      addr_infos: vector<AddrInfo>
   }

   public fun create_addr_aggregator(acct: &signer){
      let addr_aggr =  AddrAggregator{
         key_addr: Signer::address_of(acct),
         addr_infos: Vector::empty<AddrInfo>()
      };
      move_to<AddrAggregator>(acct, addr_aggr);
   }

   /// add addr without signature is permitted, and the owner can add signature later.
   public fun add_addr(
      acct: &signer, 
      addr: vector<u8>,
      chain_name: vector<u8>, 
      description: vector<u8>,
      msg: Option<vector<u8>>,
      signature: Option<vector<u8>>) acquires AddrAggregator{
      if (Option::is_some<vector<u8>>(&signature) && Option::is_some<vector<u8>>(&msg)) {
         // TODO:
         // verify the format of msg is valid:
         // Using EthSigVerifier is fine!
         // verify the signature for the msg addr_chain_name_timestamp
         // verify the timestamp - timestamp_now >= 2h is true
         // then add addr
         // let addr_aggr = borrow_global_mut<AddrAggregator>(Signer::address_of(acct));
         // let id = Vector::length(&addr_aggr.addr_infos);
         // TODO: make id make sense
         do_add_addr(acct, 1, addr, chain_name, description, Option::destroy_some<vector<u8>>(msg), Option::destroy_some<vector<u8>>(signature));
      } else {
         do_add_addr(acct, 1, addr, chain_name, description, Vector::empty(), Vector::empty());
      }
   }

   public fun do_add_addr(
      acct: &signer, 
      id: u64,
      addr: vector<u8>,
      chain_name: vector<u8>, 
      description: vector<u8>,
      msg: vector<u8>,
      signature: vector<u8>) acquires AddrAggregator{
      let addr_aggr = borrow_global_mut<AddrAggregator>(Signer::address_of(acct));
      let addr_info = AddrInfo{
         id: id,
         addr: addr, 
         chain_name: chain_name,
         description: description,
         msg: msg,
         signature: signature
      };
      Vector::push_back(&mut addr_aggr.addr_infos, addr_info);
   }
   // TODO:
   // public fun update addr with sig
   // public fun update addr with description and sig
   // public fun delete addr

   /* --- scripts --- */

   public(script) fun init_addr_aggregator(account: signer){
      Self::create_addr_aggregator(&account)
   }
   
   public(script) fun script_add_addr_unverified(
      account: signer, 
      addr: vector<u8>,
      chain_name: vector<u8>, 
      description: vector<u8>) acquires AddrAggregator {
      Self:: do_add_addr(&account, 1, addr, chain_name, description, Vector::empty(), Vector::empty())
   }

   public(script) fun script_add_addr_verified(
      account: signer, 
      addr: vector<u8>,
      chain_name: vector<u8>, 
      description: vector<u8>,
      msg: vector<u8>,
      signature: vector<u8>
      ) acquires AddrAggregator {
      Self:: do_add_addr(&account, 1, addr, chain_name, description, msg, signature)
   }
}
