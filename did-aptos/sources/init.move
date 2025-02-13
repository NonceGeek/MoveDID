module my_addr::init {
    use std::signer;
    use std::string::{Self, String};
    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::account::{Self, SignerCapability};
    use std::option;
    use std::vector;

    use aptos_token_objects::collection;
    use aptos_token_objects::token;
    use aptos_token_objects::property_map;

    use my_addr::addr_aggregator;
    use my_addr::service_aggregator;
    use my_addr::utils;

    use aptos_framework::object::{Self, ConstructorRef, Object};

    const STATE_SEED: vector<u8> = b"movedid_signer";
    const COLLECTION_NAME: vector<u8> = b"MoveDID";
    const COLLECTION_DESCRIPTION: vector<u8> = b"Verifiable Credential Collection for MoveDID Owner!";
    const TOKEN_DESCRIPTION: vector<u8> = b"MoveDID Verifiable Credential";
    const COLLECTION_URI: vector<u8> = b"https://rootmud.xyz";
    const TOKEN_URI: vector<u8> = b"https://arweave.net/7xopmyHOuhNtH2UXomaCt8m3FK42EzJ8Fb8MuGtXU58";
    const PREFIX: vector<u8> = b"MoveDID #";
    
    //:!:>resource
    struct GlobalState has key, store {
        count: u64,
        signer_cap: SignerCapability,
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct VerifiableCredential has key {
        addr: address,
        mutator_ref: token::MutatorRef, 
        property_mutator_ref: property_map::MutatorRef, 
    }

    //<:!:resource

    //:!:>events
    struct CreateDIDEvent has drop, store {
        key_addr: address,
        count: u64,
    }

    struct CreateDIDEventSet has key, store {
        create_did_events: EventHandle<CreateDIDEvent>
    }


    // This is only callable during publishing.
    fun init_module(account: &signer) {

        move_to(account, CreateDIDEventSet {
            create_did_events: account::new_event_handle<CreateDIDEvent>(account),
        });

        let (resource_account, signer_cap) = account::create_resource_account(account, STATE_SEED);

        move_to(account, GlobalState {
            count: 0,
            signer_cap
        });

        // Create log and plank collection to the resource account
        collection::create_unlimited_collection(
            &resource_account,
            string::utf8(COLLECTION_DESCRIPTION),
            string::utf8(COLLECTION_NAME),
            option::none(),
            string::utf8(COLLECTION_URI),
        );

    }

    // Combine addr_aggregator and service_aggregator init.
    public entry fun init(acct: &signer, type: u64, description: String) acquires CreateDIDEventSet, GlobalState {
        addr_aggregator::create_addr_aggregator(acct, type, description);
        service_aggregator::create_service_aggregator(acct);

        let create_did_event = CreateDIDEvent {
            key_addr: signer::address_of(acct),
            count: borrow_global<GlobalState>(@my_addr).count,
        };
        event::emit_event<CreateDIDEvent>(
            &mut borrow_global_mut<CreateDIDEventSet>(@my_addr).create_did_events,
            create_did_event,
        );

        let global_state = borrow_global_mut<GlobalState>(@my_addr);
        let resource_signer = account::create_signer_with_capability(&global_state.signer_cap);
        let vc_obj = mint_vc(&resource_signer, global_state.count, type);
        object::transfer(&resource_signer, vc_obj, signer::address_of(acct));

        global_state.count = global_state.count + 1;
    }

    public fun create_token(creator: &signer, unique_id: u64): ConstructorRef {
        
        let origin = vector::empty<u8>();
        vector::append(&mut origin, PREFIX);
        vector::append(&mut origin, utils::u64_to_vec_u8_string(unique_id));
        
        token::create_named_token(
            creator,
            string::utf8(COLLECTION_NAME),
            string::utf8(TOKEN_DESCRIPTION),
            string::utf8(origin),
            option::none(),
            string::utf8(TOKEN_URI),
        )
    }

    public fun mint_vc(
        creator: &signer,
        unique_id: u64,
        type: u64,
    ): Object<VerifiableCredential> {

        let constructor_ref = create_token(creator, unique_id);
        let token_signer = object::generate_signer(&constructor_ref);

        // <-- create properties
        let property_mutator_ref = property_map::generate_mutator_ref(&constructor_ref); 
        let properties = property_map::prepare_input(vector[], vector[], vector[]);

        property_map::init(&constructor_ref, properties);

        property_map::add_typed(
            &property_mutator_ref,
            string::utf8(b"unique_id"),
            unique_id,
        );

        property_map::add_typed(
            &property_mutator_ref,
            string::utf8(b"type"),
            type,
        );
        // create properties -->

        let vc = VerifiableCredential {
            addr: signer::address_of(creator),
            mutator_ref: token::generate_mutator_ref(&constructor_ref),
            property_mutator_ref,
        };

        move_to(&token_signer, vc);

        object::address_to_object(signer::address_of(&token_signer))

    }

    #[view]
    public fun get_count(): u64 acquires GlobalState {
        borrow_global<GlobalState>(@my_addr).count
    }
}


