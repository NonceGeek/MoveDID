module my_addr::endpoint_aggregator {
   use std::vector;
   use std::string::{String};
   use sui::object::{Self, UID};
   use sui::tx_context::{Self, TxContext};
   use sui::transfer;

   struct Endpoint has store, copy, drop {
      url: String,
      description: String
   }

   struct EndpointAggregator has key {
      id: UID,
      key_addr: address,
      endpoints: vector<Endpoint>
   }

   public entry fun create_endpoint_aggregator(ctx: &mut TxContext){
      transfer::transfer(EndpointAggregator{
         id: object::new(ctx),
         key_addr: tx_context::sender(ctx),
         endpoints: vector::empty<Endpoint>(),
      }, tx_context::sender(ctx));

      transfer::share_object(EndpointAggregator {
         id: object::new(ctx),
         key_addr: tx_context::sender(ctx),
         endpoints: vector::empty<Endpoint>(),
      });
   }

   public entry fun add_endpoint(
      aggr: &mut EndpointAggregator,
      url: String, 
      description: String) {
        // let endpoint_aggr = borrow_global_mut<EndpointAggregator>(signer::address_of(acct));
        let endpoint_info = Endpoint{
            url: url, 
            description: description
        };
      vector::push_back(&mut aggr.endpoints, endpoint_info);
   }

   // public entry fun update endpoint with description, url
   public entry fun update_endpoint_with_description_and_url(
      aggr: &mut EndpointAggregator,
      url: String,
      new_description: String,
      new_url: String) {
      let length = vector::length(&mut aggr.endpoints);
      let i = 0;
      while (i < length) {
         let endpoint = vector::borrow_mut<Endpoint>(&mut aggr.endpoints, i);
         if (endpoint.url == url) {
            endpoint.url = new_url;
            endpoint.description = new_description;
            break
         };
         i = i + 1;
      };
   }

   // public entry fun delete endpoint
   public entry fun delete_endpoint(
      aggr: &mut EndpointAggregator,
      url: String) {
      let length = vector::length(&mut aggr.endpoints);
      let i = 0;
      while (i < length) {
         let endpoint = vector::borrow(&mut aggr.endpoints, i);
         if (endpoint.url == url) {
            vector::remove(&mut aggr.endpoints, i);
            break
         };
         i = i + 1;
      };
   }
}
