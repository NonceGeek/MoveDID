module MyAddr::Utils {
    use StarcoinFramework::Vector;

    //split string by char 
   public fun split_string_by_char(v: &vector<u8>, ch: u8) :  vector<vector<u8>> {
      let result = Vector::empty<vector<u8>>();

      // let len = Vector::length(&string.bytes); 
      let len = Vector::length(v);
      let i = 0; 
      // let flag = false;
      let buffer = Vector::empty<u8>();
      while ( i < len ) {
         let byte = *Vector::borrow(v, i);
         if (byte != ch) {
            Vector::push_back(&mut buffer, byte);
         } else {
            Vector::push_back(&mut result, buffer);
            buffer = Vector::empty<u8>();
         };
         
         i = i+1; 
      };
      if (Vector::length(&buffer) != 0) {
         Vector::push_back(&mut result, buffer);
      }; 

      result
   }

   // vector<u8> transfter to timestamp 
   public fun vec_to_timestamp(timestamp_vec: vector<u8>): u64{
         let prev_time  = 0;
         let prev_time_length = Vector::length(&timestamp_vec);
         if (prev_time_length != 10) {
            abort 1002
         };
         let i=0;
         while (i < prev_time_length) {
            let char = Vector::borrow(&mut timestamp_vec, i);
            if (*char >= 48 && *char <= 57) {
               prev_time = prev_time*10 + ((*char - 48) as u64);
            };
            i = i+1;
         };
         prev_time
   }

    #[test]
    public fun split_string_by_char_test(){
        let origin = b"a_b_c";
        Debug::print(&origin);
        let result = Utils::split_string_by_char(&mut origin, 0x5f); // _ ansci is 0x5f
        Debug::print(&result);
        assert!(Vector::length(&mut result) == 3, 101);

        let origin = b"a_b_";
        Debug::print(&origin);
        let result = Utils::split_string_by_char(&mut origin, 0x5f); // _ ansci is 0x5f
        Debug::print(&result);
        assert!(Vector::length(&mut result) == 2, 101);

        let origin = b"a";
        Debug::print(&origin);
        let result = Utils::split_string_by_char(&mut origin, 0x5f); // _ ansci is 0x5f
        Debug::print(&result);
        assert!(Vector::length(&mut result) == 1, 101);
    }

   #[test]
   public fun vec_to_timestamp_test() {
      let ts_str = b"1661049255";
      // let length = Vector::length(&ts_str);
      Debug::print(&ts_str);
      
      let expected_ts = 1661049255;
      let real_ts = vec_to_timestamp(ts_str);
      Debug::print(&real_ts);
      assert!( real_ts==expected_ts,  110);
   }
}