module my_addr::eth_sig_verifier {
    use aptos_std::hash;
    use aptos_std::secp256k1;
    use aptos_std::aptos_hash;
    use std::vector;

    fun pubkey_to_address(pk_bytes : vector<u8>) : vector<u8>{

        if (vector::length(&pk_bytes) != 33) {
            abort 1003
        };
       
    //   let data[]
        vector::remove(&mut pk_bytes, 0); //
        let data = aptos_hash::keccak256(pk_bytes);
        let result = vector::empty<u8>();
        
        let i = 12;
        while (i < 32) {
            let v  = vector::borrow(&data, i);
            vector::push_back(&mut result, *v);
        };
      
        result
    }

   public fun verify_eth_sig(signature: vector<u8>, addr: vector<u8>, message: vector<u8>) : bool{
        let ecdsa_signature = secp256k1::ecdsa_signature_from_bytes(signature);
        let pk = secp256k1::ecdsa_recover(hash::sha2_256(message), 0, &ecdsa_signature);
        assert!(std::option::is_some(&pk), 1);

        let public_key = std::option::borrow(&pk);
        // assert!(std::option::extract(&mut pk).bytes == x"4646ae5047316b4230d0086c8acec687f00b1cd9d1dc634f6cb358ac0a9a8ffffe77b4dd0a4bfb95851f3b7355c781dd60f8418fc8a65d14907aff47c903a559", 1);
        let pk_bytes = secp256k1::ecdsa_raw_public_key_to_bytes(public_key);
        let origin_addr = pubkey_to_address(pk_bytes);
        if (origin_addr == addr) {
            return true
        };

        false
   }
}