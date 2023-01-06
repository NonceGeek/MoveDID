module my_addr::service_aggregator {
    use std::signer;
    use std::vector;
    use std::string::{String};
    use std::table::{Self, Table};
    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::account;

    const ERR_SERVICE_PARAM_VECTOR_LENGHT_MISMATCH: u64 = 5000;

    struct Service has store, copy, drop {
        url: String,
        description: String,
        verification_url: String
    }

    struct ServiceAggregator has key {
        key_addr: address,
        services_map: Table<String, Service>,
        names: vector<String>,
        add_service_event_set: AddServiceEventSet,
        update_service_event_set: UpdateServiceEventSet,
        delete_service_event_set: DeleteServiceEventSet,
    }

    struct AddrServiceEvent has drop, store {
        name: String,
        url: String,
        description: String,
        verification_url: String
    }

    struct AddServiceEventSet has store {
        add_service_event: EventHandle<AddrServiceEvent>,
    }

    struct UpdateServiceEvent has drop, store {
        name: String,
        url: String,
        description: String,
        verification_url: String
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

    public entry fun create_service_aggregator(acct: &signer) {
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
            }
        };
        move_to<ServiceAggregator>(acct, service_aggr);
    }

    public entry fun add_service(
        acct: &signer,
        name: String,
        url: String,
        description: String,
        verification_url: String
    ) acquires ServiceAggregator {
        let service_aggr = borrow_global_mut<ServiceAggregator>(signer::address_of(acct));
        let service_info = Service {
            url,
            description,
            verification_url
        };

        table::add(&mut service_aggr.services_map, name, service_info);
        vector::push_back(&mut service_aggr.names, name);

        event::emit_event(&mut service_aggr.add_service_event_set.add_service_event, AddrServiceEvent {
            name,
            url,
            description,
            verification_url
        })
    }

    public entry fun batch_add_services(
        acct: &signer,
        names: vector<String>,
        services: vector<Service>
    ) acquires ServiceAggregator {
        let names_length = vector::length(&names);
        let services_length = vector::length(&services);
        assert!(names_length == services_length, ERR_SERVICE_PARAM_VECTOR_LENGHT_MISMATCH);

        let service_aggr = borrow_global_mut<ServiceAggregator>(signer::address_of(acct));

        let i = 0;
        while (i < names_length) {
            let name = vector::borrow<String>(&names, i);
            let service = vector::borrow<Service>(&services, i);

            table::add(&mut service_aggr.services_map, *name, *service);
            vector::push_back(&mut service_aggr.names, *name);

            event::emit_event(&mut service_aggr.add_service_event_set.add_service_event, AddrServiceEvent {
                name: *name,
                url: service.url,
                description: service.description,
                verification_url: service.verification_url
            });

            i = i + 1;
        };
    }

    // Public entry fun update service with params.
    public entry fun update_service(
        acct: &signer,
        name: String,
        new_description: String,
        new_url: String,
        new_verification_url: String
    ) acquires ServiceAggregator {
        let service_aggr = borrow_global_mut<ServiceAggregator>(signer::address_of(acct));
        let service = table::borrow_mut(&mut service_aggr.services_map, name);

        service.url = new_url;
        service.description = new_description;
        service.verification_url = new_verification_url;

        event::emit_event(&mut service_aggr.update_service_event_set.update_service_event, UpdateServiceEvent {
            name,
            url: new_url,
            description: new_description,
            verification_url: new_verification_url
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
    // use aptos_framework::timestamp;
    // use aptos_framework::block;

    #[test(acct = @0x123)]
    public entry fun test_create_service_aggregator(acct: &signer) acquires ServiceAggregator{
        account::create_account_for_test(signer::address_of(acct));
        create_service_aggregator(acct);

        let service_aggr = borrow_global_mut<ServiceAggregator>(signer::address_of(acct));
        assert!(vector::length(&service_aggr.names) == 0, 601);
    }

    #[test(acct = @0x123)]
    public entry fun test_add_addr(acct: &signer) acquires ServiceAggregator{
        account::create_account_for_test(signer::address_of(acct));
        create_service_aggregator(acct);

        add_service(acct, string::utf8(b"google"), string::utf8(b"www.google.com"), string::utf8(b"google"), string::utf8(b""));
        let service_aggr = borrow_global_mut<ServiceAggregator>(signer::address_of(acct));
        let service = table::borrow_mut(&mut service_aggr.services_map, string::utf8(b"google"));
        assert!(service.description == string::utf8(b"google"), 602);
    }

    #[test(acct = @0x123)]
    public entry fun test_batch_add_service(acct: &signer) acquires ServiceAggregator{
        account::create_account_for_test(signer::address_of(acct));
        create_service_aggregator(acct);

        let names = vector::empty<String>();
        let services = vector::empty<Service>();
        let first_service = Service {
            url : string::utf8(b"www.google.com"),
            description : string::utf8(b"google"),
            verification_url : string::utf8(b"")
        };
        vector::push_back(&mut names, string::utf8(b"google"));
        vector::push_back(&mut services, first_service);

        let second_service = Service {
            url : string::utf8(b"www.twitter.com"),
            description : string::utf8(b"twitter"),
            verification_url: string::utf8(b"")
        };
        vector::push_back(&mut names, string::utf8(b"twitter"));
        vector::push_back(&mut services, second_service);
        batch_add_services(acct, names, services);
    }

    #[test(acct = @0x123)]
    public entry fun test_update_service(acct: &signer) acquires ServiceAggregator{
        account::create_account_for_test(signer::address_of(acct));
        create_service_aggregator(acct);
        add_service(acct, string::utf8(b"google"), string::utf8(b"www.google.com"), string::utf8(b"google"), string::utf8(b""));

        update_service(acct, string::utf8(b"google"), string::utf8(b"mail_google"), string::utf8(b"mail.google.com"), string::utf8(b""));
        let service_aggr = borrow_global_mut<ServiceAggregator>(signer::address_of(acct));
        let service = table::borrow_mut(&mut service_aggr.services_map, string::utf8(b"google"));
        assert!(service.description == string::utf8(b"mail_google"), 603);
    }

    #[test(acct = @0x123)]
    public entry fun test_delete_service(acct: &signer) acquires ServiceAggregator{
        account::create_account_for_test(signer::address_of(acct));
        create_service_aggregator(acct);
        add_service(acct, string::utf8(b"google"), string::utf8(b"www.google.com"), string::utf8(b"google"), string::utf8(b""));

        delete_service(acct,string::utf8(b"google"));
        let service_aggr = borrow_global_mut<ServiceAggregator>(signer::address_of(acct));
        assert!(table::contains(&mut service_aggr.services_map, string::utf8(b"google")) == false, 604);
    }


}


