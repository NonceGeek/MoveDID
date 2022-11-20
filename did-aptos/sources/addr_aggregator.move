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

    // define addr aggregator type
    const ADDR_AGGREGATOR_TYPE_HUMAN: u64 = 0;
    const ADDR_AGGREGATOR_TYPE_ORG: u64 = 1;
    const ADDR_AGGREGATOR_TYPE_ROBOT: u64 = 2;

    // err enum
    const ERR_ADDR_ALREADY_EXSIT: u64 = 1000;
    const ERR_ADDR_PARAM_VECTOR_LENGHT_MISMATCH: u64 = 1001;


    struct AddrAggregator has key {
        key_addr: address,
        addr_infos_map: Table<String, AddrInfo>,
        addrs: vector<String>,
        type: u64,
        description: String,
        max_id: u64,
        add_addr_event_set: AddAddrEventSet,
        update_addr_signature_event_set: UpdateAddrSignatureEventSet,
        update_addr_event_set: UpdateAddrEventSet,
        delete_addr_event_set: DeleteAddrEventSet,
    }

    struct AddAddrEvent has drop, store {
        addr_type: u64,
        addr: String,
        pubkey: String,
        chains: vector<String>,
        description: String
    }

    struct AddAddrEventSet has store  {
        add_addr_event: EventHandle<AddAddrEvent>,
    }

    struct UpdateAddrSignatureEvent has drop, store {
        addr: String
    }

    struct UpdateAddrSignatureEventSet has store  {
        update_addr_signature_event: EventHandle<UpdateAddrSignatureEvent>,
    }

    struct UpdateAddrEvent has drop, store {
        addr: String,
        chains: vector<String>,
        description: String
    }

    struct UpdateAddrEventSet has store  {
        update_addr_event: EventHandle<UpdateAddrEvent>,
    }

    struct DeleteAddrEvent has drop, store {
        addr: String
    }

    struct DeleteAddrEventSet has store {
        delete_addr_event: EventHandle<DeleteAddrEvent>
    }

    // init
    public entry fun create_addr_aggregator(acct: &signer, type: u64, description: String) {
        let addr_aggr = AddrAggregator {
            key_addr: signer::address_of(acct),
            addr_infos_map: table::new(),
            addrs: vector::empty<String>(),
            type,
            description,
            max_id: 0,
            add_addr_event_set: AddAddrEventSet{
                add_addr_event: account::new_event_handle<AddAddrEvent>(acct),
            },
            update_addr_signature_event_set: UpdateAddrSignatureEventSet{
                update_addr_signature_event: account::new_event_handle<UpdateAddrSignatureEvent>(acct)
            },
            update_addr_event_set: UpdateAddrEventSet {
                update_addr_event:account::new_event_handle<UpdateAddrEvent>(acct)
            },
            delete_addr_event_set: DeleteAddrEventSet {
                delete_addr_event: account::new_event_handle<DeleteAddrEvent>(acct),
            }
        };
        move_to<AddrAggregator>(acct, addr_aggr);
    }

    // update addr aggregator description
    public entry fun update_addr_aggregator_description(acct: &signer, description: String) acquires AddrAggregator {
        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));
        addr_aggr.description = description;
    }

    // add addr
    public entry fun add_addr(acct: &signer,
                              addr_type: u64,
                              addr: String,
                              pubkey: String,
                              chains: vector<String>,
                              description: String) acquires AddrAggregator {
        // check addr is 0x begin
        addr_info::check_addr_prefix(addr);

        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));

        //check addr is already exist
        assert!(!exist_addr_by_map(&mut addr_aggr.addr_infos_map, addr), ERR_ADDR_ALREADY_EXSIT);

        let id = addr_aggr.max_id + 1;
        let addr_info = addr_info::init_addr_info(id, addr_type, addr, pubkey, &chains, description);
        table::add(&mut addr_aggr.addr_infos_map, addr, addr_info);
        vector::push_back(&mut addr_aggr.addrs, addr);

        addr_aggr.max_id = addr_aggr.max_id + 1;

        event::emit_event(&mut addr_aggr.add_addr_event_set.add_addr_event, AddAddrEvent {
            addr_type,
            addr,
            pubkey,
            chains,
            description,
        })
    }

    // batch add addr
    public entry fun batch_add_addr(
        acct: &signer,
        addrs: vector<String>,
        addr_infos: vector<AddrInfo>
    ) acquires AddrAggregator {
        let addrs_length = vector::length(&addrs);
        let addr_infos_length = vector::length(&addr_infos);
        assert!(addrs_length == addr_infos_length, ERR_ADDR_PARAM_VECTOR_LENGHT_MISMATCH);

        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));

        let i = 0;
        while (i < addrs_length) {
            let name = vector::borrow<String>(&addrs, i);
            let addr_info = vector::borrow<AddrInfo>(&addr_infos, i);

            table::add(&mut addr_aggr.addr_infos_map, *name, *addr_info);
            vector::push_back(&mut addr_aggr.addrs, *name);

            event::emit_event(&mut addr_aggr.add_addr_event_set.add_addr_event, AddAddrEvent {
                addr_type: addr_info::get_addr_type(addr_info),
                addr: addr_info::get_addr(addr_info),
                pubkey: addr_info::get_pubkey(addr_info),
                chains: addr_info::get_chains(addr_info),
                description: addr_info::get_description(addr_info)
            });

            i = i + 1;
        };
    }

    fun exist_addr_by_map(addr_infos_map: &mut Table<String, AddrInfo>, addr: String): bool {
        table::contains(addr_infos_map, addr)
    }

    // update eth addr with signature
    public entry fun update_eth_addr(acct: &signer,
                                     addr: String, signature: String) acquires AddrAggregator {
        //check addr 0x prefix
        addr_info::check_addr_prefix(addr);

        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));
        let addr_info = table::borrow_mut(&mut addr_aggr.addr_infos_map, addr);

        addr_eth::update_addr(addr_info, &mut signature);

        event::emit_event(&mut addr_aggr.update_addr_signature_event_set.update_addr_signature_event, UpdateAddrSignatureEvent {
            addr
        });
    }

    // update aptos addr with signature and pubkey
    public entry fun update_aptos_addr(acct: &signer,
                                       addr: String, signature: String) acquires AddrAggregator {
        //check addr 0x prefix
        addr_info::check_addr_prefix(addr);

        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));
        let addr_info = table::borrow_mut(&mut addr_aggr.addr_infos_map, addr);

        addr_aptos::update_addr(addr_info, &mut signature);

        event::emit_event(&mut addr_aggr.update_addr_signature_event_set.update_addr_signature_event, UpdateAddrSignatureEvent {
            addr
        });
    }

    //update addr msg
    public entry fun update_addr_msg_with_chains_and_description(
        acct: &signer, addr: String, chains: vector<String>, description: String) acquires AddrAggregator {
        //check addr 0x prefix
        addr_info::check_addr_prefix(addr);

        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));
        let addr_info = table::borrow_mut(&mut addr_aggr.addr_infos_map, addr);

        addr_info::update_addr_msg_with_chains_and_description(addr_info, chains, description);

        event::emit_event(&mut addr_aggr.update_addr_event_set.update_addr_event, UpdateAddrEvent {
            addr,
            chains,
            description
        });
    }

    //update addr info for non verify
    public entry fun update_addr_for_non_verify(
        acct: &signer, addr: String, chains: vector<String>, description: String) acquires AddrAggregator {
        //check addr 0x prefix
        addr_info::check_addr_prefix(addr);

        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));
        let addr_info = table::borrow_mut(&mut addr_aggr.addr_infos_map, addr);

        addr_info::update_addr_for_non_verify(addr_info, chains, description);

        event::emit_event(&mut addr_aggr.update_addr_event_set.update_addr_event, UpdateAddrEvent {
            addr,
            chains,
            description
        });
    }

    // public fun delete addr
    public entry fun delete_addr(
        acct: &signer,
        addr: String) acquires AddrAggregator {
        //check addr 0x prefix
        addr_info::check_addr_prefix(addr);

        let addr_aggr = borrow_global_mut<AddrAggregator>(signer::address_of(acct));
        table::remove(&mut addr_aggr.addr_infos_map, addr);

        let length = vector::length(&addr_aggr.addrs);
        let i = 0;
        while (i < length) {
            let current_addr = vector::borrow<String>(&addr_aggr.addrs, i);
            if (*current_addr == addr) {
                vector::remove(&mut addr_aggr.addrs, i);

                event::emit_event(&mut addr_aggr.delete_addr_event_set.delete_addr_event, DeleteAddrEvent {
                    addr
                });
                break
            };
            i = i + 1;
        };
    }
}