module my_addr::endpoint_aggregator {
   use std::vector;
   use std::string::{String};
   use sui::object::{Self, UID};
   use sui::vec_map::{Self,VecMap};
   use sui::event;
   use sui::tx_context::{Self, TxContext};
   use sui::transfer;

   const ERR_ENDPOINT_PARAM_VECTOR_LENGHT_MISMATCH: u64 = 5000;

   struct Endpoint has store, copy, drop {
      url: String,
      description: String,
      verification_url: String
   }

   struct EndpointAggregator has key {
      id: UID,
      key_addr: address,
      endpoints_map: VecMap<String, Endpoint>,
      names: vector<String>
   }

   struct AddrEndpointEvent has copy, drop, store {
      name: String,
      url: String,
      description: String,
      verification_url: String
   }

   struct UpdateEndpointEvent has copy, drop, store {
      name: String,
      url: String,
      description: String,
      verification_url: String
   }

   struct DeleteEndpointEvent has copy, drop, store {
      name: String
   }

   entry fun init(ctx: &mut TxContext){
      transfer::transfer(EndpointAggregator{
         id: object::new(ctx),
         key_addr: tx_context::sender(ctx),
         endpoints_map: vec_map::empty(),
         names: vector::empty()
      }, tx_context::sender(ctx));
   }

   public entry fun add_endpoint(
      aggr: &mut EndpointAggregator,
      name: String,
      url: String,
      description: String,
      verification_url: String
   )  {
      let endpoint_info = Endpoint {
         url,
         description,
         verification_url
      };

      vec_map::insert(&mut aggr.endpoints_map, name, endpoint_info);
      vector::push_back(&mut aggr.names, name);

      event::emit(AddrEndpointEvent{
         name,
         url,
         description,
         verification_url
      })
   }

   // public entry fun batch_add_endpoint(
   //    aggr: &mut EndpointAggregator,
   //    names: vector<String>,
   //    endpoints: vector<Endpoint>
   // ) {
   //    let names_length = vector::length(&names);
   //    let endpoints_length = vector::length(&endpoints);
   //    assert!(names_length == endpoints_length, ERR_ENDPOINT_PARAM_VECTOR_LENGHT_MISMATCH);

      // let i = 0;
      // while (i < names_length) {
      //    let name = vector::borrow<String>(&names, i);
      //    let endpoint = vector::borrow<Endpoint>(&endpoints, i);
      //
      //
      //    vec_map::insert(&mut aggr.endpoints_map, *name, *endpoint);
      //    vector::push_back(&mut aggr.names, *name);
      //
      //    event::emit(AddrEndpointEvent{
      //       name: *name,
      //       url: endpoint.url,
      //       description: endpoint.description,
      //       verification_url: endpoint.verification_url
      //    });
      //
      //    i = i + 1;
      // };
   // }


   // Update endpoint with params.
   public entry fun update_endpoint(
      aggr: &mut EndpointAggregator,
      name: String,
      new_description: String,
      new_url: String,
      new_verification_url: String
   )  {

      let endpoint = vec_map::get_mut(&mut aggr.endpoints_map, &name);

      endpoint.url = new_url;
      endpoint.description = new_description;
      endpoint.verification_url = new_verification_url;

      event::emit(UpdateEndpointEvent {
         name,
         url: new_url,
         description: new_description,
         verification_url: new_verification_url
      })
   }

   // Delete endpoint.
   public entry fun delete_endpoint(
      aggr: &mut EndpointAggregator,
      name: String) {

      vec_map::remove(&mut aggr.endpoints_map, &name);

      let length = vector::length(&aggr.names);
      let i = 0;
      while (i < length) {
         let current_name = vector::borrow<String>(&aggr.names, i);
         if (*current_name == name) {
            vector::remove(&mut aggr.names, i);

            event::emit(DeleteEndpointEvent {
               name
            });

            break
         };
         i = i + 1;
      };
   }

}

