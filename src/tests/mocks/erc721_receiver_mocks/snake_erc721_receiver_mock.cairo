use super::SUCCESS;

#[starknet::contract]
mod SnakeERC721ReceiverMock {
  use traits::Into;
  use array::{ SpanTrait, SpanSerde };

  // locals
  use rules_erc721::erc721::interface::{ IERC721Receiver, IERC721_RECEIVER_ID };
  use rules_utils::introspection::src5::SRC5;
  use rules_utils::introspection::interface::ISRC5;
  use rules_utils::introspection::src5::SRC5::InternalTrait;

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
    let mut src5_self = SRC5::unsafe_new_contract_state();

    src5_self._register_interface(interface_id: IERC721_RECEIVER_ID);
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
    ) -> felt252 {
      if (*data.at(0) == super::SUCCESS) {
        IERC721_RECEIVER_ID
      } else {
        0
      }
    }
  }

  #[external(v0)]
  fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
    let src5_self = SRC5::unsafe_new_contract_state();

    src5_self.supports_interface(:interface_id)
  }
}
