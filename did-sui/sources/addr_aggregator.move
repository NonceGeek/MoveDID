module my_addr::addr_aggregator {
   use sui::transfer;
   use sui::object::{Self, UID};
   use sui::tx_context::{Self, TxContext};
   use std::string::{Self, String};
   use std::vector;
   use my_addr::utils;
   use my_addr::eth_sig_verifier;
   use sui::ecdsa;

   //addr type enum
   const ADDR_TYPE_ETH: u64 = 1;
   const ADDR_TYPE_ED25519: u64 = 2;

   //err enum
   const ERR_ADDR_INFO_MSG_EMPTY: u64 = 1001;
   const ERR_SIGNATURE_VERIFY_FAIL: u64 = 1002;
   const ERR_TIMESTAMP_EXCEED: u64 = 1003;

   const ERR_INVALID_ADR_TYPE: u64 = 2000;
   const ERR_INVALID_SECP256K1_ADDR: u64 = 2001;
   //secp256k1
   const ERR_INVALID_ED25519_ADDR: u64 = 2002;   //ed25519

   struct AddrInfo has store, copy, drop {
      aid : u64,
      addr: String,
      description: String,
      chain_name: String,
      msg: String,
      signature: vector<u8>,
      addr_type: u64,
   }

   struct AddrAggregator has key {
      id: UID,
      key_addr: address,
      addr_infos: vector<AddrInfo>,
      max_id: u64,
   }

   // init
   public entry fun create_addr_aggregator(ctx: &mut TxContext) {
      transfer::share_object(AddrAggregator {
         id: object::new(ctx),
         key_addr: tx_context::sender(ctx),
         addr_infos: vector::empty<AddrInfo>(),
         max_id: 0
      });

      transfer::transfer( AddrAggregator{
         id: object::new(ctx),
         key_addr: tx_context::sender(ctx),
         addr_infos: vector::empty<AddrInfo>(),
         max_id: 0
      }, tx_context::sender(ctx))
   }



   // add addr
   public entry fun add_addr(agg: &mut AddrAggregator, addr_type: u64, addr: String, chain_name: String, description: String) {
      assert!(addr_type == ADDR_TYPE_ETH || addr_type == ADDR_TYPE_ED25519, ERR_INVALID_ADR_TYPE);

      if (addr_type == ADDR_TYPE_ETH) {
         assert!(string::length(&addr) == 40, ERR_INVALID_SECP256K1_ADDR)
      } else (
         assert!(string::length(&addr) == 64, ERR_INVALID_ED25519_ADDR)
      );

      // gen msg
      let msg = b".nonce_geek";

      let addr_info = AddrInfo{
         addr,
         chain_name,
         description,
         signature: b"",
         msg: string::utf8(msg),
         aid:0,
         addr_type,
      };

      vector::push_back(&mut agg.addr_infos, addr_info);
      agg.max_id = agg.max_id + 1;
   }

   public entry fun update_addr_with_sig(addr_aggr: &mut AddrAggregator,
      addr: String, signature : String)  {
      let length = vector::length(&mut addr_aggr.addr_infos);
      let i = 0;
      while (i < length) {
         let addr_info = vector::borrow_mut<AddrInfo>(&mut addr_aggr.addr_infos, i);
         if (addr_info.addr == addr) {
            assert!(addr_info.msg != string::utf8(b""), ERR_ADDR_INFO_MSG_EMPTY);

            let sig_bytes = utils::string_to_vector_u8(&signature);
            let addr_byte = utils::string_to_vector_u8(&addr);
            assert!(addr_info.addr_type == ADDR_TYPE_ETH, ERR_INVALID_ADR_TYPE);

            // verify the signature for the msg
            let eth_prefix = b"\x19Ethereum Signed Message:\n";
            let msg_length = string::length(&addr_info.msg);
            let sign_origin = vector::empty<u8>();
            vector::append(&mut sign_origin, eth_prefix);
            vector::append(&mut sign_origin, utils::u64_to_vec_u8_string(msg_length));
            vector::append(&mut sign_origin, *string::bytes(&addr_info.msg));
            let msg_hash = ecdsa::keccak256(&sign_origin); //kecacak256 hash
            assert!(eth_sig_verifier::verify_eth_sig(sig_bytes, addr_byte, msg_hash), ERR_SIGNATURE_VERIFY_FAIL);
            addr_info.signature = sig_bytes;

            break
         };
         i = i + 1;
      };
   }

   // public fun delete addr
   public entry fun delete_addr(
      addr_aggr: &mut AddrAggregator,
      addr: String) {
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