module my_addr::endpoint_aggregator_v5 {
   use aptos_framework::signer;
   use std::vector;

   struct Endpoint has store, copy, drop {
      url: vector<u8>,
      description: vector<u8>
   }

   struct EndpointAggregator has key {
      key_addr: address,
      endpoints: vector<Endpoint>
   }

   public fun create_endpoint_aggregator(acct: &signer){
      let endpoint_aggr =  EndpointAggregator{
         key_addr: signer::address_of(acct),
         endpoints: vector::empty<Endpoint>()
      };
      move_to<EndpointAggregator>(acct, endpoint_aggr);
   }

   public fun add_endpoint(
      acct: &signer, 
      url: vector<u8>, 
      description: vector<u8>) acquires EndpointAggregator{
        let endpoint_aggr = borrow_global_mut<EndpointAggregator>(signer::address_of(acct));
        let endpoint_info = Endpoint{
            url: url, 
            description: description
        };
      vector::push_back(&mut endpoint_aggr.endpoints, endpoint_info);
   }

   // public fun update endpoint with description, url
   public fun update_endpoint_with_description_and_url(
      acct: &signer,
      url: vector<u8>,
      new_description: vector<u8>,
      new_url: vector<u8>) acquires EndpointAggregator {
      let endpoint_aggr = borrow_global_mut<EndpointAggregator>(signer::address_of(acct));
      let length = vector::length(&mut endpoint_aggr.endpoints);
      let i = 0;
      while (i < length) {
         let endpoint = vector::borrow_mut<Endpoint>(&mut endpoint_aggr.endpoints, i);
         if (*&endpoint.url == *&url) {
            endpoint.url = new_url;
            endpoint.description = new_description;
            break
         };
         i = i + 1;
      };
   }

   // public fun delete endpoint
   public fun delete_endpoint(
      acct: &signer,  
      url: vector<u8>) acquires EndpointAggregator {
      let endpoint_aggr = borrow_global_mut<EndpointAggregator>(signer::address_of(acct));
      let length = vector::length(&mut endpoint_aggr.endpoints);
      let i = 0;
      while (i < length) {
         let endpoint = vector::borrow(&mut endpoint_aggr.endpoints, i);
         if (*&endpoint.url == *&url) {
            vector::remove(&mut endpoint_aggr.endpoints, i);
         };
         i = i + 1;
      };
   }
   /* --- scripts --- */
}
