module my_addr::addr_eth {
    use std::string::{Self, String};
    use std::vector;
    use my_addr::utils;
    use aptos_framework::timestamp;
    use my_addr::eth_sig_verifier;
    use aptos_std::aptos_hash;
    use my_addr::addr_info::{Self, AddrInfo};

    // Eth addr type.
    const ADDR_TYPE_ETH: u64 = 0;

    // Eth addr length.
    const ETH_ADDR_LEGNTH: u64 = 40;

    // Err enum.
    const ERR_INVALID_ETH_ADDR: u64 = 2001;


    public fun update_addr(addr_info: &mut AddrInfo, signature: &mut String) {
        let addr_info_msg = addr_info::get_msg(addr_info);
        // Check msg etmpy.
        assert!(addr_info_msg != string::utf8(b""), addr_info::err_addr_info_etmpty());

        // Check addr length.
        assert!(string::length(&addr_info::get_addr(addr_info)) == ETH_ADDR_LEGNTH + 2, ERR_INVALID_ETH_ADDR);

        // Check addr type.
        assert!(addr_info::get_addr_type(addr_info) == ADDR_TYPE_ETH, addr_info::err_invalid_addr_type());

        let sig_bytes = utils::trim_string_to_vector_u8(signature, 2); //trim 0x
        let addr_byte = utils::trim_string_to_vector_u8(&addr_info::get_addr(addr_info), 2); //trim 0x

        // Verify the signature for the msg.
        let eth_prefix = b"\x19Ethereum Signed Message:\n";
        let msg_length = string::length(&addr_info_msg);
        let sign_origin = vector::empty<u8>();
        vector::append(&mut sign_origin, eth_prefix);
        vector::append(&mut sign_origin, utils::u64_to_vec_u8_string(msg_length));
        vector::append(&mut sign_origin, *string::bytes(&addr_info_msg));
        let msg_hash = aptos_hash::keccak256(sign_origin); //kecacak256 hash
        assert!(eth_sig_verifier::verify_eth_sig(sig_bytes, addr_byte, msg_hash), addr_info::err_signature_verify_fail());

        // Verify the now - created_at <= 2h.
        let now = timestamp::now_seconds();
        assert!(now - addr_info::get_created_at(addr_info) <= 2 * 60 * 60, addr_info::err_timestamp_exceed());

        // Update signature, updated_at.
        addr_info::set_sign_and_updated_at(addr_info, sig_bytes, now)
    }
}

