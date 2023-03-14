module my_addr::addr_aggregator {
    use std::signer;
    use std::string::{String};
    use std::vector;
    use std::table::{Self, Table};
    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::account;
    use my_addr::addr_info::{Self, AddrInfo};
    use my_addr::addr_eth;
    use my_addr::addr_aptos;

    // Define addr aggregator type.
    const ADDR_AGGREGATOR_TYPE_HUMAN: u64 = 0;
    const ADDR_AGGREGATOR_TYPE_ORG: u64 = 1;
    const ADDR_AGGREGATOR_TYPE_ROBOT: u64 = 2;

    // Err enum.
    const ERR_ADDR_ALREADY_EXSIT: u64 = 1000;
    const ERR_ADDR_PARAM_VECTOR_LENGHT_MISMATCH: u64 = 1001;

    //:!:>resource
    struct AddrAggregator has key {
        key_addr: address,
        addr_infos_map: Table<String, AddrInfo>,
        addrs: vector<String>,
        type: u64,
        description: String,
        max_id: u64,
        add_addr_events: EventHandle<AddAddrEvent>,
        update_addr_signature_events: EventHandle<UpdateAddrSignatureEvent>,
        update_addr_events: EventHandle<UpdateAddrEvent>,
        delete_addr_events: EventHandle<DeleteAddrEvent>,
    }
    //<:!:resource

    struct CreateAddrAggregatorEvent has drop, store {
        key_addr: address,
        type: u64,
        description: String,
    }

    struct CreateAddrAggregatorEventSet has key, store {
        create_addr_aggregator_events: EventHandle<CreateAddrAggregatorEvent>
    }

    struct AddAddrEvent has drop, store {
        addr_type: u64,
        addr: String,
        pubkey: String,
        chains: vector<String>,
        description: String,
        expired_at: u64
    }

    struct UpdateAddrSignatureEvent has drop, store {
        addr: String
    }

    struct UpdateAddrEvent has drop, store {
        addr: String,
        chains: vector<String>,
        description: String,
        expired_at: u64
    }

    struct DeleteAddrEvent has drop, store {
        addr: String
    }

    // This is only callable during publishing.
    fun init_module(account: &signer) {
        move_to(account, CreateAddrAggregatorEventSet {
            create_addr_aggregator_events: account::new_event_handle<CreateAddrAggregatorEvent>(account),
        });
    }

    fun emit_create_addr_aggregator_event(key_addr: address, type: u64, description: String) acquires CreateAddrAggregatorEventSet {
        let event = CreateAddrAggregatorEvent {
            key_addr,
            type,
            description,
        };
        event::emit_event(&mut borrow_global_mut<CreateAddrAggregatorEventSet>(@my_addr).create_addr_aggregator_events, event);
    }

    // Init.
    public entry fun create_addr_aggregator(acct: &signer, type: u64, description: String) acquires CreateAddrAggregatorEventSet {
        let addr_aggr = AddrAggregator {
            key_addr: signer::address_of(acct),
            addr_infos_map: table::new(),
            addrs: vector::empty<String>(),
            type,
            description,
            max_id: 0,
            add_addr_events: account::new_event_handle<AddAddrEvent>(acct),
            update_addr_signature_events: account::new_event_handle<UpdateAddrSignatureEvent>(acct),
            update_addr_events: account::new_event_handle<UpdateAddrEvent>(acct),
            delete_addr_events: account::new_event_handle<DeleteAddrEvent>(acct),
        };

        emit_create_addr_aggregator_event(signer::address_of(acct), type, description);

        move_to<AddrAggregator>(acct, addr_aggr);
    }

    // Update addr aggregator description.
    public entry fun update_addr_aggregator_description(acct: &signer, description: String) acquires AddrAggregator {
        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));
        addr_aggr.description = description;
    }

    // Add addr.
    public entry fun add_addr(
        acct: &signer,
        addr_type: u64,
        addr: String,
        pubkey: String,
        chains: vector<String>,
        description: String,
        expired_at: u64
    ) acquires AddrAggregator {
        let send_addr = signer::address_of(acct);
        let addr_aggr = borrow_global_mut<AddrAggregator>(send_addr);

        do_add_addr(addr_aggr, send_addr, addr_type, addr, pubkey, chains, description, expired_at);
    }

    fun do_add_addr(
        addr_aggr: &mut AddrAggregator,
        send_addr: address,
        addr_type: u64,
        addr: String,
        pubkey: String,
        chains: vector<String>,
        description: String,
        expired_at: u64) {
        // Check addr is 0x begin.
        addr_info::check_addr_prefix(addr);

        // Check addr is already exist.
        assert!(!exist_addr_by_map(&mut addr_aggr.addr_infos_map, addr), ERR_ADDR_ALREADY_EXSIT);

        addr_aggr.max_id = addr_aggr.max_id + 1;
        let addr_info = addr_info::init_addr_info(send_addr, addr_aggr.max_id, addr_type, addr, pubkey, &chains, description, expired_at);
        table::add(&mut addr_aggr.addr_infos_map, addr, addr_info);
        vector::push_back(&mut addr_aggr.addrs, addr);


        event::emit_event(&mut addr_aggr.add_addr_events, AddAddrEvent {
            addr_type,
            addr,
            pubkey,
            chains,
            description,
            expired_at
        })
    }

    // Batch add addrs.
    public entry fun batch_add_addrs(
        acct: &signer,
        addrs: vector<String>,
        addr_types: vector<u64>,
        pubkeys: vector<String>,
        chains_vec: vector<vector<String>>,
        descriptions: vector<String>,
        expired_at_vec: vector<u64>
    ) acquires AddrAggregator {
        let addrs_length = vector::length(&addrs);
        let length_match = addrs_length == vector::length(&addr_types) && addrs_length == vector::length(&pubkeys)
            && addrs_length == vector::length(&chains_vec) && addrs_length == vector::length(&descriptions)
            && addrs_length == vector::length(&expired_at_vec) ;
        assert!(length_match, ERR_ADDR_PARAM_VECTOR_LENGHT_MISMATCH);

        let send_addr = signer::address_of(acct);
        let addr_aggr = borrow_global_mut<AddrAggregator>(send_addr);

        let i = 0;
        while (i < addrs_length) {
            let addr = vector::borrow<String>(&addrs, i);
            let addr_type = vector::borrow<u64>(&addr_types, i);
            let pubkey = vector::borrow<String>(&pubkeys, i);
            let chains = vector::borrow<vector<String>>(&chains_vec, i);
            let description = vector::borrow<String>(&descriptions, i);
            let expired_at = vector::borrow<u64>(&expired_at_vec, i);

            do_add_addr(addr_aggr, send_addr, *addr_type, *addr, *pubkey, *chains, *description, *expired_at);

            i = i + 1;
        };
    }

    fun exist_addr_by_map(addr_infos_map: &mut Table<String, AddrInfo>, addr: String): bool {
        table::contains(addr_infos_map, addr)
    }

    // Update eth addr with signature.
    public entry fun update_eth_addr(acct: &signer,
                                     addr: String, signature: String) acquires AddrAggregator {
        // Check addr 0x prefix.
        addr_info::check_addr_prefix(addr);

        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));
        let addr_info = table::borrow_mut(&mut addr_aggr.addr_infos_map, addr);

        addr_eth::update_addr(addr_info, &mut signature);

        event::emit_event(&mut addr_aggr.update_addr_signature_events, UpdateAddrSignatureEvent {
            addr
        });
    }

    // Update aptos addr with signature
    public entry fun update_aptos_addr(acct: &signer,
                                       addr: String, signature: String, msg: String) acquires AddrAggregator {
        // Check addr 0x prefix.
        addr_info::check_addr_prefix(addr);

        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));
        let addr_info = table::borrow_mut(&mut addr_aggr.addr_infos_map, addr);

        addr_aptos::update_addr(addr_info, &mut signature, msg);

        event::emit_event(&mut addr_aggr.update_addr_signature_events, UpdateAddrSignatureEvent {
            addr
        });
    }

    // Update addr info for addr that verficated, you should resign after you update info.
    public entry fun update_addr_info_with_chains_and_description_and_expired_at(
        acct: &signer, addr: String, chains: vector<String>, description: String, expired_at: u64) acquires AddrAggregator {
        // Check addr 0x prefix.
        addr_info::check_addr_prefix(addr);

        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));
        let addr_info = table::borrow_mut(&mut addr_aggr.addr_infos_map, addr);

        addr_info::update_addr_info_with_chains_and_description_and_expired_at(addr_info, chains, description, expired_at);

        event::emit_event(&mut addr_aggr.update_addr_events, UpdateAddrEvent {
            addr,
            chains,
            description,
            expired_at
        });
    }

    // Update addr info for non verification.
    public entry fun update_addr_info_for_non_verification(
        acct: &signer, addr: String, chains: vector<String>, description: String, expired_at: u64) acquires AddrAggregator {
        // Check addr 0x prefix.
        addr_info::check_addr_prefix(addr);

        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));
        let addr_info = table::borrow_mut(&mut addr_aggr.addr_infos_map, addr);

        addr_info::update_addr_info_for_non_verification(addr_info, chains, description, expired_at);

        event::emit_event(&mut addr_aggr.update_addr_events, UpdateAddrEvent {
            addr,
            chains,
            description,
            expired_at
        });
    }

    // Delete addr.
    public entry fun delete_addr(
        acct: &signer,
        addr: String) acquires AddrAggregator {
        // Check addr 0x prefix.
        addr_info::check_addr_prefix(addr);

        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));
        table::remove(&mut addr_aggr.addr_infos_map, addr);

        let length = vector::length(&addr_aggr.addrs);
        let i = 0;
        while (i < length) {
            let current_addr = vector::borrow<String>(&addr_aggr.addrs, i);
            if (*current_addr == addr) {
                vector::remove(&mut addr_aggr.addrs, i);

                event::emit_event(&mut addr_aggr.delete_addr_events, DeleteAddrEvent {
                    addr
                });
                break
            };
            i = i + 1;
        };
    }

    // Returns addr agggregator max_id
    #[view]
    public fun get_max_id(owner: address): u64 acquires AddrAggregator {
        borrow_global<AddrAggregator>(owner).max_id
    }

    // Returns addr agggregator description
    #[view]
    public fun get_description(owner: address): String acquires AddrAggregator {
        borrow_global<AddrAggregator>(owner).description
    }

    // Returns addr agggregator type
    #[view]
    public fun get_type(owner: address): u64 acquires AddrAggregator {
        borrow_global<AddrAggregator>(owner).type
    }

    #[test_only]
    use std::string;
    #[test_only]
    use aptos_framework::timestamp;
    #[test_only]
    use aptos_framework::block;
    #[test_only]
    use std::debug;

    #[test(acct = @0x123)]
    public entry fun test_create_addr_aggregator(acct: &signer) acquires AddrAggregator, CreateAddrAggregatorEventSet {
        account::create_account_for_test(signer::address_of(acct));
        init_module(acct); //init module

        create_addr_aggregator(acct, 0, string::utf8(b"test"));
        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));
        assert!(addr_aggr.description == string::utf8(b"test"), 501);
    }

    #[test(acct = @0x123)]
    public entry fun test_update_addr_aggregator_description(acct: &signer) acquires AddrAggregator, CreateAddrAggregatorEventSet {
        account::create_account_for_test(signer::address_of(acct));
        init_module(acct); //init module

        create_addr_aggregator(acct, 0, string::utf8(b"test"));
        update_addr_aggregator_description(acct, string::utf8(b"updated"));

        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));
        assert!(addr_aggr.description == string::utf8(b"updated"), 502);
    }

    #[test(aptos_framework = @0x1, acct = @0x123)]
    public entry fun test_add_addr(aptos_framework: &signer, acct: &signer) acquires AddrAggregator, CreateAddrAggregatorEventSet {
        account::create_account_for_test(signer::address_of(acct));
        account::create_account_for_test(@aptos_framework);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        block::initialize_for_test(aptos_framework, 1000);
        init_module(acct); //init module

        create_addr_aggregator(acct, 0, string::utf8(b"test"));
        add_addr(acct, 0, string::utf8(b"0x14791697260E4c9A71f18484C9f997B308e59325"), string::utf8(b""), vector[string::utf8(b"eth"), string::utf8(b"polygon")],
            string::utf8(b"evm addr"), 7200);
        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));
        let info = table::borrow_mut(&mut addr_aggr.addr_infos_map, string::utf8(b"0x14791697260E4c9A71f18484C9f997B308e59325"));
        let msg = addr_info::get_msg(info);

        debug::print(&msg);
        assert!(msg == string::utf8(b"0.2.0000000000000000000000000000000000000000000000000000000000000123.1.nonce_geek"), 503);
    }

    #[test(aptos_framework = @0x1, acct = @0x123)]
    public entry fun test_batch_add_addr(aptos_framework: &signer, acct: &signer) acquires AddrAggregator, CreateAddrAggregatorEventSet {
        account::create_account_for_test(signer::address_of(acct));
        account::create_account_for_test(@aptos_framework);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        block::initialize_for_test(aptos_framework, 1000);
        init_module(acct); //init module

        create_addr_aggregator(acct, 0, string::utf8(b"test"));
        batch_add_addrs(acct, vector[string::utf8(b"0x14791697260E4c9A71f18484C9f997B308e59325"), string::utf8(b"0x978c213990c4833df71548df7ce49d54c759d6b6d932de22b24d56060b7af2aa")],
            vector[0, 1], vector[string::utf8(b"0x14791697260E4c9A71f18484C9f997B308e59325"), string::utf8(b"0x978c213990c4833df71548df7ce49d54c759d6b6d932de22b24d56060b7af2aa")],
            vector[vector[string::utf8(b"eth"), string::utf8(b"polygon")], vector[string::utf8(b"aptos")]],
            vector[string::utf8(b"first addr"), string::utf8(b"second addr")], vector[7200, 7200]);
    }

    #[test(aptos_framework = @0x1, acct = @0x123)]
    public entry fun test_update_eth_addr(aptos_framework: &signer, acct: &signer) acquires AddrAggregator, CreateAddrAggregatorEventSet {
        account::create_account_for_test(signer::address_of(acct));
        account::create_account_for_test(@aptos_framework);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        block::initialize_for_test(aptos_framework, 1000);
        init_module(acct); //init module

        create_addr_aggregator(acct, 0, string::utf8(b"test"));
        add_addr(acct, 0, string::utf8(b"0x14791697260E4c9A71f18484C9f997B308e59325"), string::utf8(b""), vector[string::utf8(b"eth"), string::utf8(b"polygon")],
            string::utf8(b"evm addr"), 7200);

        // msg is 0.2.0000000000000000000000000000000000000000000000000000000000000123.1.nonce_geek
        update_eth_addr(acct, string::utf8(b"0x14791697260E4c9A71f18484C9f997B308e59325"), string::utf8(b"0xede93b0920b5c0584102bee3804cda9c83c4e05d4b2cde7aecdc1182f25021521b934c08f48552eaa286bf28f2c2cfa30c8395d6d95a95aae125ba2befb2e85c1b"));
    }

    #[test(aptos_framework = @0x1, acct = @0x123)]
    public entry fun test_update_aptos_addr(aptos_framework: &signer, acct: &signer) acquires AddrAggregator, CreateAddrAggregatorEventSet {
        account::create_account_for_test(signer::address_of(acct));
        account::create_account_for_test(@aptos_framework);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        block::initialize_for_test(aptos_framework, 1000);
        init_module(acct); //init module

        create_addr_aggregator(acct, 0, string::utf8(b"test"));
        add_addr(acct, 1, string::utf8(b"0x978c213990c4833df71548df7ce49d54c759d6b6d932de22b24d56060b7af2aa"), string::utf8(b"0xde19e5d1880cac87d57484ce9ed2e84cf0f9599f12e7cc3a52e4e7657a763f2c"), vector[string::utf8(b"aptos")],
            string::utf8(b"aptos addr"), 7200);

        // msg is 0.2.0000000000000000000000000000000000000000000000000000000000000123.1.nonce_geek
        let msg = string::utf8(b"0.2.0000000000000000000000000000000000000000000000000000000000000123.1.nonce_geek");
        update_aptos_addr(acct, string::utf8(b"0x978c213990c4833df71548df7ce49d54c759d6b6d932de22b24d56060b7af2aa"), string::utf8(b"0x1fc94485554e14c5cd59de70763e57b1222a33041185971e58cefc1d96105a5e6b2290a77fe62ac170690cdd9881119bbfa7d004790834803f723706958f6e03"), msg);
    }

    #[test(aptos_framework = @0x1, acct = @0x123)]
    public entry fun test_update_addr_info_with_chains_and_description_and_expired_at(aptos_framework: &signer, acct: &signer) acquires AddrAggregator, CreateAddrAggregatorEventSet {
        account::create_account_for_test(signer::address_of(acct));
        account::create_account_for_test(@aptos_framework);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        block::initialize_for_test(aptos_framework, 1000);
        init_module(acct); //init module

        create_addr_aggregator(acct, 0, string::utf8(b"test"));
        add_addr(acct, 0, string::utf8(b"0x14791697260E4c9A71f18484C9f997B308e59325"), string::utf8(b""), vector[string::utf8(b"eth"), string::utf8(b"polygon")],
            string::utf8(b"evm addr"), 7200);

        // msg is 0.1.0000000000000000000000000000000000000000000000000000000000000123.1.nonce_geek
        update_eth_addr(acct, string::utf8(b"0x14791697260E4c9A71f18484C9f997B308e59325"), string::utf8(b"0xede93b0920b5c0584102bee3804cda9c83c4e05d4b2cde7aecdc1182f25021521b934c08f48552eaa286bf28f2c2cfa30c8395d6d95a95aae125ba2befb2e85c1b"));

        update_addr_info_with_chains_and_description_and_expired_at(acct, string::utf8(b"0x14791697260E4c9A71f18484C9f997B308e59325"), vector[string::utf8(b"bsc")],
            string::utf8(b"evm bsc addr"), 0);
    }

    #[test(aptos_framework = @0x1, acct = @0x123)]
    public entry fun test_update_addr_info_for_non_verification(aptos_framework: &signer, acct: &signer) acquires AddrAggregator, CreateAddrAggregatorEventSet {
        account::create_account_for_test(signer::address_of(acct));
        account::create_account_for_test(@aptos_framework);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        block::initialize_for_test(aptos_framework, 1000);
        init_module(acct); //init module

        create_addr_aggregator(acct, 0, string::utf8(b"test"));
        add_addr(acct, 0, string::utf8(b"0x14791697260E4c9A71f18484C9f997B308e59325"), string::utf8(b""), vector[string::utf8(b"eth"), string::utf8(b"polygon")],
            string::utf8(b"evm addr"), 7200);

        update_addr_info_for_non_verification(acct, string::utf8(b"0x14791697260E4c9A71f18484C9f997B308e59325"), vector[string::utf8(b"bsc")],
            string::utf8(b"evm bsc addr"), 0);
    }

    #[test(aptos_framework = @0x1, acct = @0x123)]
    public entry fun test_delete_addr(aptos_framework: &signer, acct: &signer) acquires AddrAggregator, CreateAddrAggregatorEventSet {
        account::create_account_for_test(signer::address_of(acct));
        account::create_account_for_test(@aptos_framework);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        block::initialize_for_test(aptos_framework, 1000);
        init_module(acct); //init module

        create_addr_aggregator(acct, 0, string::utf8(b"test"));
        add_addr(acct, 0, string::utf8(b"0x14791697260E4c9A71f18484C9f997B308e59325"), string::utf8(b""), vector[string::utf8(b"eth"), string::utf8(b"polygon")],
            string::utf8(b"evm addr"), 7200);

        delete_addr(acct, string::utf8(b"0x14791697260E4c9A71f18484C9f997B308e59325"));

        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));
        assert!(table::contains(&mut addr_aggr.addr_infos_map, string::utf8(b"0x14791697260E4c9A71f18484C9f997B308e59325")) == false, 505);
    }
}