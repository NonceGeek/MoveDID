spec my_addr::utils {
    spec module {
        pragma verify = true;
        pragma aborts_if_is_strict;

    }

    spec u64_to_vec_u8 {
        pragma verify = false;
    }

    spec ascii_u8_to_number {
        aborts_if (u >= 0 && u <48) || (u >= 58 && u < 65) || (u >= 71 && u < 97) || (u > 102);
    }

    spec string_to_vector_u8 {
        pragma verify = false;
    }

    spec trim_string_to_vector_u8 {
        pragma verify = false;
    }

    spec address_to_u64 {
        pragma verify = false;
    }
}
