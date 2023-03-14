spec my_addr::addr_info {
    spec module {
        pragma verify = true;
    }

    /// BlockResource should under the @aptos_framework.
    /// CurrentTimeMicroseconds should under the @aptos_framework.
    spec init_addr_info(send_addr : address, id: u64, addr_type: u64, addr: String, pubkey: String, chains: &vector<String>, description: String, expire_second : u64): AddrInfo {
        ensures exists<block::BlockResource>(@aptos_framework);
        ensures exists<timestamp::CurrentTimeMicroseconds>(@aptos_framework);
        }

    /// The addr has 0x as it's prefix.
    spec check_addr_prefix(addr: String) {
        let l = len(addr.bytes);
        aborts_if string::spec_internal_sub_string(addr.bytes, 0, 2) != (b"0x");
        aborts_if 2 > l || !string::spec_internal_is_char_boundary(addr.bytes, 0) || !string::spec_internal_is_char_boundary(addr.bytes, 2);
        aborts_if !string::spec_internal_check_utf8(b"0x");
    }

    spec schema CheckAddrPrefix {
        addr: String;
        ensures string::spec_internal_sub_string(addr.bytes, 0, 2) == (b"0x");
    }

    /// The signature under the addr_info should not be empty.
    /// BlockResource should under the @aptos_framework.
    spec update_addr_info_with_chains_and_description(addr_info: &mut AddrInfo, chains: vector<String>, description: String) {
        ensures len(addr_info.signature) != 0;
        ensures exists<block::BlockResource>(@aptos_framework);
    }

    /// The signature under the addr_info should be empty.
    /// BlockResource should under the @aptos_framework.
    spec update_addr_info_for_non_verification(addr_info: &mut AddrInfo, chains: vector<String>, description: String) {
        aborts_if len(addr_info.signature) != 0;
        aborts_if !exists<timestamp::CurrentTimeMicroseconds>(@aptos_framework);
    }

    spec schema UpdateAddrForNonVerify {
        addr_info: AddrInfo;

        ensures len(addr_info.signature) == 0;
        ensures exists<timestamp::CurrentTimeMicroseconds>(@aptos_framework);
    }
}
