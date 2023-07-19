const SUCCESS: felt252 = 'SUCCESS';
const FAILURE: felt252 = 'FAILURE';

#[starknet::contract]
mod ERC721Receiver {
  use traits::Into;
  use array::{ SpanTrait, SpanSerde };

  // locals
  use rules_erc721::erc721::interface::{ IERC721Receiver, IERC721_RECEIVER_ID };
  use rules_utils::introspection::erc165::{ ERC165, IERC165 };
  use rules_utils::introspection::erc165::ERC165::HelperTrait;

  //
  // Storage
  //

  #[storage]
  struct Storage { }

  //
  // Constructor
  //

  #[constructor]
  fn constructor(ref self: ContractState) {
    let mut erc165_self = ERC165::unsafe_new_contract_state();

    erc165_self._register_interface(interface_id: IERC721_RECEIVER_ID);
  }

  //
  // ERC721 Receiver impl
  //

  #[external(v0)]
  impl ERC721ReceiverImpl of IERC721Receiver<ContractState> {
    fn on_erc721_received(
      ref self: ContractState,
      operator: starknet::ContractAddress,
      from: starknet::ContractAddress,
      token_id: u256,
      data: Span<felt252>
    ) -> u32 {
      if (*data.at(0) == super::SUCCESS) {
        IERC721_RECEIVER_ID
      } else {
        0
      }
    }
  }

  #[external(v0)]
  fn supports_interface(self: @ContractState, interface_id: u32) -> bool {
    let erc165_self = ERC165::unsafe_new_contract_state();

    erc165_self.supports_interface(:interface_id)
  }
}

#[starknet::contract]
mod CamelERC721Receiver {
  use traits::Into;
  use array::{ SpanTrait, SpanSerde };

  // locals
  use rules_erc721::erc721::interface::{ IERC721ReceiverCamel, IERC721_RECEIVER_ID };
  use rules_utils::introspection::erc165::{ ERC165, IERC165 };
  use rules_utils::introspection::erc165::ERC165::HelperTrait;

  //
  // Storage
  //

  #[storage]
  struct Storage { }

  //
  // Constructor
  //

  #[constructor]
  fn constructor(ref self: ContractState) {
    let mut erc165_self = ERC165::unsafe_new_contract_state();

    erc165_self._register_interface(interface_id: IERC721_RECEIVER_ID);
  }

  //
  // ERC721 Receiver impl
  //

  #[external(v0)]
  impl ERC721ReceiverImpl of IERC721ReceiverCamel<ContractState> {
    fn onERC721Received(
      ref self: ContractState,
      operator: starknet::ContractAddress,
      from: starknet::ContractAddress,
      tokenId: u256,
      data: Span<felt252>
    ) -> u32 {
      if (*data.at(0) == super::SUCCESS) {
        IERC721_RECEIVER_ID
      } else {
        0
      }
    }
  }

  #[external(v0)]
  fn supportsInterface(self: @ContractState, interfaceId: u32) -> bool {
    let erc165_self = ERC165::unsafe_new_contract_state();

    erc165_self.supports_interface(interface_id: interfaceId)
  }
}

#[starknet::contract]
mod ERC721NonReceiver {
  #[storage]
  struct Storage { }

  #[constructor]
  fn constructor(ref self: ContractState) {}
}
