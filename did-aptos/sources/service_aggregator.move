module my_addr::service_aggregator {
    use std::signer;
    use std::vector;
    use std::string::{String};
    use std::table::{Self, Table};
    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::account;

    const ERR_SERVICE_PARAM_VECTOR_LENGHT_MISMATCH: u64 = 5000;

    struct Service has store, copy, drop {
        description: String,
        url: String,
        verification_url: String,
        expired_at: u64
    }

    struct ServiceAggregator has key {
        key_addr: address,
        services_map: Table<String, Service>,
        names: vector<String>,
        add_service_event_set: AddServiceEventSet,
        update_service_event_set: UpdateServiceEventSet,
        delete_service_event_set: DeleteServiceEventSet,
    }

    struct CreateServiceAggregatorEvent has drop, store {
        key_addr: address,
    }

    struct CreateServiceAggregatorEventSet has key, store {
        create_service_aggregator_event: EventHandle<CreateServiceAggregatorEvent>
    }

    struct AddrServiceEvent has drop, store {
        name: String,
        description: String,
        url: String,
        verification_url: String,
        expired_at: u64
    }

    struct AddServiceEventSet has store {
        add_service_event: EventHandle<AddrServiceEvent>
    }

    struct UpdateServiceEvent has drop, store {
        name: String,
        description: String,
        url: String,
        verification_url: String, 
        expired_at: u64
    }

    struct UpdateServiceEventSet has store {
        update_service_event: EventHandle<UpdateServiceEvent>,
    }

    struct DeleteServiceEvent has drop, store {
        name: String
    }

    struct DeleteServiceEventSet has store {
        delete_service_event: EventHandle<DeleteServiceEvent>,
    }

    // This is only callable during publishing.
    fun init_module(account: &signer) {
        move_to(account, CreateServiceAggregatorEventSet {
            create_service_aggregator_event: account::new_event_handle<CreateServiceAggregatorEvent>(account),
        });
    }

    fun emit_create_service_aggregator_event(key_addr: address) acquires CreateServiceAggregatorEventSet {
        let event = CreateServiceAggregatorEvent {
            key_addr,
        };
        event::emit_event(&mut borrow_global_mut<CreateServiceAggregatorEventSet>(@my_addr).create_service_aggregator_event, event);
    }

    public entry fun create_service_aggregator(acct: &signer) acquires CreateServiceAggregatorEventSet {
        let service_aggr = ServiceAggregator {
            key_addr: signer::address_of(acct),
            services_map: table::new(),
            names: vector::empty<String>(),
            add_service_event_set: AddServiceEventSet{
                add_service_event: account::new_event_handle<AddrServiceEvent>(acct)
            },
            update_service_event_set: UpdateServiceEventSet{
                update_service_event: account::new_event_handle<UpdateServiceEvent>(acct)
            },
            delete_service_event_set: DeleteServiceEventSet {
                delete_service_event: account::new_event_handle<DeleteServiceEvent>(acct)
            },
        };

        emit_create_service_aggregator_event(signer::address_of(acct));

        move_to<ServiceAggregator>(acct, service_aggr);
    }

    public entry fun add_service(
        acct: &signer,
        name: String,
        description: String,
        url: String,
        verification_url: String,
        expired_at: u64
    ) acquires ServiceAggregator {
        let service_aggr = borrow_global_mut<ServiceAggregator>(signer::address_of(acct));
        do_add_service(service_aggr, name, description, url, verification_url, expired_at);
    }

    fun do_add_service(
        service_aggr: &mut ServiceAggregator,
        name: String,
        description: String,
        url: String,
        verification_url: String,
        expired_at: u64
    ) {
        let service_info = Service {
            description,
            url,
            verification_url,
            expired_at
        };

        table::add(&mut service_aggr.services_map, name, service_info);
        vector::push_back(&mut service_aggr.names, name);

        event::emit_event(&mut service_aggr.add_service_event_set.add_service_event, AddrServiceEvent {
            name,
            description,
            url,
            verification_url,
            expired_at
        })
    }

    public entry fun batch_add_services(
        acct: &signer,
        names: vector<String>,
        descriptions : vector<String>,
        urls: vector<String>,
        verification_urls: vector<String>,
        expired_at_vec: vector<u64>
    ) acquires ServiceAggregator {
        let names_length = vector::length(&names);

        let length_match = names_length == vector::length(&urls) && names_length == vector::length(&descriptions)
            && names_length == vector::length(&verification_urls) && names_length == vector::length(&expired_at_vec);

        assert!(length_match, ERR_SERVICE_PARAM_VECTOR_LENGHT_MISMATCH);

        let service_aggr = borrow_global_mut<ServiceAggregator>(signer::address_of(acct));

        let i = 0;
        while (i < names_length) {
            let name = vector::borrow<String>(&names, i);
            let url = vector::borrow<String>(&urls, i);
            let description = vector::borrow<String>(&descriptions, i);
            let verification_url = vector::borrow<String>(&verification_urls, i);
            let expired_at = vector::borrow<u64>(&expired_at_vec, i);
            do_add_service(service_aggr, *name, *description, *url, *verification_url, *expired_at);

            i = i + 1;
        };
    }

    // Public entry fun update service with params.
    public entry fun update_service(
        acct: &signer,
        name: String,
        new_description: String,
        new_url: String,
        new_verification_url: String,
        expired_at: u64
    ) acquires ServiceAggregator {
        let service_aggr = borrow_global_mut<ServiceAggregator>(signer::address_of(acct));
        let service = table::borrow_mut(&mut service_aggr.services_map, name);

        service.description = new_description;
        service.verification_url = new_verification_url;
        service.url = new_url;
        service.expired_at = expired_at;

        event::emit_event(&mut service_aggr.update_service_event_set.update_service_event, UpdateServiceEvent {
            name,
            description: new_description,
            url: new_url,
            verification_url: new_verification_url,
            expired_at: expired_at
        })
    }

    // Public entry fun delete service.
    public entry fun delete_service(
        acct: &signer,
        name: String) acquires ServiceAggregator {
        let service_aggr = borrow_global_mut<ServiceAggregator>(signer::address_of(acct));
        table::remove(&mut service_aggr.services_map, name);

        let length = vector::length(&service_aggr.names);
        let i = 0;
        while (i < length) {
            let current_name = vector::borrow<String>(&service_aggr.names, i);
            if (*current_name == name) {
                vector::remove(&mut service_aggr.names, i);

                event::emit_event(&mut service_aggr.delete_service_event_set.delete_service_event, DeleteServiceEvent {
                    name
                });

                break
            };
            i = i + 1;
        };
    }

    #[test_only]
    use std::string;

    #[test(acct = @0x123)]
    public entry fun test_create_service_aggregator(acct: &signer) acquires ServiceAggregator, CreateServiceAggregatorEventSet {
        account::create_account_for_test(signer::address_of(acct));
        create_service_aggregator(acct);
        let service_aggr = borrow_global_mut<ServiceAggregator>(signer::address_of(acct));
        assert!(service_aggr.key_addr == @0x123, 501);
    }

    #[test(aptos_framework = @0x1, acct = @0x123)]
    public entry fun test_add_service(aptos_framework: &signer, acct: &signer) acquires ServiceAggregator, CreateServiceAggregatorEventSet {
        account::create_account_for_test(signer::address_of(acct));
        timestamp::set_time_has_started_for_testing(aptos_framework);

        create_service_aggregator(acct);
        add_service(acct, string::utf8(b"nonce.geek"), string::utf8(b"test"), string::utf8(b"https://movedid.build"), string::utf8(b"https://movedid.build"), 7200);
        let service_aggr = borrow_global_mut<ServiceAggregator>(signer::address_of(acct));
        let name = vector::pop_back(&mut service_aggr.names);
        assert!(name == string::utf8(b"nonce.geek"), 502);
    }

    #[test(aptos_framework = @0x1, acct = @0x123)]
    public entry fun test_batch_add_services(aptos_framework: &signer, acct: &signer) acquires ServiceAggregator, CreateServiceAggregatorEventSet {
        account::create_account_for_test(signer::address_of(acct));
        timestamp::set_time_has_started_for_testing(aptos_framework);

        create_service_aggregator(acct);
        let names = vector[string::utf8(b"nonce1"), string::utf8(b"nonce2")];

        batch_add_services(acct, names, vector[string::utf8(b"nonce1.url"), string::utf8(b"nonce2.url")],
            vector[string::utf8(b"nonce1.desc"),string::utf8(b"nonce2.desc")],
            vector[string::utf8(b"nonce1.verif"),string::utf8(b"nonce2.verif")], vector[0,0]
        );

        let service_aggr = borrow_global_mut<ServiceAggregator>(signer::address_of(acct));
        let _name = vector::pop_back(&mut service_aggr.names);
        assert!(vector::length(&service_aggr.names) == 1, 503);
        assert!(_name == string::utf8(b"nonce2"), 507);
    }


    #[test(aptos_framework = @0x1, acct = @0x123)]
    public entry fun test_update_service(aptos_framework: &signer, acct: &signer) acquires ServiceAggregator, CreateServiceAggregatorEventSet {
        account::create_account_for_test(signer::address_of(acct));
        timestamp::set_time_has_started_for_testing(aptos_framework);

        create_service_aggregator(acct);
        add_service(acct, string::utf8(b"nonce.geek"), string::utf8(b"test"), string::utf8(b"https://movedid.build"), string::utf8(b"https://movedid.build"), 0);
        update_service(acct, string::utf8(b"nonce.geek"), string::utf8(b"test2"), string::utf8(b"https://movedid.build2"), string::utf8(b"https://movedid.build2", 0));

        let service_aggr = borrow_global_mut<ServiceAggregator>(signer::address_of(acct));
        let service = table::borrow_mut(&mut service_aggr.services_map, string::utf8(b"nonce.geek"));

        assert!(service.description == string::utf8(b"test2"), 504);
    }

    #[test(aptos_framework = @0x1, acct = @0x123)]
    public entry fun test_delete_services(aptos_framework: &signer, acct: &signer) acquires ServiceAggregator, CreateServiceAggregatorEventSet {
        account::create_account_for_test(signer::address_of(acct));
        timestamp::set_time_has_started_for_testing(aptos_framework);

        create_service_aggregator(acct);
        let names = vector[string::utf8(b"nonce1"), string::utf8(b"nonce2")];
        batch_add_services(acct, names, vector[string::utf8(b"nonce1.url"), string::utf8(b"nonce2.url")],
            vector[string::utf8(b"nonce1.desc"),string::utf8(b"nonce2.desc")],
            vector[string::utf8(b"nonce1.verif"),string::utf8(b"nonce2.verif")], vector[0,0]
        );

        delete_service(acct, string::utf8(b"nonce1"));

        let service_aggr = borrow_global_mut<ServiceAggregator>(signer::address_of(acct));
        assert!(vector::length(&service_aggr.names) == 1, 505);
    }
}