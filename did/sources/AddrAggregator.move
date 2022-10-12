module MyAddr::AddrAggregator {
   use StarcoinFramework::Vector;
   use StarcoinFramework::Signer;
   use StarcoinFramework::Timestamp;
   use StarcoinFramework::Block;
   use StarcoinFramework::Hash;
   use MyAddr::Utils;
   use MyAddr::EthSigVerifierV5;

   //err enum
   const ERR_ADDR_INFO_MSG_EMPTY: u64 = 1001;
   const ERR_SIGNATURE_VERIFY_FAIL: u64 = 1002;
   const ERR_TIMESTAMP_EXCEED: u64 = 1003;
   
   struct AddrInfo has store, copy, drop {
      addr: vector<u8>,
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

   public (script) fun create_addr_aggregator(sender: signer){
      let addr_aggr =  AddrAggregator{
         key_addr: Signer::address_of(&sender),
         addr_infos: Vector::empty<AddrInfo>(),
         max_id : 0
      };
      move_to<AddrAggregator>(&sender, addr_aggr);
   }

   // add addr
   public (script) fun add_addr(sender: signer, 
      addr: vector<u8>, 
      chain_name: vector<u8>,
      description: vector<u8>) acquires AddrAggregator {
      let addr_aggr = borrow_global_mut<AddrAggregator>(Signer::address_of(&sender));   
      let id = addr_aggr.max_id + 1;
      
      let height = Block::get_current_block_number();
      let msg = Utils::u64_to_vec_u8_string(height);
      let msg_suffix = b".nonce_geek";
      Vector::append(&mut msg, msg_suffix);

      let now = Timestamp::now_seconds();
         
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
      Vector::push_back(&mut addr_aggr.addr_infos, addr_info);
      addr_aggr.max_id = addr_aggr.max_id + 1;
   }

   // get addr  msg 
   public fun get_msg(contract: address, addr: vector<u8>) :vector<u8> acquires AddrAggregator {
      let addr_aggr = borrow_global_mut<AddrAggregator>(contract);
      let length = Vector::length(&mut addr_aggr.addr_infos);
      let i = 0;
    
      while (i < length) {
         let addr_info = Vector::borrow<AddrInfo>(&mut addr_aggr.addr_infos, i);
         if (*&addr_info.addr == copy addr) {
            return *&addr_info.msg
         };
         i = i + 1;
      };

      return x""
   }

   // public fun update addr with sig
   public (script) fun update_addr_with_sig(sender: signer, 
      addr: vector<u8>, signature : vector<u8>) acquires AddrAggregator {
      let addr_aggr = borrow_global_mut<AddrAggregator>(Signer::address_of(&sender));

      let length = Vector::length(&mut addr_aggr.addr_infos);
      let i = 0;
      while (i < length) {
         let addr_info = Vector::borrow_mut<AddrInfo>(&mut addr_aggr.addr_infos, i);
         if (*&addr_info.addr == copy addr) {
            assert!(*&addr_info.msg != x"", ERR_ADDR_INFO_MSG_EMPTY);

            // verify the signature for the msg 
            let eth_prefix = b"\x19Ethereum Signed Message:\n";
            let msg_length = Vector::length(&addr_info.msg);
            let sign_origin = Vector::empty<u8>();
            Vector::append(&mut sign_origin, eth_prefix);
            Vector::append(&mut sign_origin, Utils::u64_to_vec_u8_string(msg_length));
            Vector::append(&mut sign_origin, *&addr_info.msg);
            let msg_hash = Hash::keccak_256(sign_origin); //kecacak256 hash 
            assert!(EthSigVerifierV5::verify_eth_sig(copy signature, addr, msg_hash), ERR_SIGNATURE_VERIFY_FAIL);
            
            // verify the now - created_at <= 2h 
            let now = Timestamp::now_seconds();
            assert!(now - addr_info.created_at <= 2*60*60, ERR_TIMESTAMP_EXCEED);

            // update signature, updated_at 
            addr_info.signature = signature;
            addr_info.updated_at = now;
            break
         };
         i = i + 1;
      };
   }

   // public fun delete addr
   public (script) fun delete_addr(
      sender: signer,  
      addr: vector<u8>) acquires AddrAggregator{
      let addr_aggr = borrow_global_mut<AddrAggregator>(Signer::address_of(&sender));
      let length = Vector::length(&mut addr_aggr.addr_infos);
      let i = 0;
      while (i < length) {
         let addr_info = Vector::borrow(&mut addr_aggr.addr_infos, i);
         if (*&addr_info.addr == copy addr) {
            Vector::remove(&mut addr_aggr.addr_infos, i);
            break
         };
         i = i + 1;
      }
   }
}