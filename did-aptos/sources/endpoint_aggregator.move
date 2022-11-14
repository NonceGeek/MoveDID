module my_addr::endpoint_aggregator {
    use std::signer;
    use std::vector;
    use std::string::{String};
    use std::table::{Self, Table};

    struct Endpoint has store, copy, drop {
        url: String,
        description: String,
        verification_url: String
    }

    struct EndpointAggregator has key {
        key_addr: address,
        endpoints_map:Table<String, Endpoint>,
        names: vector<String>,
    }

    public entry fun create_endpoint_aggregator(acct: &signer) {
        let endpoint_aggr = EndpointAggregator {
            key_addr: signer::address_of(acct),
            endpoints_map: table::new(),
            names: vector::empty<String>(),
        };
        move_to<EndpointAggregator>(acct, endpoint_aggr);
    }

    public entry fun add_endpoint(
        acct: &signer,
        name: String,
        url: String,
        description: String,
        verification_url: String
    ) acquires EndpointAggregator {
        let endpoint_aggr = borrow_global_mut<EndpointAggregator>(signer::address_of(acct));
        let endpoint_info = Endpoint {
            url,
            description,
            verification_url
        };

        table::add(&mut endpoint_aggr.endpoints_map, name, endpoint_info);
        vector::push_back(&mut endpoint_aggr.names, name);
    }

    // public entry fun update endpoint with params
    public entry fun update_endpoint(
        acct: &signer,
        name: String,
        new_description: String,
        new_url: String,
        new_verification_url: String
    ) acquires EndpointAggregator {
        let endpoint_aggr = borrow_global_mut<EndpointAggregator>(signer::address_of(acct));
        let endpoint = table::borrow_mut(&mut endpoint_aggr.endpoints_map, name);

        endpoint.url = new_url;
        endpoint.description = new_description;
        endpoint.verification_url = new_verification_url;
    }

    // public entry fun delete endpoint
    public entry fun delete_endpoint(
        acct: &signer,
        name: String) acquires EndpointAggregator {
        let endpoint_aggr = borrow_global_mut<EndpointAggregator>(signer::address_of(acct));
        table::remove(&mut endpoint_aggr.endpoints_map, name);

        let length = vector::length(&endpoint_aggr.names);
        let i = 0;
        while (i < length) {
            let current_name = vector::borrow<String>(&endpoint_aggr.names, i);
            if (*current_name == name) {
                vector::remove(&mut endpoint_aggr.names, i);
                break
            };
            i = i + 1;
        };
    }
}
