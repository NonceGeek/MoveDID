spec my_addr::eth_sig_verifier {
    spec module {
        pragma verify = true;
        pragma aborts_if_is_strict;
    }

    spec pubkey_to_address {
        pragma verify = false;
    }

    spec verify_eth_sig {
        pragma aborts_if_is_partial;
        aborts_if len(signature) != 65;
        let recovery_byte = vector::borrow(signature,len(signature) - 1);
        aborts_if recovery_byte != 27 && recovery_byte != 28;
    }
}
