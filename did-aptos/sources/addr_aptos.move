module my_addr::addr_aptos {
    use std::string::{Self, String};
    use aptos_std::ed25519;
    use my_addr::utils;
    use aptos_framework::timestamp;
    use my_addr::addr_info::{Self, AddrInfo};

    // Aptos addr type.
    const ADDR_TYPE_APTOS: u64 = 1;

    // Aptos addr length.
    const APTOS_ADDR_LENGTH: u64 = 64;

    // Err enum.
    const ERR_INVALID_APTOS_ADDR: u64 = 2002;

    public fun update_addr(addr_info: &mut AddrInfo, signature: &mut String) {
        let addr_info_msg = addr_info::get_msg(addr_info);
        // Check msg etmpy.
        assert!(addr_info_msg != string::utf8(b""), addr_info::err_addr_info_etmpty());

        // Check addr length.
        assert!(string::length(&addr_info::get_addr(addr_info)) == APTOS_ADDR_LENGTH + 2, ERR_INVALID_APTOS_ADDR);

        // Check addr type.
        assert!(addr_info::get_addr_type(addr_info) == ADDR_TYPE_APTOS, addr_info::err_invalid_addr_type());

        let sig_bytes = utils::trim_string_to_vector_u8(signature, 2); // trim 0x
        let pubkey_bytes = utils::trim_string_to_vector_u8(&addr_info::get_pubkey(addr_info), 2); // trim 0x

        // Verify the signature for the msg.
        let pk = ed25519::new_validated_public_key_from_bytes(pubkey_bytes);
        let pk = std::option::extract(&mut pk);
        let pk = ed25519::public_key_into_unvalidated(pk);
        let sig = ed25519::new_signature_from_bytes(sig_bytes);
        assert!(ed25519::signature_verify_strict(&sig, &pk, *string::bytes(&addr_info_msg)), addr_info::err_signature_verify_fail());

        // Verify the now - created_at <= 2h.
        let now = timestamp::now_seconds();
        assert!(now - addr_info::get_created_at(addr_info) <= 2 * 60 * 60, addr_info::err_timestamp_exceed());

        // Update signature, updated_at.
        addr_info::set_sign_and_updated_at(addr_info, sig_bytes, now)
    }
}

