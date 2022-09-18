// module my_addr::eth_sig_verifier_v5 {
//    // use StarcoinFramework::Signature;
//    // use StarcoinFramework::EVMAddress::{Self, EVMAddress};
//    // use StarcoinFramework::Option::{Self, Option};
//    use 0x01::secp256k1;

//    public fun pubkey_to_address(pk : &secp256k1::ECDSARawPublicKey) : vector<u8>{
//       let pk = secp256k1::ecdsa_recover(message, 0, &secp256k1::ECDSASignature{ bytes: message});

//       let data = aptos_hash::keccak256(pk.ecdsa_raw_public_key_to_bytes());
//       let data[]

//    }

//    public fun verify_eth_sig(signature: vector<u8>, addr: vector<u8>, message: vector<u8>) : bool{
//       // 0x01) recover addr from signature
//       // --- ecrecover(hash: vector<u8>, signature: vector<u8>)      // cond2 = (addr1 == addr2)
//       // 0x02 assert(addr == ecrecover)

     


//           let pk = ecdsa_recover(
//             hash::sha2_256(b"test aptos secp256k1"),
//             0,
//             &ECDSASignature { bytes: x"f7ad936da03f948c14c542020e3c5f4e02aaacd1f20427c11aa6e2fbf8776477646bba0e1a37f9e7c777c423a1d2849baafd7ff6a9930814a43c3f80d59db56f" },
//         );
//         assert!(std::option::is_some(&pk), 1);
//         assert!(std::option::extract(&mut pk).bytes == x"4646ae5047316b4230d0086c8acec687f00b1cd9d1dc634f6cb358ac0a9a8ffffe77b4dd0a4bfb95851f3b7355c781dd60f8418fc8a65d14907aff47c903a559", 1);


//       let receover_address_opt:Option<EVMAddress>  = Signature::ecrecover(message, signature);
//       let expect_address =  EVMAddress::new(addr);
//       &Option::destroy_some<EVMAddress>(receover_address_opt) == &expect_address
//    }
   
//    #[test]
//    public fun verify_eth_sig_test(){
//       let signature = x"90a938f7457df6e8f741264c32697fc52f9a8f867c52dd70713d9d2d472f2e415d9c94148991bbe1f4a1818d1dff09165782749c877f5cf1eff4ef126e55714d1c";
//       let msg_hash = x"b453bd4e271eed985cbab8231da609c4ce0a9cf1f763b6c1594e76315510e0f1";
//       let address_bytes = x"29c76e6ad8f28bb1004902578fb108c507be341b";
//       assert!(verify_eth_sig(signature, address_bytes, msg_hash), 101);
//    }
// }