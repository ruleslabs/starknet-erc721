use array::SpanSerde;

const IERC721_ID: u32 = 0x80ac58cd;
const IERC721_METADATA_ID: u32 = 0x5b5e139f;
const IERC721_RECEIVER_ID: u32 = 0x150b7a02;

#[starknet::interface]
trait IERC721<TContractState> {
  fn name(self: @TContractState) -> felt252;

  fn symbol(self: @TContractState) -> felt252;

  fn token_uri(self: @TContractState, token_id: u256) -> felt252;

  fn balance_of(self: @TContractState, account: starknet::ContractAddress) -> u256;

  fn owner_of(self: @TContractState, token_id: u256) -> starknet::ContractAddress;

  fn get_approved(self: @TContractState, token_id: u256) -> starknet::ContractAddress;

  fn is_approved_for_all(
    self: @TContractState,
    owner: starknet::ContractAddress,
    operator: starknet::ContractAddress
  ) -> bool;

  fn transfer_from(
    ref self: TContractState,
    from: starknet::ContractAddress,
    to: starknet::ContractAddress,
    token_id: u256
  );

  fn safe_transfer_from(
    ref self: TContractState,
    from: starknet::ContractAddress,
    to: starknet::ContractAddress,
    token_id: u256,
    data: Span<felt252>
  );

  fn approve(ref self: TContractState, to: starknet::ContractAddress, token_id: u256);

  fn set_approval_for_all(ref self: TContractState, operator: starknet::ContractAddress, approved: bool);
}

#[starknet::interface]
trait IERC721Camel<TContractState> {
  fn tokenUri(self: @TContractState, tokenId: u256) -> felt252;

  fn balanceOf(self: @TContractState, account: starknet::ContractAddress) -> u256;

  fn ownerOf(self: @TContractState, tokenId: u256) -> starknet::ContractAddress;

  fn getApproved(self: @TContractState, tokenId: u256) -> starknet::ContractAddress;

  fn isApprovedForAll(
    self: @TContractState,
    owner: starknet::ContractAddress,
    operator: starknet::ContractAddress
  ) -> bool;

  fn transferFrom(
    ref self: TContractState,
    from: starknet::ContractAddress,
    to: starknet::ContractAddress,
    tokenId: u256
  );

  fn safeTransferFrom(
    ref self: TContractState,
    from: starknet::ContractAddress,
    to: starknet::ContractAddress,
    tokenId: u256,
    data: Span<felt252>
  );

  fn setApprovalForAll(ref self: TContractState, operator: starknet::ContractAddress, approved: bool);
}

// ERC721 Receiver

#[starknet::interface]
trait IERC721Receiver<TContractState> {
  fn on_erc721_received(
    ref self: TContractState,
    operator: starknet::ContractAddress,
    from: starknet::ContractAddress,
    token_id: u256,
    data: Span<felt252>
  ) -> u32;
}

#[starknet::interface]
trait IERC721ReceiverCamel<TContractState> {
  fn onERC721Received(
    ref self: TContractState,
    operator: starknet::ContractAddress,
    from: starknet::ContractAddress,
    tokenId: u256,
    data: Span<felt252>
  ) -> u32;
}
