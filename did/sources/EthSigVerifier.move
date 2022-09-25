module MyAddr::EthSigVerifierV5 {
   use StarcoinFramework::Signature;
   use StarcoinFramework::EVMAddress::{Self, EVMAddress};
   use StarcoinFramework::Option::{Self, Option};
   #[test_only]
   use StarcoinFramework::Debug;
   #[test_only]
   use StarcoinFramework::Hash;


   public fun verify_eth_sig(signature: vector<u8>, addr: vector<u8>, msg_hash: vector<u8>) : bool{
      // 0x01) recover addr from signature
      // --- ecrecover(hash: vector<u8>, signature: vector<u8>)      // cond2 = (addr1 == addr2)
      // 0x02 assert(addr == ecrecover)

      let receover_address_opt:Option<EVMAddress>  = Signature::ecrecover(msg_hash, signature); 
      let expect_address =  EVMAddress::new(addr);
      &Option::destroy_some<EVMAddress>(receover_address_opt) == &expect_address
   }
   
   #[test]
   public fun verify_eth_sig_test(){
      // let signature = x"90a938f7457df6e8f741264c32697fc52f9a8f867c52dd70713d9d2d472f2e415d9c94148991bbe1f4a1818d1dff09165782749c877f5cf1eff4ef126e55714d1c";
      // let msg_hash = x"b453bd4e271eed985cbab8231da609c4ce0a9cf1f763b6c1594e76315510e0f1";
      // let address_bytes = x"29c76e6ad8f28bb1004902578fb108c507be341b";

      let v = x"04";
      let msg_hash = Hash::keccak_256(v);
      Debug::print(&msg_hash);
      let signature = x"e02fcfd6e2f9d7a1aa6b12cef95bb6e5013b14dc584e080034b09f902fd87d8b4e46d83462ae957f8db86f50aac61dde24261befd1c11780adc8e0d5ee4e34971c";
      let address_bytes = x"14791697260e4c9a71f18484c9f997b308e59325";
      
      assert!(verify_eth_sig(signature, address_bytes, msg_hash), 101);
   }
}