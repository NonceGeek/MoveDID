module my_addr::addr_aggregator {
    use std::signer;
    use std::vector;
    use std::string::{Self, String};
    use my_addr::addr_info::{Self, AddrInfo};
    use my_addr::addr_eth;
    use my_addr::addr_aptos;

    // define addr aggregator type
    const ADDR_AGGREGATOR_TYPE_HUMAN: u64 = 0;
    const ADDR_AGGREGATOR_TYPE_ORG: u64 = 1;
    const ADDR_AGGREGATOR_TYPE_ROBOT: u64 = 2;

    const ERR_ADDR_ALREADY_EXSIT: u64 = 100;


    struct AddrAggregator has key {
        key_addr: address,
        addr_infos: vector<AddrInfo>,
        type: u64,
        description: String,
        max_id: u64,
    }

    // init
    public entry fun create_addr_aggregator(acct: &signer, type: u64, description: String) {
        let addr_aggr = AddrAggregator {
            key_addr: signer::address_of(acct),
            addr_infos: vector::empty<AddrInfo>(),
            type,
            description,
            max_id: 0
        };
        move_to<AddrAggregator>(acct, addr_aggr);
    }

    // add addr
    public entry fun add_addr(acct: &signer,
                              addr_type: u64,
                              addr: String,
                              chains: vector<String>,
                              description: String) acquires AddrAggregator {

        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));

        //check addr is already exist
        assert!(!exist_addr(&mut addr_aggr.addr_infos, addr), ERR_ADDR_ALREADY_EXSIT);

        let id = addr_aggr.max_id + 1;
        let addr_info = addr_info::init_addr_info(id, addr_type, addr, &chains, description);
        vector::push_back(&mut addr_aggr.addr_infos, addr_info);
        addr_aggr.max_id = addr_aggr.max_id + 1;
    }

    fun exist_addr(addr_infos: &mut vector<AddrInfo>, addr: String): bool {
        let flag = false;
        let length = vector::length(addr_infos);
        let i = 0;

        while (i < length) {
            let addr_info = vector::borrow_mut<AddrInfo>(addr_infos, i);
            if (addr_info::equal_addr(addr_info, addr)) {
                flag = true;
                break
            };
            i = i + 1;
        };
        flag
    }

    public fun get_msg(contract: address, addr: String): String acquires AddrAggregator {
        //check addr 0x prefix
        addr_info::check_addr_prefix(addr);

        let addr_aggr = borrow_global_mut<AddrAggregator>(contract);
        let length = vector::length(&mut addr_aggr.addr_infos);
        let i = 0;

        while (i < length) {
            let addr_info = vector::borrow_mut<AddrInfo>(&mut addr_aggr.addr_infos, i);
            if (addr_info::equal_addr(addr_info, addr)) {
                return addr_info::get_msg(addr_info)
            };
            i = i + 1;
        };

        return string::utf8(b"")
    }

    // update eth addr with signature
    public entry fun update_eth_addr(acct: &signer,
                                     addr: String, signature: String) acquires AddrAggregator {
        //check addr 0x prefix
        addr_info::check_addr_prefix(addr);

        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));
        let length = vector::length(&mut addr_aggr.addr_infos);
        let i = 0;
        while (i < length) {
            let addr_info = vector::borrow_mut<AddrInfo>(&mut addr_aggr.addr_infos, i);

            if (addr_info::equal_addr(addr_info, addr)) {
                addr_eth::update_addr(addr_info, &mut signature);
                break
            };
            i = i + 1;
        };
    }

    // update aptos addr with signature and pubkey
    public entry fun update_aptos_addr(acct: &signer,
                                       addr: String, signature: String, pubkey: String) acquires AddrAggregator {
        //check addr 0x prefix
        addr_info::check_addr_prefix(addr);

        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));
        let length = vector::length(&mut addr_aggr.addr_infos);
        let i = 0;
        while (i < length) {
            let addr_info = vector::borrow_mut<AddrInfo>(&mut addr_aggr.addr_infos, i);
            if (addr_info::equal_addr(addr_info, addr)) {
                addr_aptos::update_addr(addr_info, &mut signature, &mut pubkey);
                break
            };
            i = i + 1;
        };
    }

    // public fun delete addr
    public entry fun delete_addr(
        acct: signer,
        addr: String) acquires AddrAggregator {
        //check addr 0x prefix
        addr_info::check_addr_prefix(addr);

        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(&acct));
        let length = vector::length(&mut addr_aggr.addr_infos);
        let i = 0;
        while (i < length) {
            let addr_info = vector::borrow(&mut addr_aggr.addr_infos, i);
            if (addr_info::equal_addr(addr_info, addr)) {
                vector::remove(&mut addr_aggr.addr_infos, i);
                break
            };
            i = i + 1;
        }
    }
}