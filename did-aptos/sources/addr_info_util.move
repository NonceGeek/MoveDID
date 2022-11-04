module my_addr::addr_info_util {
    use std::string::{Self, String};
    use std::vector;
    use my_addr::utils;
    use aptos_framework::block;
    use aptos_framework::timestamp;

    //addr type enum
    const ADDR_TYPE_ETH: u64 = 0;  //eth
    const ADDR_TYPE_APTOS: u64 = 1; //aptos

    //err enum
    const ERR_ADDR_INFO_MSG_EMPTY: u64 = 1001;
    const ERR_SIGNATURE_VERIFY_FAIL: u64 = 1002;
    const ERR_TIMESTAMP_EXCEED: u64 = 1003;
    const ERR_INVALID_ADR_TYPE: u64 = 2000;
    const ERR_INVALID_ETH_ADDR: u64 = 2001;
    const ERR_INVALID_APTOS_ADDR: u64 = 2002;

    // addr type pack
    public fun addr_type_eth() : u64 {ADDR_TYPE_ETH}
    public fun addr_type_aptos() : u64 {ADDR_TYPE_APTOS}

    // err pack
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
        id : u64,
        addr_type : u64,
    }

    // get attr
    public fun get_msg(addr_info: &AddrInfo) : String { addr_info.msg }
    public fun get_addr(addr_info: &AddrInfo) : String { addr_info.addr }
    public fun get_addr_type(addr_info: &AddrInfo) : u64 { addr_info.addr_type }
    public fun get_created_at(addr_info: &AddrInfo) : u64 { addr_info.created_at }

    // set attr
    public fun set_sign_and_updated_at(addr_info: &mut AddrInfo, sig : vector<u8>, updated_at : u64) {
        addr_info.signature = sig;
        addr_info.updated_at = updated_at
    }

    // init
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
        assert!(addr_type == ADDR_TYPE_ETH || addr_type == ADDR_TYPE_APTOS, ERR_INVALID_ADR_TYPE);

        if (addr_type == ADDR_TYPE_ETH) {
            assert!(string::length(&addr) == 40, ERR_INVALID_ETH_ADDR)
        } else (
            assert!(string::length(&addr) == 64, ERR_INVALID_APTOS_ADDR)
        )
    }

    public fun equal_addr(addr_info: &AddrInfo, addr : String) : bool {
        let flag = false;
        if (addr_info.addr == addr) {
            flag = true;
        };
        flag
    }
}