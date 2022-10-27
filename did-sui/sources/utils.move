module my_addr::utils {
    use std::vector;
    use std::string::{Self, String};
    // #[test_only]
    // use std::debug;

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

    public fun u64_to_vec_u8_string(val : u64) : vector<u8> {
      let result = vector::empty<u8>();

      if (val == 0) {
         return b"0"
      };
     
      while (val != 0) {
         vector::push_back(&mut result, ((48 + val % 10) as u8));
         val = val / 10;
      };

      vector::reverse(&mut result);
      
      result
   } 

   public fun ascii_u8_to_number(u : u8) : u8 {
        assert!((u >= 48 && u <=57)||(u >= 65 && u <= 70 ) || (u >= 97 && u <= 102), 3005);
        let byte = 0;
        if (u >= 48 && u <=57) {
            byte = u - 48;
            return byte
        };

        if (u >= 65 && u <= 70 ) {
            byte = u - 65 + 10; 
            return byte
        };

        if (u >= 97 && u <= 102) {
            byte = u - 97 + 10; 
            return byte
        };

        byte
   }

   // transfer string to vector u8 bytes
   public fun string_to_vector_u8(str : &String) : vector<u8> {
        assert!(string::length(str) % 2 == 0, 3003);
        let vec = string::bytes(str);

        let result = vector::empty<u8>();
        let i = 0;
        while(i < vector::length(vec)) {
            let h = *vector::borrow(vec, i);
            h = ascii_u8_to_number(h);
            i = i + 1;

            let l = *vector::borrow(vec, i);
            l = ascii_u8_to_number(l);
            
            let u = h * 16 + l;
            // debug::print(&u);
            i = i + 1;
            vector::push_back(&mut result, u);
        };

        // let result_length = vector::length(&result);
        //  debug::print(&result_length);

        result
   }
}