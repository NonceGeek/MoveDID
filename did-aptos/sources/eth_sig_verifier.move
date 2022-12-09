module my_addr::eth_sig_verifier {
    // use aptos_std::hash;
    use aptos_std::secp256k1;
    use aptos_std::aptos_hash;
    use std::vector;
    #[test_only]
    use my_addr::utils;
    // #[test_only]
    // use std::debug;
    #[test_only]
    use std::string;
    #[test_only]
    use aptos_std::ed25519;


    const ERR_ETH_INVALID_SIGNATURE_LENGTH : u64 = 4000;
    const ERR_ETH_SIGNATURE_FAIL : u64 = 4001;
    const ERR_ETH_INVALID_PUBKEY  : u64 = 4002;

    fun pubkey_to_address(pk_bytes: vector<u8>): vector<u8> {
        let data = aptos_hash::keccak256(pk_bytes);
        let result = vector::empty<u8>();

        let i = 12;
        while (i < 32) {
            let v = vector::borrow(&data, i);
            vector::push_back(&mut result, *v);
            i = i + 1
        };
        result
    }

    public fun verify_eth_sig(signature: vector<u8>, addr: vector<u8>, message: vector<u8>): bool {
        let signature_length = vector::length(&signature);
        assert!(signature_length == 65, ERR_ETH_INVALID_SIGNATURE_LENGTH);

        let recovery_byte = vector::remove(&mut signature, signature_length - 1);
        assert!(recovery_byte == 27 || recovery_byte == 28, ERR_ETH_SIGNATURE_FAIL);

        let recovery_id = 0;
        if (recovery_byte == 28) {
            recovery_id = 1
        };

        let ecdsa_signature = secp256k1::ecdsa_signature_from_bytes(signature);
        let pk = secp256k1::ecdsa_recover(message, recovery_id, &ecdsa_signature);
        assert!(std::option::is_some(&pk), ERR_ETH_INVALID_PUBKEY);

        let public_key = std::option::borrow(&pk);
        let pk_bytes = secp256k1::ecdsa_raw_public_key_to_bytes(public_key);
        let origin_addr = pubkey_to_address(pk_bytes);
        if (origin_addr == addr) {
            return true
        };

        false
    }

    #[test]
    public fun verify_eth_sig_test() {
        // let msg = b"0a.nonce_geek";     
        // let eth_prefix = b"\x19Ethereum Signed Message:\n";
        // let msg_length = vector::length(&msg);
        // let sign_origin = vector::empty<u8>();

        // vector::append(&mut sign_origin, eth_prefix);
        // vector::append(&mut sign_origin, utils::u64_to_vec_u8_string(msg_length));
        // vector::append(&mut sign_origin, msg);
        // let msg_hash = aptos_hash::keccak256(copy sign_origin); 

        // let str = string::utf8(b"6f90301664e3cfda973d4d56067289110a08feb0eca78cc1598a8b992ba9d80f2f77bfe7673c16ec49b81955cf6e1d900aa6fc371bc075a98e8d588fe165c2e61b");
        // let address_bytes = x"14791697260e4c9a71f18484c9f997b308e59325";

        let msg = b"1463.nonce_geek";
        let eth_prefix = b"\x19Ethereum Signed Message:\n";
        let msg_length = vector::length(&msg);
        let sign_origin = vector::empty<u8>();

        vector::append(&mut sign_origin, eth_prefix);
        vector::append(&mut sign_origin, utils::u64_to_vec_u8_string(msg_length));
        vector::append(&mut sign_origin, msg);
        let msg_hash = aptos_hash::keccak256(copy sign_origin);

        let str = string::utf8(b"ca305f8b9742f1fd899f7b8aaeea3ed234e4e25fe33998ce539d06d41027dc6902eb251320c796f5ad79cd1340b3bdc2abaeae5beddd2c4b828ed5b2f88544371c");
        let address_bytes = x"14791697260e4c9a71f18484c9f997b308e59325";

        let sig = utils::string_to_vector_u8(&str);

        assert!(verify_eth_sig(sig, address_bytes, msg_hash), 101);
    }

    #[test]
    public fun ed25519_sign_verify_test() {
        let msg = b"0a.nonce_geek";
        let sig_bytes = x"309d03620a349b430c62f394897f33b7abe24e9ddb02a643c6cdc3d3af6237618c04c018bbdbfb0e21010658f5373a36b71eba4ab88005e0099999719da58c0b";
        let pubkey_bytes = x"de19e5d1880cac87d57484ce9ed2e84cf0f9599f12e7cc3a52e4e7657a763f2c";

        let pk = ed25519::new_validated_public_key_from_bytes(pubkey_bytes);
        let pk = std::option::extract(&mut pk);
        let pk = ed25519::public_key_into_unvalidated(pk);
        let sig = ed25519::new_signature_from_bytes(sig_bytes);

        assert!(ed25519::signature_verify_strict(&sig, &pk, msg), 102);
    }
}

