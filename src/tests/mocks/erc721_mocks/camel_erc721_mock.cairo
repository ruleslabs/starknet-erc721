#[starknet::contract]
mod CamelERC721Mock {
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
  use rules_erc721::erc721::erc721::ERC721;
  use rules_erc721::erc721::erc721::ERC721::InternalTrait as ERC721InternalTrait;

  //
  // Storage
  //

  #[storage]
  struct Storage {}

  //
  // Constructor
  //

  #[constructor]
  fn constructor(ref self: ContractState, name_: felt252, symbol_: felt252, tokenId: u256, tokenUri: felt252) {
    let mut erc721_self = ERC721::unsafe_new_contract_state();

    let caller = starknet::get_caller_address();

    erc721_self.initializer(:name_, :symbol_);
    erc721_self._mint(to: caller, token_id: tokenId);
    erc721_self._set_token_uri(token_id: tokenId, token_uri: tokenUri);
  }

  //
  // IERC721 impl
  //

  #[external(v0)]
  impl IERC721CamelImpl of IERC721Camel<ContractState> {
    fn balanceOf(self: @ContractState, account: starknet::ContractAddress) -> u256 {
      let erc721_self = ERC721::unsafe_new_contract_state();

      erc721_self.balanceOf(:account)
    }

    fn ownerOf(self: @ContractState, tokenId: u256) -> starknet::ContractAddress {
      let erc721_self = ERC721::unsafe_new_contract_state();

      erc721_self.ownerOf(:tokenId)
    }

    fn getApproved(self: @ContractState, tokenId: u256) -> starknet::ContractAddress {
      let erc721_self = ERC721::unsafe_new_contract_state();

      erc721_self.getApproved(:tokenId)
    }

    fn isApprovedForAll(
      self: @ContractState,
      owner: starknet::ContractAddress,
      operator: starknet::ContractAddress
    ) -> bool {
      let erc721_self = ERC721::unsafe_new_contract_state();

      erc721_self.isApprovedForAll(:owner, :operator)
    }

    fn approve(ref self: ContractState, to: starknet::ContractAddress, token_id: u256) {
      let mut erc721_self = ERC721::unsafe_new_contract_state();

      erc721_self.approve(:to, :token_id);
    }

    fn setApprovalForAll(ref self: ContractState, operator: starknet::ContractAddress, approved: bool) {
      let mut erc721_self = ERC721::unsafe_new_contract_state();

      erc721_self.setApprovalForAll(:operator, :approved);
    }

    fn transferFrom(
      ref self: ContractState,
      from: starknet::ContractAddress,
      to: starknet::ContractAddress,
      tokenId: u256
    ) {
      let mut erc721_self = ERC721::unsafe_new_contract_state();

      erc721_self.transferFrom(:from, :to, :tokenId);
    }

    fn safeTransferFrom(
      ref self: ContractState,
      from: starknet::ContractAddress,
      to: starknet::ContractAddress,
      tokenId: u256,
      data: Span<felt252>
    ) {
      let mut erc721_self = ERC721::unsafe_new_contract_state();

      erc721_self.safeTransferFrom(:from, :to, :tokenId, :data);
    }
  }

  //
  // IERC721 Metadata impl
  //

  #[external(v0)]
  impl IERC721MetadataImpl of IERC721MetadataCamel<ContractState> {
    fn name(self: @ContractState) -> felt252 {
      let erc721_self = ERC721::unsafe_new_contract_state();

      erc721_self.name()
    }

    fn symbol(self: @ContractState) -> felt252 {
      let erc721_self = ERC721::unsafe_new_contract_state();

      erc721_self.symbol()
    }

    fn tokenUri(self: @ContractState, tokenId: u256) -> felt252 {
      let erc721_self = ERC721::unsafe_new_contract_state();

      erc721_self.tokenUri(:tokenId)
    }
  }

  //
  // ISRC5 impl
  //

  #[external(v0)]
  impl ISRC5CamelImpl of ISRC5Camel<ContractState> {
    fn supportsInterface(self: @ContractState, interfaceId: felt252) -> bool {
      let erc721_self = ERC721::unsafe_new_contract_state();

      erc721_self.supportsInterface(:interfaceId)
    }
  }
}
