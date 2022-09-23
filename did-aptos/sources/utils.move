module my_addr::utils {
    use std::vector;

    public fun u64_to_vec_u8(val : u64) : vector<u8> {
        let result = vector::empty<u8>();
        
        while(val > 0) {
            let d  = val / 256;
            if (d > 0) {
                vector::push_back(&mut result, (d as u8));
            } else {
                let m = val % 256;
                vector::push_back(&mut result, (m as u8));
                break
            };
            val = val / 256;
        };
        
        result
    } 
}