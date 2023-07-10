#[starknet::interface]
trait ERC721ABI<TContractState> {

  // IERC721

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

  // IERC165

  fn supports_interface(self: @TContractState, interface_id: u32) -> bool;
}

#[starknet::contract]
mod ERC721 {
  use zeroable::Zeroable;

  // locals
  use rules_erc721::erc721::interface::IERC721;

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
    _owners: LegacyMap<u256, starknet::ContractAddress>,
    _balances: LegacyMap<starknet::ContractAddress, u256>,
    _token_approvals: LegacyMap<u256, starknet::ContractAddress>,
    _operator_approvals: LegacyMap<(starknet::ContractAddress, starknet::ContractAddress), bool>,
    _token_uri: LegacyMap<u256, felt252>,
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

  #[external(v0)]
  impl IERC721Impl of erc721::interface::IERC721<ContractState> {
    fn name(self: @ContractState) -> felt252 {
      self._name.read()
    }

    fn symbol(self: @ContractState) -> felt252 {
      self._symbol.read()
    }

    fn token_uri(self: @ContractState, token_id: u256) -> felt252 {
      assert(self._exists(token_id), 'ERC721: invalid token ID');
      self._token_uri.read(token_id)
    }

    fn balance_of(self: @ContractState, account: starknet::ContractAddress) -> u256 {
      assert(!account.is_zero(), 'ERC721: invalid account');
      self._balances.read(account)
    }

    fn owner_of(self: @ContractState, token_id: u256) -> starknet::ContractAddress {
      self._owner_of(token_id)
    }

    fn get_approved(self: @ContractState, token_id: u256) -> starknet::ContractAddress {
      assert(self._exists(token_id), 'ERC721: invalid token ID');
      self._token_approvals.read(token_id)
    }

    fn is_approved_for_all(
      self: @ContractState,
      owner: starknet::ContractAddress,
      operator: starknet::ContractAddress
    ) -> bool {
      self._operator_approvals.read((owner, operator))
    }

    fn transfer_from(
      ref self: ContractState,
      from: starknet::ContractAddress,
      to: starknet::ContractAddress,
      token_id: u256
    ) {
      // TODO
    }

    fn safe_transfer_from(
      ref self: ContractState,
      from: starknet::ContractAddress,
      to: starknet::ContractAddress,
      token_id: u256,
      data: Span<felt252>
    ) {
      // TODO
    }

    fn approve(ref self: ContractState, to: starknet::ContractAddress, token_id: u256) {
      // TODO
    }

    fn set_approval_for_all(ref self: ContractState, operator: starknet::ContractAddress, approved: bool) {
      // TODO
    }
  }

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

    fn _owner_of(self: @ContractState, token_id: u256) -> starknet::ContractAddress {
      let owner = self._owners.read(token_id);

      match owner.is_zero() {
        bool::False(()) => owner,
        bool::True(()) => panic_with_felt252('ERC721: invalid token ID')
      }
    }

    fn _exists(self: @ContractState, token_id: u256) -> bool {
      !self._owners.read(token_id).is_zero()
    }

    fn _is_approved_or_owner(self: @ContractState, spender: starknet::ContractAddress, token_id: u256) -> bool {
      let owner = self._owner_of(token_id);

      (owner == spender) | self.is_approved_for_all(owner, spender) | (spender == self.get_approved(token_id))
    }
  }
}
