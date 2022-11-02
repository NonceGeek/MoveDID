module my_addr::eth_sig_verifier {
    use std::vector;
    use sui::ecdsa;
    #[test_only]
    use my_addr::utils;
    // #[test_only]
    // use std::debug;
    #[test_only]
    use std::string;


    fun pubkey_to_address(pk_bytes : vector<u8>) : vector<u8>{
        let data = ecdsa::keccak256(&pk_bytes);
        let result = vector::empty<u8>();
        
        let i = 12;
        while (i < 32) {
            let v  = vector::borrow(&data, i);
            vector::push_back(&mut result, *v);
            i=i+1
        };
        result
    }

   public fun verify_eth_sig(signature: vector<u8>, addr: vector<u8>, message: vector<u8>) : bool{
        let signature_length = vector::length(&signature);
        assert!(signature_length == 65, 3001);

        let recovery_byte = vector::remove(&mut signature, signature_length - 1);
        assert!(recovery_byte == 27 || recovery_byte == 28, 3002);

        let pk = ecdsa::ecrecover(&signature, &message);

        let origin_addr = pubkey_to_address(pk);
        if (origin_addr == addr) {
            return true
        };

        false
   }

    #[test]
    public fun verify_eth_sig_test(){

        let msg = b"1463.nonce_geek";     
        let eth_prefix = b"\x19Ethereum Signed Message:\n";
        let msg_length = vector::length(&msg);
        let sign_origin = vector::empty<u8>();
        
        vector::append(&mut sign_origin, eth_prefix);
        vector::append(&mut sign_origin, utils::u64_to_vec_u8_string(msg_length));
        vector::append(&mut sign_origin, msg);
        let msg_hash = ecdsa::keccak256(&sign_origin);
        
        let str = string::utf8(b"ca305f8b9742f1fd899f7b8aaeea3ed234e4e25fe33998ce539d06d41027dc6902eb251320c796f5ad79cd1340b3bdc2abaeae5beddd2c4b828ed5b2f88544371c");
        let address_bytes = x"14791697260e4c9a71f18484c9f997b308e59325";

        let sig = utils::string_to_vector_u8(&str);
       
        assert!(verify_eth_sig(sig, address_bytes, msg_hash), 101);
    }
}