module my_addr::addr_bitcoin_verificated_offline {
    use std::signer;
    use std::string::{Self, String};
    use my_addr::utils;
    use aptos_framework::timestamp;
    use my_addr::addr_info::{Self, AddrInfo};

    friend my_addr::addr_aggregator;

    // Bitcoin addr type.
    const ADDR_TYPE_BTC: u64 = 2;

     // Err enum.
    const ERR_DEPRECATED_ALREADY: u64 = 2001;
    
    //:!:>resource
    struct DeprecatedCapability has key, store, copy, drop {
        deprecated: bool
    }
    //<:!:resource

    // only signer call this is available.
    public entry fun init(acct: &signer) {
        let de = DeprecatedCapability{
            deprecated: false
        };
        move_to<DeprecatedCapability>(acct, de);
    }

   public entry fun enable(acct: &signer) acquires DeprecatedCapability{
        let send_addr = signer::address_of(acct);
        let de = borrow_global_mut<DeprecatedCapability>(send_addr);
        de.deprecated = false
    }
    public entry fun depre(acct: &signer) acquires DeprecatedCapability{
        let send_addr = signer::address_of(acct);
        let de = borrow_global_mut<DeprecatedCapability>(send_addr);
        de.deprecated = true
    }

    public(friend) fun update_addr(addr_info: &mut AddrInfo, signature: &mut String) acquires DeprecatedCapability{
        // only avaiable if @my_addr's DeprecatedCapability.deprecated == false
        let de_cap = borrow_global<DeprecatedCapability>(@my_addr);
        // check deprecated
        assert!(de_cap.deprecated == false, ERR_DEPRECATED_ALREADY);
        let addr_info_msg = addr_info::get_msg(addr_info);
        // Check msg etmpy.
        assert!(addr_info_msg != string::utf8(b""), addr_info::err_addr_info_empty());
        // Check addr type.
        assert!(addr_info::get_addr_type(addr_info) == ADDR_TYPE_BTC, addr_info::err_invalid_addr_type());

        let sig_bytes = utils::trim_string_to_vector_u8(signature, 2); //trim 0x

        // Verify the now - created_at <= 2h.
        let now = timestamp::now_seconds();
        assert!(now - addr_info::get_created_at(addr_info) <= 2 * 60 * 60, addr_info::err_timestamp_exceed());

        // Update signature, updated_at.
        addr_info::set_sign_and_updated_at(addr_info, sig_bytes, now)
    }

    #[view]
    public fun get_deprecated_status(owner: address) :bool acquires DeprecatedCapability {
        borrow_global<DeprecatedCapability>(owner).deprecated
    }

}