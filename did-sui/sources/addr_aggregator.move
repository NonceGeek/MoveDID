module my_addr::addr_aggregator {
   use sui::transfer;
   use sui::object::{Self, UID};
   use sui::tx_context::{Self, TxContext};
   use std::string::{Self, String};
   use sui::vec_map::{Self,VecMap};
   use sui::event;
   use std::vector;
   use my_addr::addr_info::{Self, AddrInfo};
   use my_addr::addr_eth;
   use my_addr::addr_sui;

   // Define addr aggregator type.
   const ADDR_AGGREGATOR_TYPE_HUMAN: u64 = 0;
   const ADDR_AGGREGATOR_TYPE_ORG: u64 = 1;
   const ADDR_AGGREGATOR_TYPE_ROBOT: u64 = 2;

   // Err enum.
   const ERR_ADDR_ALREADY_EXSIT: u64 = 1000;
   const ERR_ADDR_PARAM_VECTOR_LENGHT_MISMATCH: u64 = 1001;


   struct AddAddrEvent has copy, drop, store {
      addr_type: u64,
      addr: String,
      pubkey: String,
      chains: vector<String>,
      description: String
   }

   struct UpdateAddrSignatureEvent has copy, drop, store {
      addr: String
   }

   struct UpdateAddrEvent has copy, drop, store {
      addr: String,
      chains: vector<String>,
      description: String
   }

   struct DeleteAddrEvent has copy, drop, store {
      addr: String
   }

   struct AddrAggregator has key {
      id: UID,
      key_addr: address,
      addr_infos_map: VecMap<String, AddrInfo>,
      addrs: vector<String>,
      type: u64,
      description: String,
      max_id: u64,
   }

   // Init.
   entry fun init(ctx: &mut TxContext) {
      transfer::share_object(AddrAggregator {
         id: object::new(ctx),
         key_addr: tx_context::sender(ctx),
         addr_infos_map: vec_map::empty(),
         addrs: vector::empty<String>(),
         type:0,
         description:string::utf8(b""),
         max_id: 0,
      });
   }

   // Update addr aggregator type and description.
   public entry fun update_addr_aggregator_type_and_description(aggr: &mut AddrAggregator, type:u64, description: String) {
      aggr.type = type;
      aggr.description = description;
   }

   fun exist_addr_by_map(addr_infos_map: &mut VecMap<String, AddrInfo>, addr: String): bool {
      vec_map::contains(addr_infos_map, &addr)
   }

   // Add addr.
   public entry fun add_addr(aggr: &mut AddrAggregator, addr_type: u64, addr: String,
                             pubkey: String, chains: vector<String>, description: String) {
      // Check addr is 0x begin.
      addr_info::check_addr_prefix(addr);

      // Check addr is already exist.
      assert!(!exist_addr_by_map(&mut aggr.addr_infos_map, addr), ERR_ADDR_ALREADY_EXSIT);

      let id = aggr.max_id + 1;
      let addr_info = addr_info::init_addr_info(id, addr_type, addr, pubkey, &chains, description);
      // table::add(&mut aggr.addr_infos_map, addr, addr_info);
      vec_map::insert(&mut aggr.addr_infos_map, addr, addr_info);
      vector::push_back(&mut aggr.addrs, addr);

      aggr.max_id = aggr.max_id + 1;

      event::emit(AddAddrEvent {
         addr_type,
         addr,
         pubkey,
         chains,
         description,
      })
   }


   // Update addr msg.
   public entry fun update_addr_msg_with_chains_and_description(
      aggr: &mut AddrAggregator, addr: String, chains: vector<String>, description: String) {
      // Check addr 0x prefix.
      addr_info::check_addr_prefix(addr);

      let addr_info = vec_map::get_mut(&mut aggr.addr_infos_map, &addr);

      addr_info::update_addr_msg_with_chains_and_description(addr_info, chains, description);

      event::emit(UpdateAddrEvent {
         addr,
         chains,
         description
      });
   }

   // Update addr info for non verify.
   public entry fun update_addr_for_non_verify(
      aggr: &mut AddrAggregator, addr: String, chains: vector<String>, description: String) {
      // Check addr 0x prefix.
      addr_info::check_addr_prefix(addr);

      let addr_info = vec_map::get_mut(&mut aggr.addr_infos_map, &addr);

      addr_info::update_addr_for_non_verify(addr_info, chains, description);

      event::emit(UpdateAddrEvent {
         addr,
         chains,
         description
      });
   }

   // Update eth addr with signature.
   public entry fun update_eth_addr(aggr: &mut AddrAggregator,
                                    addr: String, signature: String) {
      // Check addr 0x prefix.
      addr_info::check_addr_prefix(addr);

      let addr_info = vec_map::get_mut(&mut aggr.addr_infos_map, &addr);

      addr_eth::update_addr(addr_info, &mut signature);

      event::emit(UpdateAddrSignatureEvent {
         addr
      });
   }

   // Update eth addr with signature.
   public entry fun update_sui_addr(aggr: &mut AddrAggregator,
                                    addr: String, signature: String) {
      // Check addr 0x prefix.
      addr_info::check_addr_prefix(addr);

      let addr_info = vec_map::get_mut(&mut aggr.addr_infos_map, &addr);

      addr_sui::update_addr(addr_info, &mut signature);

      event::emit(UpdateAddrSignatureEvent {
         addr
      });
   }



   // Delete addr.
   public entry fun delete_addr(
      aggr: &mut AddrAggregator,
      addr: String) {
      // Check addr 0x prefix.
      addr_info::check_addr_prefix(addr);

      vec_map::remove(&mut aggr.addr_infos_map, &addr);

      let length = vector::length(&aggr.addrs);
      let i = 0;
      while (i < length) {
         let current_addr = vector::borrow<String>(&aggr.addrs, i);
         if (*current_addr == addr) {
            vector::remove(&mut aggr.addrs, i);

            event::emit(DeleteAddrEvent {
               addr
            });
            break
         };
         i = i + 1;
      };
   }
}