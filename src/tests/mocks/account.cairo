#[starknet::contract]
mod Account {
  use rules_account::account::interface::ISRC6_ID;

  #[storage]
  struct Storage { }

  #[constructor]
  fn constructor(ref self: ContractState) {}

  #[external(v0)]
  fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
    if (interface_id == ISRC6_ID) {
      true
    } else {
      false
    }
  }
}

#[starknet::contract]
mod CamelAccount {
  use rules_account::account::interface::ISRC6_ID;

  #[storage]
  struct Storage { }

  #[constructor]
  fn constructor(ref self: ContractState) {}

  #[external(v0)]
  fn supportsInterface(self: @ContractState, interfaceId: felt252) -> bool {
    if (interfaceId == ISRC6_ID) {
      true
    } else {
      false
    }
  }
}
