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
    const COLLECTION_URI: vector<u8> = b"18FHdw2SH3ihFeqIQMIAJVkHwOsZkF23rRM7-Fk2yKw";

    const BASE_URI: vector<u8> = b"https://arweave.net/";
    const TOKEN_URI_0: vector<u8> = b"ZLH6DsQn-dzjdB-j9xE6Pf9WskH3AUvUejMkQQdLiqY";
    const TOKEN_URI_1: vector<u8> = b"nrYdR5UThi2_nMb0rNPfGKyb6rF4RV0ffs1saY6TUGg";
    const TOKEN_URI_2: vector<u8> = b"eW9C2_JBIz_ZgYT53ck3dII-hGP5RetZR8LDckdRwGk";
    const TOKEN_URI_3: vector<u8> = b"Jn-4GulYbugg6Dr96FRbz813dY3B1hhMuSvylmvJKkA";

    const PREFIX: vector<u8> = b"MoveDID ";

    const ENOT_VALID_TYPE: u64 = 0;
    
    //:!:>resource
    struct GlobalState has key, store {
        count_0: u64,
        count_1: u64,
        count_2: u64,
        count_3: u64,
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
        type: u64,
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
            count_0: 0,
            count_1: 0,
            count_2: 0,
            count_3: 0,
            signer_cap
        });

        let collection_uri = vector::empty<u8>();
        vector::append(&mut collection_uri, BASE_URI);
        vector::append(&mut collection_uri, COLLECTION_URI);

        // Create log and plank collection to the resource account
        collection::create_unlimited_collection(
            &resource_account,
            string::utf8(COLLECTION_DESCRIPTION),
            string::utf8(COLLECTION_NAME),
            option::none(),
            string::utf8(collection_uri),
        );

    }

    // Combine addr_aggregator and service_aggregator init.
    public entry fun init(acct: &signer, type: u64, description: String) acquires CreateDIDEventSet, GlobalState {
        addr_aggregator::create_addr_aggregator(acct, type, description);
        service_aggregator::create_service_aggregator(acct);

        let global_state = borrow_global_mut<GlobalState>(@my_addr);
        let resource_signer = account::create_signer_with_capability(&global_state.signer_cap);

        let vc_obj: Object<VerifiableCredential>;
 
        let count: u64;
        if(type == 0){
            vc_obj = mint_vc(&resource_signer, global_state.count_0, type);
            count = global_state.count_0;
            global_state.count_0 = global_state.count_0 + 1;
        }else if(type == 1){
            vc_obj = mint_vc(&resource_signer, global_state.count_1, type);
            count = global_state.count_1;
            global_state.count_1 = global_state.count_1 + 1;
        }else if(type == 2){
            vc_obj = mint_vc(&resource_signer, global_state.count_2, type);
            count = global_state.count_2;
            global_state.count_2 = global_state.count_2 + 1;
        }else if(type == 3){
            vc_obj = mint_vc(&resource_signer, global_state.count_3, type);
            count = global_state.count_3;
            global_state.count_3 = global_state.count_3 + 1;
        }else{
            abort ENOT_VALID_TYPE
        };

        let create_did_event = CreateDIDEvent {
            key_addr: signer::address_of(acct),
            type, 
            count,
        };

        event::emit_event<CreateDIDEvent>(
            &mut borrow_global_mut<CreateDIDEventSet>(@my_addr).create_did_events,
            create_did_event,
        );

        object::transfer(&resource_signer, vc_obj, signer::address_of(acct));
    }

    public fun uri(type: u64): vector<u8>{

        let uri = vector::empty<u8>();
        vector::append(&mut uri, BASE_URI);
        if(type == 0){
            vector::append(&mut uri, TOKEN_URI_0);
            uri
        }else if(type == 1){
            vector::append(&mut uri, TOKEN_URI_1);
            uri
        }else if(type == 2){
            vector::append(&mut uri, TOKEN_URI_2);
            uri
        }else if(type == 3){
            vector::append(&mut uri, TOKEN_URI_3);
            uri
        }else{
            abort ENOT_VALID_TYPE
        }

    }

    public fun create_token(creator: &signer, unique_id: u64, type: u64): ConstructorRef {
        let name = vector::empty<u8>();
        vector::append(&mut name, PREFIX);
        if(type == 0){
            vector::append(&mut name, b"Human");
        }else if(type == 1){
            vector::append(&mut name, b"Org");
        }else if(type == 2){
            vector::append(&mut name, b"AI Agent");
        }else if(type == 3){
            vector::append(&mut name, b"Smart Contract");
        }
        vector::append(&mut name, b" #");
        vector::append(&mut name, utils::u64_to_vec_u8_string(unique_id));
        
        let token_uri = uri(type);

        token::create_named_token(
            creator,
            string::utf8(COLLECTION_NAME),
            string::utf8(TOKEN_DESCRIPTION),
            string::utf8(name),
            option::none(),
            string::utf8(token_uri),
        )
    }

    public fun mint_vc(
        creator: &signer,
        unique_id: u64,
        type: u64,
    ): Object<VerifiableCredential> {

        let constructor_ref = create_token(creator, unique_id, type);
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

        property_map::add_typed(
            &property_mutator_ref,
            string::utf8(b"creator"),
            signer::address_of(creator),
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
    public fun get_count(type: u64): u64 acquires GlobalState {
        if(type == 0){
            borrow_global<GlobalState>(@my_addr).count_0
        }else if(type == 1){
            borrow_global<GlobalState>(@my_addr).count_1
        }else if(type == 2){
            borrow_global<GlobalState>(@my_addr).count_2
        }else if(type == 3){
            borrow_global<GlobalState>(@my_addr).count_3
        }else{
            abort ENOT_VALID_TYPE
        }
    }
}


