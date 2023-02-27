module my_addr::addr_aptos {
    use std::string::{Self, String};
    use aptos_std::ed25519;
    use my_addr::utils;
    use aptos_framework::timestamp;
    use my_addr::addr_info::{Self, AddrInfo};

    friend my_addr::addr_aggregator;

    // Aptos addr type.
    const ADDR_TYPE_APTOS: u64 = 1;

    // Aptos addr length.
    const APTOS_ADDR_LENGTH: u64 = 64;

    // Err enum.
    const ERR_INVALID_APTOS_ADDR: u64 = 2002;
    const ERR_INVALID_APTOS_MSG: u64 = 2003;


    public(friend) fun update_addr(addr_info: &mut AddrInfo, signature: &mut String, msg: String) {
        let addr_info_msg = addr_info::get_msg(addr_info);
        // Check msg etmpy.
        assert!(addr_info_msg != string::utf8(b""), addr_info::err_addr_info_empty());

        // Check addr length.
        assert!(string::length(&addr_info::get_addr(addr_info)) == APTOS_ADDR_LENGTH + 2, ERR_INVALID_APTOS_ADDR);

        // Check addr type.
        assert!(addr_info::get_addr_type(addr_info) == ADDR_TYPE_APTOS, addr_info::err_invalid_addr_type());

        // Check addr_info.msg is the msg's subset 
        assert!(string::index_of(&msg, &addr_info::get_msg(addr_info)) != string::length(&msg), ERR_INVALID_APTOS_MSG);


        let sig_bytes = utils::trim_string_to_vector_u8(signature, 2); // trim 0x
        let pubkey_bytes = utils::trim_string_to_vector_u8(&addr_info::get_pubkey(addr_info), 2); // trim 0x

        // Verify the signature for the msg.
        // let pk = ed25519::new_validated_public_key_from_bytes(pubkey_bytes);
        let pk = std::option::extract(&mut ed25519::new_validated_public_key_from_bytes(pubkey_bytes));
        let pk = ed25519::public_key_into_unvalidated(pk);
        let sig = ed25519::new_signature_from_bytes(sig_bytes);
        assert!(ed25519::signature_verify_strict(&sig, &pk, *string::bytes(&msg)), addr_info::err_signature_verify_fail());

        // Verify the now - created_at <= 2h.
        let now = timestamp::now_seconds();
        assert!(now - addr_info::get_created_at(addr_info) <= 2 * 60 * 60, addr_info::err_timestamp_exceed());

        // Update signature, updated_at.
        addr_info::set_sign_and_updated_at(addr_info, sig_bytes, now)
    }


    #[test]
    fun test_aptos_sign_verify() {
        let pk_bytes = x"09b3d965cd69f49ad7fa68dd7e6669e8fe0c0b69de3238c393961e8c2e1511ac";
        let public_key = std::option::extract(&mut ed25519::new_validated_public_key_from_bytes(pk_bytes));
        let pk = ed25519::public_key_into_unvalidated(public_key);

        let sig = ed25519::new_signature_from_bytes(x"6bf16f0a2b0dbb4d56fff501ae8d57e20707ecf9bc2eac9f7ce859be30e536ec4805fb99581d6150c789a8c94c47ef467c869fd9056d8b8e559410e8cd797e04");
        // let msg = b"APTOS\nmessage: 4139eaf9a8f1ee32431e6d33876a8a4243be4b0d7fbf76f0cb0315ec92452369\nnonce: random_string_change";
        // let sub_msg = b"helloworld";
        let msg = b"APTOS\nmessage: 62485469.1.4139eaf9a8f1ee32431e6d33876a8a4243be4b0d7fbf76f0cb0315ec92452369.2.nonce_geek\nnonce: random_string_change";

        // assert!(string::index_of(&string::utf8(msg), &string::utf8(sub_msg)) != string::length(&string::utf8(msg)), ERR_INVALID_APTOS_MSG);
        
        assert!(ed25519::signature_verify_strict(&sig, &pk, msg), 5005);
    }
}

