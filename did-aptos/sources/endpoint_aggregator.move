module my_addr::endpoint_aggregator {
    use std::signer;
    use std::vector;
    use std::string::{String};
    use std::table::{Self, Table};

    const ERR_ENDPOINT_PARAM_VECTOR_LENGHT_MISMATCH: u64 = 5000;

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

    public entry fun batch_add_endpoint(
        acct: &signer,
        names: vector<String>,
        endpoints : vector<Endpoint>
    ) acquires EndpointAggregator {

        let names_length = vector::length(&names);
        let endpoints_length = vector::length(&endpoints);
        assert!(names_length == endpoints_length, ERR_ENDPOINT_PARAM_VECTOR_LENGHT_MISMATCH);

        let endpoint_aggr = borrow_global_mut<EndpointAggregator>(signer::address_of(acct));

        let i = 0;
        while (i < names_length) {
            let name = vector::borrow<String>(&names, i);
            let endpoint = vector::borrow<Endpoint>(&endpoints, i);

            table::add(&mut endpoint_aggr.endpoints_map, *name, *endpoint);
            vector::push_back(&mut endpoint_aggr.names, *name);

            i = i + 1;
        };
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
