spec my_addr::addr_aptos {
    spec module {
        pragma verify = true;
    }

    /// The msg should not be etmpy.
    /// The length of addr under the addr_info should same as APTOS_ADDR_LENGTH + 2.
    /// The addr_type should under the addr_info is ADDR_TYPE_APTOS.
    /// The now - created_at should not exceed 2h.
    spec update_addr(addr_info: &mut AddrInfo, signature: &mut String) {
        pragma aborts_if_is_partial;
        aborts_if addr_info.msg.bytes == (b"");
        aborts_if len(addr_info.addr.bytes) != APTOS_ADDR_LENGTH + 2;
        aborts_if addr_info.addr_type != ADDR_TYPE_APTOS;
        let now = timestamp::spec_now_seconds();
        aborts_if (now - addr_info.created_at) > 2 * 60 * 60;
    }

    spec schema UpdateAddr {
        addr_info: AddrInfo;
        ensures addr_info.msg.bytes != (b"");
        ensures len(addr_info.addr.bytes) == APTOS_ADDR_LENGTH + 2;
        ensures addr_info.addr_type == ADDR_TYPE_APTOS;
        let now = timestamp::spec_now_seconds();
        ensures (now - addr_info.created_at) <= 2 * 60 * 60;
    }
}
