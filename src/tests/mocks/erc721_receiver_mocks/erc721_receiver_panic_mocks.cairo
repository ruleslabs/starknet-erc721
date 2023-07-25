#[starknet::contract]
mod SnakeERC721ReceiverPanicMock {
  #[storage]
  struct Storage {}

  #[external(v0)]
  fn on_erc721_received(
    self: @ContractState,
    operator: starknet::ContractAddress,
    from: starknet::ContractAddress,
    token_id: u256,
    data: Span<felt252>
  ) -> felt252 {
    panic_with_felt252('Some error');
    3
  }
}

#[starknet::contract]
mod CamelERC721ReceiverPanicMock {
  #[storage]
  struct Storage {}

  #[external(v0)]
  fn onERC721Received(
    self: @ContractState,
    operator: starknet::ContractAddress,
    from: starknet::ContractAddress,
    tokenId: u256,
    data: Span<felt252>
  ) -> felt252 {
    panic_with_felt252('Some error');
    3
  }
}
