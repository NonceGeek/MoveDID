module my_addr::addr_aggregator {
   use aptos_framework::signer;
   use aptos_framework::block;
   use std::vector;
   use my_addr::utils;
   // use 0x1::bcs;

   
   struct AddrInfo has store, copy, drop {
      addr: address,
      description: vector<u8>,
      chain_name: vector<u8>,
      msg: vector<u8>,
      signature: vector<u8>,
      id : u64
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
         
      let addr_info = AddrInfo{
         addr: addr, 
         chain_name: chain_name,
         description: description,
         signature: x"",
         // msg: x"",
         msg: msg,
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

   public fun update_addr_with_sig(acct: &signer, 
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


             // verify the timestamp - timestamp_now >= 2h is true



            addr_info.signature = signature;
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



   // // add addr without signature is permitted, and the owner can add signature later.
   // public (script) fun add_addr(
   //    acct: signer, 
   //    addr: address, 
   //    chain_name: vector<u8>, 
   //    description: vector<u8>,
   //    msg: vector<u8>,
   //    signature: vector<u8>) acquires AddrAggregator{
   //    if (Vector::length(&signature) != 0 && Vector::length(&msg) != 0) {
   //       let split_vec = Utils::split_string_by_char(&msg, 0x5f);

   //       // verify the format of msg is valid
   //       if (Vector::length(&mut split_vec) != 3) {
   //          abort 1001
   //       };

   //       // verify the signature for the msg addr_chain_name_timestamp
   //       let addr_bytes =BCS::to_bytes<address>(&addr);
   //       if (!EthSigVerifierV5::verify_eth_sig(copy signature, addr_bytes, msg)) {
   //          abort 1002
   //       };

         

   //       let timestamp_vec = Vector::borrow(&split_vec, 2);
   //       let prev_time = Utils::vec_to_timestamp(*timestamp_vec);
   //       let now_time = Timestamp::now_seconds();
   //       let elapsed_time = now_time - prev_time;

   //       // verify the timestamp - timestamp_now >= 2h is true
   //       if (elapsed_time < 2*60*60) {
   //          abort 1003
   //       };

   //       // then add addr
   //       do_add_addr(&acct, addr, chain_name, description, signature);
   //    } else {
   //       do_add_addr(&acct, addr, chain_name, description, signature);
   //    }
   // }

   // public fun do_add_addr(
   //    acct: &signer, 
   //    addr: address, 
   //    chain_name: vector<u8>, 
   //    description: vector<u8>,
   //    signature: vector<u8>) acquires AddrAggregator{
   //    let addr_aggr = borrow_global_mut<AddrAggregator>(Signer::address_of(acct));   
   //    let id = addr_aggr.max_id + 1;

   //    let addr_info = AddrInfo{
   //       addr: addr, 
   //       chain_name: chain_name,
   //       description: description,
   //       signature: signature,
   //       id : id,
   //    };
   //    Vector::push_back(&mut addr_aggr.addr_infos, addr_info);
   //    addr_aggr.max_id = addr_aggr.max_id + 1;
   // }

   // // public fun update addr with sig
   // public fun  update_addr_with_sig(
   //    acct: signer,  
   //    addr: address,
   //    signature: vector<u8>) acquires AddrAggregator{
   //    let addr_aggr = borrow_global_mut<AddrAggregator>(Signer::address_of(&acct));
   //    let length = Vector::length(&mut addr_aggr.addr_infos);
   //    let i = 0;
   //    while (i < length) {
   //       let addr_info = Vector::borrow_mut<AddrInfo>(&mut addr_aggr.addr_infos, i);
   //       if (addr_info.addr == addr) {
   //          addr_info.signature = signature;
   //          break
   //       };
   //       i = i + 1;
   //    };
   // }

   // // public fun update addr with description and sig
   // public fun update_addr_with_description_and_sig(
   //    acct: signer,  
   //    addr: address,
   //    signature: vector<u8>,
   //    description: vector<u8>) acquires AddrAggregator{
   //    let addr_aggr = borrow_global_mut<AddrAggregator>(Signer::address_of(&acct));
   //    let length = Vector::length(&mut addr_aggr.addr_infos);
   //    let i = 0;
   //    while (i < length) {
   //       let addr_info = Vector::borrow_mut<AddrInfo>(&mut addr_aggr.addr_infos, i);
   //       if (addr_info.addr == addr) {
   //          addr_info.signature = signature;
   //          addr_info.description = description;
   //          break
   //       };
   //       i = i + 1;
   //    };
   // }

   // // public fun delete addr
   // public(script) fun delete_addr(
   //    acct: signer,  
   //    addr: address) acquires AddrAggregator{
   //    let addr_aggr = borrow_global_mut<AddrAggregator>(Signer::address_of(&acct));
   //    let length = Vector::length(&mut addr_aggr.addr_infos);
   //    let i = 0;
   //    while (i < length) {
   //       let addr_info = Vector::borrow(&mut addr_aggr.addr_infos, i);
   //       if (addr_info.addr == addr) {
   //          Vector::remove(&mut addr_aggr.addr_infos, i);
   //          break
   //       };
   //       i = i + 1;
   //    }
   // }

   // // public fun show_addr() {
   // //    Debug::print(&result);
   // // }
}