#[starknet::interface]
trait ERC721ABI<TContractState> {
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

  // IERC721Metadata

  fn name(self: @TContractState) -> felt252;

  fn symbol(self: @TContractState) -> felt252;

  fn token_uri(self: @TContractState, token_id: u256) -> felt252;
}

#[starknet::contract]
mod ERC721 {
  // locals
  use rules_erc721::erc721;

  use rules_erc721::introspection::erc165;
  use rules_erc721::introspection::erc165::{ ERC165, IERC165 };

  //
  // Storage
  //

  #[storage]
  struct Storage {
    _name: felt252,
    _symbol: felt252,
  }

  //
  // Constructor
  //

  #[constructor]
  fn constructor(ref self: ContractState, name_: felt252, symbol_: felt252) {
    self.initializer(:name_, :symbol_);
  }

  //
  // IERC721 impl
  //

  // #[external(v0)]
  // impl IERC721Impl of erc721::interface::IERC721<ContractState> { }

  //
  // IERC165 impl
  //

  #[external(v0)]
  impl IERC165Impl of erc165::IERC165<ContractState> {
    fn supports_interface(self: @ContractState, interface_id: u32) -> bool {
      if (
        (interface_id == erc721::interface::IERC721_ID) |
        (interface_id == erc721::interface::IERC721_METADATA_ID)
      ) {
        true
      } else {
        let erc165_self = ERC165::unsafe_new_contract_state();

        erc165_self.supports_interface(:interface_id)
      }
    }
  }

  //
  // Helpers
  //

  #[generate_trait]
  impl HelperImpl of HelperTrait {
    fn initializer(ref self: ContractState, name_: felt252, symbol_: felt252) {
      self._name.write(name_);
      self._symbol.write(symbol_);
    }
  }
}
