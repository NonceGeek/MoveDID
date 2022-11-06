module my_addr::endpoint_aggregator {
    use std::signer;
    use std::vector;
    use std::string::{String};

    struct Endpoint has store, copy, drop {
        url: String,
        description: String,
        msg: String,
        verification_url: String
    }

    struct EndpointAggregator has key {
        key_addr: address,
        endpoints: vector<Endpoint>
    }

    public entry fun create_endpoint_aggregator(acct: &signer) {
        let endpoint_aggr = EndpointAggregator {
            key_addr: signer::address_of(acct),
            endpoints: vector::empty<Endpoint>()
        };
        move_to<EndpointAggregator>(acct, endpoint_aggr);
    }

    public entry fun add_endpoint(
        acct: &signer,
        url: String,
        description: String,
        msg: String,
        verification_url: String
    ) acquires EndpointAggregator {
        let endpoint_aggr = borrow_global_mut<EndpointAggregator>(signer::address_of(acct));
        let endpoint_info = Endpoint {
            url: url,
            description: description,
            msg: msg,
            verification_url: verification_url
        };
        vector::push_back(&mut endpoint_aggr.endpoints, endpoint_info);
    }

    // public entry fun update endpoint with params
    public entry fun update_endpoint(
        acct: &signer,
        url: String,
        new_description: String,
        new_url: String,
        new_msg: String,
        new_verification_url: String
    ) acquires EndpointAggregator {
        let endpoint_aggr = borrow_global_mut<EndpointAggregator>(signer::address_of(acct));
        let length = vector::length(&mut endpoint_aggr.endpoints);
        let i = 0;
        while (i < length) {
            let endpoint = vector::borrow_mut<Endpoint>(&mut endpoint_aggr.endpoints, i);
            if (endpoint.url == url) {
                endpoint.url = new_url;
                endpoint.description = new_description;
                endpoint.msg = new_msg;
                endpoint.verification_url = new_verification_url;
                break
            };
            i = i + 1;
        };
    }

    // public entry fun delete endpoint
    public entry fun delete_endpoint(
        acct: &signer,
        url: String) acquires EndpointAggregator {
        let endpoint_aggr = borrow_global_mut<EndpointAggregator>(signer::address_of(acct));
        let length = vector::length(&mut endpoint_aggr.endpoints);
        let i = 0;
        while (i < length) {
            let endpoint = vector::borrow(&mut endpoint_aggr.endpoints, i);
            if (endpoint.url == url) {
                vector::remove(&mut endpoint_aggr.endpoints, i);
                break
            };
            i = i + 1;
        };
    }
}
