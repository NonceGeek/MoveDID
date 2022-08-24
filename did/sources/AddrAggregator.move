module MyAddr::AddrAggregator {
   use StarcoinFramework::Vector;
   use StarcoinFramework::Signer;
   use StarcoinFramework::Timestamp;
   use StarcoinFramework::Signature;
   use StarcoinFramework::BCS;
   use StarcoinFramework::Option::{Self, Option};
   use MyAddr::Utils;
   #[test_only]
   use StarcoinFramework::Debug;

   struct AddrInfo has store, copy, drop {
      addr: address,
      description: vector<u8>,
      chain_name: vector<u8>,
      signature: vector<u8>,
      id : u64
   }

   struct AddrAggregator has key {
      key_addr: address,
      addr_infos: vector<AddrInfo>,
      max_id : u64
   }

   public fun create_addr_aggregator(acct: &signer){
      let addr_aggr =  AddrAggregator{
         key_addr: Signer::address_of(acct),
         addr_infos: Vector::empty<AddrInfo>(),
         max_id : 0
      };
      move_to<AddrAggregator>(acct, addr_aggr);
   }

   /// add addr without signature is permitted, and the owner can add signature later.
   public fun add_addr(
      acct: &signer, 
      addr: address, 
      chain_name: vector<u8>, 
      description: vector<u8>,
      msg: Option<vector<u8>>,
      signature: Option<vector<u8>>) acquires AddrAggregator{
      if (Option::is_some<vector<u8>>(&signature) && Option::is_some<vector<u8>>(&msg)) {
         let msg_bytes = Option::borrow(&msg);
         let signature_bytes = Option::borrow(&signature);
         let split_vec = Utils::split_string_by_char(msg_bytes, 0x5f);

         // verify the format of msg is valid
         if (Vector::length(&mut split_vec) != 3) {
            abort 1001
         };

         // verify the signature for the msg addr_chain_name_timestamp
         let addr_bytes =BCS::to_bytes<address>(&addr);
         if (!Signature::secp256k1_verify(*signature_bytes, addr_bytes, *msg_bytes)) {
            abort 1002
         };

         let timestamp_vec = Vector::borrow(&split_vec, 2);
         let prev_time = Utils::vec_to_timestamp(*timestamp_vec);
         let now_time = Timestamp::now_seconds();
         let elapsed_time = now_time - prev_time;

         // verify the timestamp - timestamp_now >= 2h is true
         if (elapsed_time < 2*60*60) {
            abort 1003
         };

         // then add addr
         do_add_addr(acct, addr, chain_name, description, Option::destroy_some<vector<u8>>(signature));
      } else {
         do_add_addr(acct, addr, chain_name, description, Vector::empty());
      }
   }

   public fun do_add_addr(
      acct: &signer, 
      addr: address, 
      chain_name: vector<u8>, 
      description: vector<u8>,
      signature: vector<u8>) acquires AddrAggregator{
      let addr_aggr = borrow_global_mut<AddrAggregator>(Signer::address_of(acct));   
      let id = addr_aggr.max_id + 1;

      let addr_info = AddrInfo{
         addr: addr, 
         chain_name: chain_name,
         description: description,
         signature: signature,
         id : id,
      };
      Vector::push_back(&mut addr_aggr.addr_infos, addr_info);
      addr_aggr.max_id = addr_aggr.max_id + 1;
   }

   // public fun update addr with sig
   public fun  update_addr_with_sig(
      acct: &signer,  
      addr: address,
      signature: vector<u8>) acquires AddrAggregator{
      let addr_aggr = borrow_global_mut<AddrAggregator>(Signer::address_of(acct));
      let length = Vector::length(&mut addr_aggr.addr_infos);
      let i = 0;
      while (i < length) {
         let addr_info = Vector::borrow_mut<AddrInfo>(&mut addr_aggr.addr_infos, i);
         if (addr_info.addr == addr) {
            addr_info.signature = signature;
            break
         }
      };
   }

   // public fun update addr with description and sig
   public fun update_addr_with_description_and_sig(
      acct: &signer,  
      addr: address,
      signature: vector<u8>,
      description: vector<u8>) acquires AddrAggregator{
      let addr_aggr = borrow_global_mut<AddrAggregator>(Signer::address_of(acct));
      let length = Vector::length(&mut addr_aggr.addr_infos);
      let i = 0;
      while (i < length) {
         let addr_info = Vector::borrow_mut<AddrInfo>(&mut addr_aggr.addr_infos, i);
         if (addr_info.addr == addr) {
            addr_info.signature = signature;
            addr_info.description = description;
            break
         }
         i = i + 1;
      };
   }

   // public fun delete addr
   public fun delete_addr(
      acct: &signer,  
      addr: address) acquires AddrAggregator{
      let addr_aggr = borrow_global_mut<AddrAggregator>(Signer::address_of(acct));
      let length = Vector::length(&mut addr_aggr.addr_infos);
      let i = 0;
      while (i < length) {
         let addr_info = Vector::borrow(&mut addr_aggr.addr_infos, i);
         if (addr_info.addr == addr) {
            Vector::remove(&mut addr_aggr.addr_infos, i);
         }
         i = i + 1;
      }
   }
}