spec my_addr::service_aggregator {
    spec module {
        pragma verify = true;
        pragma aborts_if_is_strict;
    }

    spec create_service_aggregator {
        pragma aborts_if_is_partial;
        let addr = signer::address_of(acct);
        aborts_if exists<ServiceAggregator>(addr);
    }

    spec add_service {
        let addr = signer::address_of(acct);
        let pre_service_aggr = global<ServiceAggregator>(addr);
        aborts_if !exists<ServiceAggregator>(addr);
        aborts_if std::table::spec_contains(pre_service_aggr.services_map,name) == true;
        let post service_aggr = global<ServiceAggregator>(addr);
        ensures contains(service_aggr.names,name);
        ensures std::table::spec_contains(service_aggr.services_map,name) == true;
    }

    // spec batch_add_services {
    //     pragma aborts_if_is_partial;
    //     aborts_if len(names) != len(services);
    // }

    spec update_service {
        let addr = signer::address_of(acct);
        aborts_if !exists<ServiceAggregator>(addr);
        let service_aggr = global<ServiceAggregator>(addr);
        aborts_if !std::table::spec_contains(service_aggr.services_map,name);
    }

    spec delete_service {
        let addr = signer::address_of(acct);
        aborts_if !exists<ServiceAggregator>(addr);
        aborts_if !std::table::spec_contains(pre_service_aggr.services_map,name);
        let pre_service_aggr = global<ServiceAggregator>(addr);
        let post service_aggr = global<ServiceAggregator>(addr);
        ensures std::table::spec_contains(service_aggr.services_map,name) == false;
    }
}
