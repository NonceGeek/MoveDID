module my_addr::addr_eth_util {
    use std::string::{Self, String};
    use std::vector;
    use my_addr::utils;
    use aptos_framework::timestamp;
    use my_addr::eth_sig_verifier;
    use aptos_std::aptos_hash;
    use my_addr::addr_info_util::{Self, AddrInfo};

    public fun update_addr(addr_info: &mut AddrInfo, signature: &mut String) {
        let addr_info_msg = addr_info_util::get_msg(addr_info);
        // check msg etmpy
        assert!(addr_info_msg != string::utf8(b""), addr_info_util::err_addr_info_etmpty());

        //check addr type
        assert!(addr_info_util::get_addr_type(addr_info) == addr_info_util::addr_type_eth(), addr_info_util::err_invalid_addr_type());

        let sig_bytes = utils::trim_string_to_vector_u8(signature, 2); //trim 0x
        let addr_byte = utils::trim_string_to_vector_u8(&addr_info_util::get_addr(addr_info), 2); //trim 0x

        // verify the signature for the msg
        let eth_prefix = b"\x19Ethereum Signed Message:\n";
        let msg_length = string::length(&addr_info_msg);
        let sign_origin = vector::empty<u8>();
        vector::append(&mut sign_origin, eth_prefix);
        vector::append(&mut sign_origin, utils::u64_to_vec_u8_string(msg_length));
        vector::append(&mut sign_origin, *string::bytes(&addr_info_msg));
        let msg_hash = aptos_hash::keccak256(sign_origin); //kecacak256 hash
        assert!(eth_sig_verifier::verify_eth_sig(sig_bytes, addr_byte, msg_hash), addr_info_util::err_signature_verify_fail());

        // verify the now - created_at <= 2h
        let now = timestamp::now_seconds();
        assert!(now - addr_info_util::get_created_at(addr_info) <= 2 * 60 * 60, addr_info_util::err_timestamp_exceed());

        // update signature, updated_at
        addr_info_util::set_sign_and_updated_at(addr_info, sig_bytes, now)
    }
}