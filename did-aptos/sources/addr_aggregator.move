module my_addr::addr_aggregator {
   use aptos_framework::signer;
   use aptos_framework::block;
   use aptos_framework::timestamp;
   use std::vector;
   use my_addr::utils;
   use my_addr::eth_sig_verifier;
   use 0x1::bcs;

   
   struct AddrInfo has store, copy, drop {
      addr: address,
      description: vector<u8>,
      chain_name: vector<u8>,
      msg: vector<u8>,
      signature: vector<u8>,
      created_at: u64,
      updated_at: u64,
      id : u64,
   }

   struct AddrAggregator has key {
      key_addr: address,
      addr_infos: vector<AddrInfo>,
      max_id : u64
   }

   public entry fun create_addr_aggregator(acct: &signer){
      let addr_aggr =  AddrAggregator{
         key_addr: signer::address_of(acct),
         addr_infos: vector::empty<AddrInfo>(),
         max_id : 0
      };
      move_to<AddrAggregator>(acct, addr_aggr);
   }

   public entry fun add_addr(acct: &signer, 
      addr: address, 
      chain_name: vector<u8>,
      description: vector<u8>) acquires AddrAggregator {
      let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));   
      let id = addr_aggr.max_id + 1;
      
      let height = block::get_current_block_height();

      let msg = utils::u64_to_vec_u8(height);
      let now = timestamp::now_seconds();
         
      let addr_info = AddrInfo{
         addr: addr, 
         chain_name: chain_name,
         description: description,
         signature: x"",
         msg: msg,
         created_at: now,
         updated_at: 0,
         id : id,
      };
      vector::push_back(&mut addr_aggr.addr_infos, addr_info);
      addr_aggr.max_id = addr_aggr.max_id + 1;
   }

   public fun get_msg(contract: address, addr: address) :vector<u8> acquires AddrAggregator {
      let addr_aggr = borrow_global_mut<AddrAggregator>(contract);
      let length = vector::length(&mut addr_aggr.addr_infos);
      let i = 0;
    
      while (i < length) {
         let addr_info = vector::borrow_mut<AddrInfo>(&mut addr_aggr.addr_infos, i);
         if (addr_info.addr == addr) {
            // addr_info.signature = signature;
            return addr_info.msg
         };
      };

      return x""
   }

   public entry fun update_addr_with_sig(acct: &signer, 
      addr: address, signature : vector<u8>) acquires AddrAggregator {
      let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));
      let length = vector::length(&mut addr_aggr.addr_infos);
      let i = 0;
      while (i < length) {
         let addr_info = vector::borrow_mut<AddrInfo>(&mut addr_aggr.addr_infos, i);
         if (addr_info.addr == addr) {
            if (addr_info.msg == x"") {
               abort 1001
            };

            // verify the signature for the msg 
            let addr_byte = bcs::to_bytes(&addr);
            if (eth_sig_verifier::verify_eth_sig(signature, addr_byte, addr_info.msg)) {
               abort 1002
            };

            // verify the now - created_at <= 2h 
            let now = timestamp::now_seconds();
            if (now - addr_info.created_at > 2*60*60) {
               abort 1003
            };

            // update signature, updated_at 
            addr_info.signature = signature;
            addr_info.updated_at = now;
            break
         };
         i = i + 1;
      };
   }

   // public fun delete addr
   public entry fun delete_addr(
      acct: signer,  
      addr: address) acquires AddrAggregator{
      let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(&acct));
      let length = vector::length(&mut addr_aggr.addr_infos);
      let i = 0;
      while (i < length) {
         let addr_info = vector::borrow(&mut addr_aggr.addr_infos, i);
         if (addr_info.addr == addr) {
            vector::remove(&mut addr_aggr.addr_infos, i);
            break
         };
         i = i + 1;
      }
   }
}