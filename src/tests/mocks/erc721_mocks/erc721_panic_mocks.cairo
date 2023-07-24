#[starknet::contract]
mod SnakeERC721PanicMock {
  use zeroable::Zeroable;
  use rules_utils::introspection::interface::ISRC5;

  //locals
  use rules_erc721::erc721::interface::{ IERC721, IERC721Metadata };

  //
  // Storage
  //

  #[storage]
  struct Storage {}

  //
  // IERC721 impl
  //

  #[external(v0)]
  impl IERC721Impl of IERC721<ContractState> {
    fn balance_of(self: @ContractState, account: starknet::ContractAddress) -> u256 {
      panic_with_felt252('Some error');
      u256 { low: 3, high: 3 }
    }

    fn owner_of(self: @ContractState, token_id: u256) -> starknet::ContractAddress {
      panic_with_felt252('Some error');
      Zeroable::zero()
    }

    fn get_approved(self: @ContractState, token_id: u256) -> starknet::ContractAddress {
      panic_with_felt252('Some error');
      Zeroable::zero()
    }

    fn is_approved_for_all(
      self: @ContractState,
      owner: starknet::ContractAddress,
      operator: starknet::ContractAddress
    ) -> bool {
      panic_with_felt252('Some error');
      false
    }

    fn approve(ref self: ContractState, to: starknet::ContractAddress, token_id: u256) {
      panic_with_felt252('Some error');
    }

    fn set_approval_for_all(ref self: ContractState, operator: starknet::ContractAddress, approved: bool) {
      panic_with_felt252('Some error');
    }

    fn transfer_from(
      ref self: ContractState,
      from: starknet::ContractAddress,
      to: starknet::ContractAddress,
      token_id: u256
    ) {
      panic_with_felt252('Some error');
    }

    fn safe_transfer_from(
      ref self: ContractState,
      from: starknet::ContractAddress,
      to: starknet::ContractAddress,
      token_id: u256,
      data: Span<felt252>
    ) {
      panic_with_felt252('Some error');
    }
  }

  //
  // IERC721 Metadata impl
  //

  #[external(v0)]
  impl IERC721MetadataImpl of IERC721Metadata<ContractState> {
    fn name(self: @ContractState) -> felt252 {
      panic_with_felt252('Some error');
      3
    }

    fn symbol(self: @ContractState) -> felt252 {
      panic_with_felt252('Some error');
      3
    }

    fn token_uri(self: @ContractState, token_id: u256) -> felt252 {
      panic_with_felt252('Some error');
      3
    }
  }

  //
  // ISRC5 impl
  //

  #[external(v0)]
  impl ISRC5Impl of ISRC5<ContractState> {
    fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
      panic_with_felt252('Some error');
      false
    }
  }
}

#[starknet::contract]
mod CamelERC721PanicMock {
  use zeroable::Zeroable;
  use rules_utils::introspection::interface::ISRC5Camel;

  //locals
  use rules_erc721::erc721::interface::{
    IERC721,
    IERC721Camel,
    IERC721CamelOnly,
    IERC721Metadata,
    IERC721MetadataCamel,
    IERC721MetadataCamelOnly,
  };

  //
  // Storage
  //

  #[storage]
  struct Storage {}

  //
  // IERC721 impl
  //

  #[external(v0)]
  impl IERC721CamelImpl of IERC721Camel<ContractState> {
    fn balanceOf(self: @ContractState, account: starknet::ContractAddress) -> u256 {
      panic_with_felt252('Some error');
      u256 { low: 3, high: 3 }
    }

    fn ownerOf(self: @ContractState, tokenId: u256) -> starknet::ContractAddress {
      panic_with_felt252('Some error');
      Zeroable::zero()
    }

    fn getApproved(self: @ContractState, tokenId: u256) -> starknet::ContractAddress {
      panic_with_felt252('Some error');
      Zeroable::zero()
    }

    fn isApprovedForAll(
      self: @ContractState,
      owner: starknet::ContractAddress,
      operator: starknet::ContractAddress
    ) -> bool {
      panic_with_felt252('Some error');
      false
    }

    fn approve(ref self: ContractState, to: starknet::ContractAddress, token_id: u256) {
      panic_with_felt252('Some error');
    }

    fn setApprovalForAll(ref self: ContractState, operator: starknet::ContractAddress, approved: bool) {
      panic_with_felt252('Some error');
    }

    fn transferFrom(
      ref self: ContractState,
      from: starknet::ContractAddress,
      to: starknet::ContractAddress,
      tokenId: u256
    ) {
      panic_with_felt252('Some error');
    }

    fn safeTransferFrom(
      ref self: ContractState,
      from: starknet::ContractAddress,
      to: starknet::ContractAddress,
      tokenId: u256,
      data: Span<felt252>
    ) {
      panic_with_felt252('Some error');
    }
  }

  //
  // IERC721 Metadata impl
  //

  #[external(v0)]
  impl IERC721MetadataImpl of IERC721MetadataCamel<ContractState> {
    fn name(self: @ContractState) -> felt252 {
      panic_with_felt252('Some error');
      3
    }

    fn symbol(self: @ContractState) -> felt252 {
      panic_with_felt252('Some error');
      3
    }

    fn tokenUri(self: @ContractState, tokenId: u256) -> felt252 {
      panic_with_felt252('Some error');
      3
    }
  }

  //
  // ISRC5 impl
  //

  #[external(v0)]
  impl ISRC5CamelImpl of ISRC5Camel<ContractState> {
    fn supportsInterface(self: @ContractState, interfaceId: felt252) -> bool {
      panic_with_felt252('Some error');
      false
    }
  }
}
