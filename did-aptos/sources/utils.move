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





   // vector<u8> transfter to timestamp 
   public fun vec_to_timestamp(timestamp_vec: vector<u8>): u64{
         let prev_time  = 0;
         let prev_time_length = vector::length(&timestamp_vec);
         if (prev_time_length != 10) {
            abort 1002
         };
         let i=0;
         while (i < prev_time_length) {
            let char = vector::borrow(&mut timestamp_vec, i);
            if (*char >= 48 && *char <= 57) {
               prev_time = prev_time*10 + ((*char - 48) as u64);
            };
            i = i+1;
         };
         prev_time
   }

 
}