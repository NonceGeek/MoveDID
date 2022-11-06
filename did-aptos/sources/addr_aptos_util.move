module my_addr::addr_aptos_util {
    use std::string::{Self, String};
    use aptos_std::ed25519;
    use my_addr::utils;
    use aptos_framework::timestamp;
    use my_addr::addr_info_util::{Self, AddrInfo};

    public fun update_addr(addr_info: &mut AddrInfo, signature: &mut String, pubkey: &mut String) {
        let addr_info_msg = addr_info_util::get_msg(addr_info);
        // check msg etmpy
        assert!(addr_info_msg != string::utf8(b""), addr_info_util::err_addr_info_etmpty());

        //check addr type
        assert!(addr_info_util::get_addr_type(addr_info) == addr_info_util::addr_type_aptos(), addr_info_util::err_invalid_addr_type());

        let sig_bytes = utils::trim_string_to_vector_u8(signature, 2); // trim 0x
        let pubkey_bytes = utils::trim_string_to_vector_u8(pubkey, 2); // trim 0x

        // verify the signature for the msg
        let pk = ed25519::new_validated_public_key_from_bytes(pubkey_bytes);
        let pk = std::option::extract(&mut pk);
        let pk = ed25519::public_key_into_unvalidated(pk);
        let sig = ed25519::new_signature_from_bytes(sig_bytes);
        assert!(ed25519::signature_verify_strict(&sig, &pk, *string::bytes(&addr_info_msg)), addr_info_util::err_signature_verify_fail());

        // verify the now - created_at <= 2h
        let now = timestamp::now_seconds();
        assert!(now - addr_info_util::get_created_at(addr_info) <= 2 * 60 * 60, addr_info_util::err_timestamp_exceed());

        // update signature, updated_at
        addr_info_util::set_sign_and_updated_at(addr_info, sig_bytes, now)
    }
}