module my_addr::utils {
    use std::vector;
    use std::string::{Self, String};
    use std::bcs;
    #[test_only]
    use std::debug;

    const ERR_INVALID_ASCII_CHAR: u64 = 3000;
    const ERR_STRING_LENGTH_INVALID: u64 = 3001;

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
        assert!((u >= 48 && u <=57)||(u >= 65 && u <= 70 ) || (u >= 97 && u <= 102), ERR_INVALID_ASCII_CHAR);
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



   // Transfer string to vector u8 bytes.
   public fun string_to_vector_u8(str : &String) : vector<u8> {
        assert!(string::length(str) % 2 == 0, ERR_STRING_LENGTH_INVALID);
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

        result
   }

    // Trim pos chars and transfer string to vector u8 bytes.
    public fun trim_string_to_vector_u8(str : &String, pos: u64) :  vector<u8>{

        let s = string::sub_string(str, pos, string::length(str));
        string_to_vector_u8(&s)
    }

    // Address to u64.
    public fun address_to_u64(address : address) : u64 {
        let vec = bcs::to_bytes(&address);

        let result = 0u64;
        let i = 0;
        while(i < vector::length(&vec)) {
            let h = *vector::borrow(&vec, i);
            result = result * 16 + (h as u64);
            i = i+1;
        };
        result
    }

    // Translate Address to as
    public fun address_to_ascii_u8_vec(address : address) : vector<u8> {
        let vec = bcs::to_bytes(&address);

        // let result = 0u64;
        // let vec =
        let result = vector::empty<u8>();
        // debug::print(&vec);
        // debug::print(&vector::length(&vec));

        let i = 0;
        while(i < vector::length(&vec)) {
            let h = *vector::borrow(&vec, i);
            let h_high = h / 16;
            h_high = h_high + 48;
            vector::push_back(&mut result, h_high);

            let h_low = h % 16;
            h_low = h_low + 48;
            vector::push_back(&mut result, h_low);

            i = i+1;
        };
        result
    }



    // #[test_only]
    // use aptos_std::debug;
    #[test_only]
    use aptos_std::from_bcs;

    #[test]
    fun test_address() {

        let addr_vec = x"0000000000000000000000000000000000000000000000000000000000000101";

        // let str = string::utf8(addr_vec);
        let addr_out = from_bcs::to_address(addr_vec);

        let result  = address_to_u64(addr_out);
        debug::print(&result)
    }
}

