module my_addr::addr_info {
    use std::string::{Self, String};
    use std::vector;
    use my_addr::utils;
    use aptos_framework::block;
    use aptos_framework::timestamp;
    // use std::debug;

    // Err enum.
    const ERR_ADDR_INFO_MSG_EMPTY: u64 = 1001;
    const ERR_SIGNATURE_VERIFY_FAIL: u64 = 1002;
    const ERR_TIMESTAMP_EXCEED: u64 = 1003;
    const ERR_ADDR_INVALID_PREFIX: u64 = 1004;
    const ERR_INVALID_ADR_TYPE: u64 = 1005;
    const ERR_ADDR_NO_FIRST_VERIFY: u64 = 1006;
    const ERR_ADDR_MUST_NO_VERIFY: u64 = 1007;

    // Err pack.
    public fun err_addr_info_etmpty(): u64 { ERR_ADDR_INFO_MSG_EMPTY }

    public fun err_invalid_addr_type(): u64 { ERR_INVALID_ADR_TYPE }

    public fun err_signature_verify_fail(): u64 { ERR_SIGNATURE_VERIFY_FAIL }

    public fun err_timestamp_exceed(): u64 { ERR_TIMESTAMP_EXCEED }

    struct AddrInfo has store, copy, drop {
        addr: String,
        description: String,
        chains: vector<String>,
        msg: String,
        signature: vector<u8>,
        created_at: u64,
        updated_at: u64,
        id: u64,
        addr_type: u64,
        expired_at: u64,
        pubkey: String,
    }

    // Get attr.
    public fun get_msg(addr_info: &AddrInfo): String { addr_info.msg }

    public fun get_addr(addr_info: &AddrInfo): String { addr_info.addr }

    public fun get_addr_type(addr_info: &AddrInfo): u64 { addr_info.addr_type }

    public fun get_created_at(addr_info: &AddrInfo): u64 { addr_info.created_at }

    public fun get_updated_at(addr_info: &AddrInfo): u64 { addr_info.updated_at }

    public fun get_pubkey(addr_info: &AddrInfo): String { addr_info.pubkey }

    public fun get_chains(addr_info: &AddrInfo): vector<String> { addr_info.chains }

    public fun get_description(addr_info: &AddrInfo): String { addr_info.description }


    // Init.
    public fun init_addr_info(
        send_addr : address,
        id: u64,
        addr_type: u64,
        addr: String,
        pubkey: String,
        chains: &vector<String>,
        description: String,
        expire_second : u64): AddrInfo {
        // Gen msg; format=height.chain_id.send_addr.id.nonce_geek .
        let height = block::get_current_block_height();
        let msg = utils::u64_to_vec_u8_string(height);

        let chain_id_address = @chain_id;
        let chain_id = utils::address_to_u64(chain_id_address);
        let chain_id_vec = utils::u64_to_vec_u8_string(chain_id);
        vector::append(&mut msg, b".");
        vector::append(&mut msg, chain_id_vec);

        let send_addr_vec = utils::address_to_ascii_u8_vec(send_addr);
        vector::append(&mut msg, b".");
        vector::append(&mut msg, send_addr_vec);

        let id_vec = utils::u64_to_vec_u8_string(id);
        vector::append(&mut msg, b".");
        vector::append(&mut msg, id_vec);

        let msg_suffix = b".nonce_geek";
        vector::append(&mut msg, msg_suffix);

        let now = timestamp::now_seconds();
        let expired_at = now + expire_second; // udpate expired_at

        AddrInfo {
            addr,
            chains: *chains,
            description,
            signature: b"",
            msg: string::utf8(msg),
            created_at: now,
            updated_at: 0,
            id,
            addr_type,
            expired_at,
            pubkey,
        }
    }

    #[test_only]
    public fun set_addr_info_init_for_testing(
        addr_type: u64,
        addr: String,
        pubkey: String,
        chains: vector<String>,
        description: String) : AddrInfo{
        AddrInfo{
            addr,
            chains,
            description,
            signature: b"",
            msg: string::utf8(b""),
            created_at: 0,
            updated_at: 0,
            id:0,
            addr_type,
            expired_at:0,
            pubkey,
        }
    }

    // Check addr is 0x prefix.
    public fun check_addr_prefix(addr: String) {
        assert!(string::sub_string(&addr, 0, 2) == string::utf8(b"0x"), ERR_ADDR_INVALID_PREFIX);
    }

    public fun equal_addr(addr_info: &AddrInfo, addr: String): bool {
        let flag = false;
        if (addr_info.addr == addr) {
            flag = true;
        };
        flag
    }


    // Set attr.
    public fun set_sign_and_updated_at(addr_info: &mut AddrInfo, sig: vector<u8>, updated_at: u64) {
        addr_info.signature = sig;
        addr_info.updated_at = updated_at;
    }

    // Update.
    public fun update_addr_info_with_chains_and_description(addr_info: &mut AddrInfo, chains: vector<String>, description: String) {
        // Check addr_info's signature has verified.
        assert!(vector::length(&addr_info.signature) != 0, ERR_ADDR_NO_FIRST_VERIFY);

        // Msg format : block_height.chain_id.nonce_geek.chains.description.
        let height = block::get_current_block_height();
        let msg = utils::u64_to_vec_u8_string(height);

        let chain_id_address = @chain_id;
        let chain_id = utils::address_to_u64(chain_id_address);
        let chain_id_vec = utils::u64_to_vec_u8_string(chain_id);
        vector::append(&mut msg, b".");
        vector::append(&mut msg, chain_id_vec);

        let msg_suffix = b".nonce_geek";
        vector::append(&mut msg, msg_suffix);
        vector::append(&mut msg, b".");
        // Add chains.
        let chains_length = vector::length(&chains);
        let i = 0;
        while (i < chains_length) {
            let chain = vector::borrow<String>(&mut chains, i);
            vector::append(&mut msg, *string::bytes(chain));
            if (i != chains_length - 1) {
                vector::append(&mut msg, b"_");
            };
            i = i + 1
        };

        vector::append(&mut msg, b".");
        // Add description.
        vector::append(&mut msg, *string::bytes(&description));

        addr_info.msg = string::utf8(msg);
        addr_info.chains = chains;
        addr_info.description = description;
        addr_info.updated_at = timestamp::now_seconds();
    }

    public fun update_addr_info_for_non_verification(addr_info: &mut AddrInfo, chains: vector<String>, description: String) {
        // Check addr_info's signature must no verified.
        assert!(vector::length(&addr_info.signature) == 0, ERR_ADDR_MUST_NO_VERIFY);

        addr_info.chains = chains;
        addr_info.description = description;
        addr_info.updated_at = timestamp::now_seconds();
    }
}