spec my_addr::addr_aggregator {
    spec module {
        pragma verify = true;
    }

    /// AddrAggregatord shouldn't under the signer befroe creating it.
    /// Make sure the AddrAggregatord exists under the signer after creating it.
    spec create_addr_aggregator(acct: &signer, type: u64, description: String) {
        let addr = signer::address_of(acct);
        aborts_if exists<AddrAggregator>(addr);
        ensures exists<AddrAggregator>(addr);
    }

    spec update_addr_aggregator_description(acct: &signer, description: String) {
        aborts_if !exists<AddrAggregator>(signer::address_of(acct));
    }

    /// The addr has 0x as it's prefix.
    /// The AddrAggregatord should under the signer.
    /// Check addr_info is already exist under the addr.
    /// Max id should not exceed MAX_U64.
    /// The max_id should plus 1.
    spec add_addr{
        include addr_info::CheckAddrPrefix;
        let account = signer::address_of(acct);
        let addr_aggr = global<AddrAggregator>(account);
        let post addr_aggr_post = global<AddrAggregator>(account);
        ensures !spec_exist_addr_by_map(addr_aggr.addr_infos_map, addr);
        ensures spec_exist_addr_by_map(addr_aggr_post.addr_infos_map,addr);
        ensures contains(addr_aggr_post.addrs, addr);
        ensures addr_aggr.max_id + 1 <= MAX_U64;
        ensures addr_aggr_post.max_id == addr_aggr.max_id + 1;
    }

    spec fun spec_exist_addr_by_map (addr_infos_map: Table<String, AddrInfo>, addr: String): bool {
        table::spec_contains(addr_infos_map, addr)
    }

    /// The number of 'addr' added should same as the number of 'addrinfo'.
    /// The AddrAggregatord should under the signer.
    /// The value of max_id after batch_add_addr should plus the number of the addresses.
    spec  batch_add_addr(
        acct: &signer,
        addrs: vector<String>,
        addr_infos : vector<AddrInfo>
    ) {
        let addrs_length = len(addrs);
        let old_addr_aggr = global<AddrAggregator>(signer::address_of(acct));
        let post addr_aggr = global<AddrAggregator>(signer::address_of(acct));
        ensures len(addrs) == len(addr_infos);
        ensures addr_aggr.max_id == old_addr_aggr.max_id + addrs_length;
    }

    /// The addr has 0x as it's prefix.
    /// The AddrAggregatord should under the signer.
    spec update_eth_addr(acct: &signer, addr: String, signature: String) {
        include addr_info::CheckAddrPrefix;
        let addr_aggr = global<AddrAggregator>(signer::address_of(acct));
        let addr_info = table::spec_get(addr_aggr.addr_infos_map, addr);
        include addr_eth::UpdateAddr{addr_info};
    }

    /// The addr has 0x as it's prefix.
    /// The AddrAggregatord should under the signer.
    spec update_aptos_addr(acct: &signer, addr: String, signature: String) {
        include addr_info::CheckAddrPrefix;
        let addr_aggr = global<AddrAggregator>(signer::address_of(acct));
        let addr_info = table::spec_get(addr_aggr.addr_infos_map, addr);
        include addr_aptos::UpdateAddr{addr_info};
    }

    /// The addr has 0x as it's prefix.
    /// The AddrAggregatord is under the signer.
    /// The length of signature should not same as 0.
    spec update_addr_msg_with_chains_and_description(acct: &signer, addr: String, chains: vector<String>, description: String) {
        include addr_info::CheckAddrPrefix;
        let addr_aggr = global<AddrAggregator>(signer::address_of(acct));
        let addr_info = table::spec_get(addr_aggr.addr_infos_map, addr);
        ensures len(addr_info.signature) != 0;
        }

    /// The addr has 0x as it's prefix.
    /// The AddrAggregatord should under the signer.
    spec update_addr_for_non_verify(acct: &signer, addr: String, chains: vector<String>, description: String) {
        include addr_info::CheckAddrPrefix;
        let addr_aggr = global<AddrAggregator>(signer::address_of(acct));
        let addr_info = table::spec_get(addr_aggr.addr_infos_map, addr);
        include addr_info::UpdateAddrForNonVerify{addr_info};
        }

    /// The addr has 0x as it's prefix.
    /// The AddrAggregatord should under the signer.
    /// The addr should not in the addr_infos_map after deleting.
    spec delete_addr(acct: &signer, addr: String) {
        include addr_info::CheckAddrPrefix;
        let addr_aggr = global<AddrAggregator>(signer::address_of(acct));
        let length = len(addr_aggr.addrs);
        let post addr_aggr_post = global<AddrAggregator>(signer::address_of(acct));
        ensures !table::spec_contains(addr_aggr_post.addr_infos_map, addr);
    }
}
