module my_addr::addr_info_util {
    use std::string::{Self, String};
    use std::vector;
    use my_addr::utils;
    use aptos_framework::block;
    use aptos_framework::timestamp;
    use my_addr::eth_sig_verifier;
    use aptos_std::aptos_hash;
    use aptos_std::ed25519;

    //addr type enum
    const ADDR_TYPE_SECP256K1: u64 = 1;  //secp256k1
    const ADDR_TYPE_ED25519: u64 = 2; //ed25519

    //err enum
    const ERR_ADDR_INFO_MSG_EMPTY: u64 = 1001;
    const ERR_SIGNATURE_VERIFY_FAIL: u64 = 1002;
    const ERR_TIMESTAMP_EXCEED: u64 = 1003;

    const ERR_INVALID_ADR_TYPE: u64 = 2000;
    const ERR_INVALID_SECP256K1_ADDR: u64 = 2001;  //secp256k1
    const ERR_INVALID_ED25519_ADDR: u64 = 2002;   //ed25519

    struct AddrInfo has store, copy, drop {
        addr: String,
        description: String,
        chains: vector<String>,
        msg: String,
        signature: vector<u8>,
        created_at: u64,
        updated_at: u64,
        id : u64,
        addr_type : u64,
    }

    public fun init_addr_info(id : u64,
         addr_type: u64,
         addr: String,
         chains: &vector<String>,
         description: String) : AddrInfo{
        // gen msg
        let height = block::get_current_block_height();
        let msg = utils::u64_to_vec_u8_string(height);
        let msg_suffix = b".nonce_geek";
        vector::append(&mut msg, msg_suffix);

        let now = timestamp::now_seconds();

        AddrInfo{
            addr,
            chains: *chains,
            description,
            signature: b"",
            msg: string::utf8(msg),
            created_at: now,
            updated_at: 0,
            id,
            addr_type,
        }
    }

    public fun check_addr_type(addr_type: u64, addr: String) {
        assert!(addr_type == ADDR_TYPE_SECP256K1 || addr_type == ADDR_TYPE_ED25519, ERR_INVALID_ADR_TYPE);

        if (addr_type == ADDR_TYPE_SECP256K1) {
            assert!(string::length(&addr) == 40, ERR_INVALID_SECP256K1_ADDR)
        } else (
            assert!(string::length(&addr) == 64, ERR_INVALID_ED25519_ADDR)
        )
    }

    public fun equal_addr(addr_info: &AddrInfo, addr : String) : bool {
        let flag = false;
        if (addr_info.addr == addr) {
            flag = true;
        };
        flag
    }

    public fun  get_msg(addr_info: &AddrInfo) : String {
        addr_info.msg
    }

    public fun update_addr_info_with_sig(addr_info: &mut AddrInfo, signature : &mut String) {
        assert!(addr_info.msg != string::utf8(b""), ERR_ADDR_INFO_MSG_EMPTY);

        let sig_bytes = utils::string_to_vector_u8(signature);
        let addr_byte = utils::string_to_vector_u8(&addr_info.addr);
        assert!(addr_info.addr_type == ADDR_TYPE_SECP256K1, ERR_INVALID_ADR_TYPE);

        // verify the signature for the msg
        let eth_prefix = b"\x19Ethereum Signed Message:\n";
        let msg_length = string::length(&addr_info.msg);
        let sign_origin = vector::empty<u8>();
        vector::append(&mut sign_origin, eth_prefix);
        vector::append(&mut sign_origin, utils::u64_to_vec_u8_string(msg_length));
        vector::append(&mut sign_origin, *string::bytes(&addr_info.msg));
        let msg_hash = aptos_hash::keccak256(sign_origin); //kecacak256 hash
        assert!(eth_sig_verifier::verify_eth_sig(sig_bytes, addr_byte, msg_hash), ERR_SIGNATURE_VERIFY_FAIL);

        // verify the now - created_at <= 2h
        let now = timestamp::now_seconds();
        assert!(now - addr_info.created_at <= 2*60*60, ERR_TIMESTAMP_EXCEED);

        // update signature, updated_at
        addr_info.signature = sig_bytes;
        addr_info.updated_at = now;
    }

    public fun update_addr_info_with_sig_and_pubkey(addr_info: &mut AddrInfo, signature : &mut String, pubkey : &mut String) {
        assert!(addr_info.msg != string::utf8(b""), ERR_ADDR_INFO_MSG_EMPTY);

        let sig_bytes = utils::string_to_vector_u8(signature);
        let pubkey_bytes = utils::string_to_vector_u8(pubkey);

        assert!(addr_info.addr_type == ADDR_TYPE_ED25519, ERR_INVALID_ADR_TYPE);

        // verify the signature for the msg
        let pk = ed25519::new_validated_public_key_from_bytes(pubkey_bytes);
        let pk = std::option::extract(&mut pk);
        let pk = ed25519::public_key_into_unvalidated(pk);
        let sig = ed25519::new_signature_from_bytes(sig_bytes);
        assert!(ed25519::signature_verify_strict(&sig, &pk, *string::bytes(&addr_info.msg)), ERR_SIGNATURE_VERIFY_FAIL);

        // verify the now - created_at <= 2h
        let now = timestamp::now_seconds();
        assert!(now - addr_info.created_at <= 2*60*60, ERR_TIMESTAMP_EXCEED);

        // update signature, updated_at
        addr_info.signature = sig_bytes;
        addr_info.updated_at = now;
    }
}