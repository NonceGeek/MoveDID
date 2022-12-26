spec my_addr::endpoint_aggregator {
    spec module {
        pragma verify = true;
        pragma aborts_if_is_strict;
    }

    spec create_endpoint_aggregator {
        pragma aborts_if_is_partial;
        let addr = signer::address_of(acct);
        aborts_if exists<EndpointAggregator>(addr);
    }

    spec add_endpoint {
        let addr = signer::address_of(acct);
        let pre_endpoint_aggr = global<EndpointAggregator>(addr);
        aborts_if !exists<EndpointAggregator>(addr);
        aborts_if std::table::spec_contains(pre_endpoint_aggr.endpoints_map,name) == true;
        let post endpoint_aggr = global<EndpointAggregator>(addr);
        ensures contains(endpoint_aggr.names,name);
        ensures std::table::spec_contains(endpoint_aggr.endpoints_map,name) == true;
    }

    spec batch_add_endpoints {
        pragma aborts_if_is_partial;
        aborts_if len(names) != len(endpoints);
    }

    spec update_endpoint {
        let addr = signer::address_of(acct);
        aborts_if !exists<EndpointAggregator>(addr);
        let endpoint_aggr = global<EndpointAggregator>(addr);
        aborts_if !std::table::spec_contains(endpoint_aggr.endpoints_map,name);
    }

    spec delete_endpoint {
        let addr = signer::address_of(acct);
        aborts_if !exists<EndpointAggregator>(addr);
        aborts_if !std::table::spec_contains(pre_endpoint_aggr.endpoints_map,name);
        let pre_endpoint_aggr = global<EndpointAggregator>(addr);
        let post endpoint_aggr = global<EndpointAggregator>(addr);
        ensures std::table::spec_contains(endpoint_aggr.endpoints_map,name) == false;
    }
}
