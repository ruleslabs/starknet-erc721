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

  // ISRC5

  fn supports_interface(self: @TContractState, interface_id: felt252) -> bool;
}

#[starknet::contract]
mod ERC721 {
  use zeroable::Zeroable;
  use rules_account::account;
  use rules_utils::introspection::dual_src5::{ DualCaseSRC5, DualCaseSRC5Trait };

  // locals
  use erc721::erc721::interface;
  use erc721::erc721::interface::{ IERC721, IERC721Metadata };

  use rules_utils::introspection::src5::SRC5;
  use rules_utils::introspection::interface::{ ISRC5, ISRC5Camel };

  // Dispatchers
  use erc721::erc721::dual_erc721_receiver::{ DualCaseERC721Receiver, DualCaseERC721ReceiverTrait };

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
  // Events
  //

  #[event]
  #[derive(Drop, starknet::Event)]
  enum Event {
    Transfer: Transfer,
    Approval: Approval,
    ApprovalForAll: ApprovalForAll,
  }

  #[derive(Drop, starknet::Event)]
  struct Transfer {
    from: starknet::ContractAddress,
    to: starknet::ContractAddress,
    token_id: u256,
  }

  #[derive(Drop, starknet::Event)]
  struct Approval {
    owner: starknet::ContractAddress,
    approved: starknet::ContractAddress,
    token_id: u256,
  }

  #[derive(Drop, starknet::Event)]
  struct ApprovalForAll {
    owner: starknet::ContractAddress,
    operator: starknet::ContractAddress,
    approved: bool,
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
  impl IERC721Impl of interface::IERC721<ContractState> {
    fn balance_of(self: @ContractState, account: starknet::ContractAddress) -> u256 {
      assert(!account.is_zero(), 'ERC721: invalid account');
      self._balances.read(account)
    }

    fn owner_of(self: @ContractState, token_id: u256) -> starknet::ContractAddress {
      self._owner_of(:token_id)
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
      let caller = starknet::get_caller_address();

      assert(self._is_approved_or_owner(spender: caller, :token_id), 'ERC721: unauthorized caller');

      self._transfer(:from, :to, :token_id);
    }

    fn safe_transfer_from(
      ref self: ContractState,
      from: starknet::ContractAddress,
      to: starknet::ContractAddress,
      token_id: u256,
      data: Span<felt252>
    ) {
      let caller = starknet::get_caller_address();

      assert(self._is_approved_or_owner(spender: caller, :token_id), 'ERC721: unauthorized caller');

      self._safe_transfer(:from, :to, :token_id, :data);
    }

    fn approve(ref self: ContractState, to: starknet::ContractAddress, token_id: u256) {
      let owner = self._owner_of(token_id);

      let caller = starknet::get_caller_address();
      assert((owner == caller) | self.is_approved_for_all(:owner, operator: caller), 'ERC721: unauthorized caller');

      self._approve(to, token_id);
    }

    fn set_approval_for_all(ref self: ContractState, operator: starknet::ContractAddress, approved: bool) {
      let caller = starknet::get_caller_address();

      self._set_approval_for_all(owner: caller, :operator, :approved);
    }
  }

  //
  // IERC721 Camel impl
  //

  #[external(v0)]
  impl IERC721CamelOnlyImpl of interface::IERC721CamelOnly<ContractState> {
    fn balanceOf(self: @ContractState, account: starknet::ContractAddress) -> u256 {
      self.balance_of(:account)
    }

    fn ownerOf(self: @ContractState, tokenId: u256) -> starknet::ContractAddress {
      self.owner_of(token_id: tokenId)
    }

    fn getApproved(self: @ContractState, tokenId: u256) -> starknet::ContractAddress {
      self.get_approved(token_id: tokenId)
    }

    fn isApprovedForAll(
      self: @ContractState,
      owner: starknet::ContractAddress,
      operator: starknet::ContractAddress
    ) -> bool {
      self.is_approved_for_all(:owner, :operator)
    }

    fn transferFrom(
      ref self: ContractState,
      from: starknet::ContractAddress,
      to: starknet::ContractAddress,
      tokenId: u256
    ) {
      self.transfer_from(:from, :to, token_id: tokenId);
    }

    fn safeTransferFrom(
      ref self: ContractState,
      from: starknet::ContractAddress,
      to: starknet::ContractAddress,
      tokenId: u256,
      data: Span<felt252>
    ) {
      self.safe_transfer_from(:from, :to, token_id: tokenId, :data);
    }

    fn setApprovalForAll(ref self: ContractState, operator: starknet::ContractAddress, approved: bool) {
      self.set_approval_for_all(:operator, :approved);
    }
  }

  //
  // IERC721 Metadata impl
  //

  #[external(v0)]
  impl IERC721MetadataImpl of interface::IERC721Metadata<ContractState> {
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
  }

  //
  // IERC721 Metadata Camel impl
  //

  #[external(v0)]
  impl IERC721MetadataCamelOnlyImpl of interface::IERC721MetadataCamelOnly<ContractState> {
    fn tokenUri(self: @ContractState, tokenId: u256) -> felt252 {
      self.token_uri(token_id: tokenId)
    }
  }

  //
  // ISRC5 impl
  //

  #[external(v0)]
  impl ISRC5Impl of ISRC5<ContractState> {
    fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
      if (
        (interface_id == interface::IERC721_ID) |
        (interface_id == interface::IERC721_METADATA_ID)
      ) {
        true
      } else {
        let src5_self = SRC5::unsafe_new_contract_state();

        src5_self.supports_interface(:interface_id)
      }
    }
  }

  //
  // ISRC5Camel impl
  //

  #[external(v0)]
  impl ISRC5CamelImpl of ISRC5Camel<ContractState> {
    fn supportsInterface(self: @ContractState, interfaceId: felt252) -> bool {
      self.supports_interface(interface_id: interfaceId)
    }
  }

  //
  // Internals
  //

  #[generate_trait]
  impl InternalImpl of InternalTrait {
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

    fn _approve(ref self: ContractState, to: starknet::ContractAddress, token_id: u256) {
      let owner = self._owner_of(token_id);
      assert(owner != to, 'ERC721: approval to owner');

      self._token_approvals.write(token_id, to);

      // emit event
      self.emit(
        Event::Approval(
          Approval { owner, approved: to, token_id }
        )
      );
    }

    fn _set_approval_for_all(
      ref self: ContractState,
      owner: starknet::ContractAddress,
      operator: starknet::ContractAddress,
      approved: bool
    ) {
      assert(owner != operator, 'ERC721: self approval');

      self._operator_approvals.write((owner, operator), approved);

      // emit event
      self.emit(
        Event::ApprovalForAll(
          ApprovalForAll { owner, operator, approved }
        )
      );
    }

    fn _mint(ref self: ContractState, to: starknet::ContractAddress, token_id: u256) {
      assert(!to.is_zero(), 'ERC721: invalid receiver');
      assert(!self._exists(token_id), 'ERC721: token already minted');

      // Update balances
      self._balances.write(to, self._balances.read(to) + 1);

      // Update token_id owner
      self._owners.write(token_id, to);

      // Emit event
      self.emit(
        Event::Transfer(
          Transfer { from: Zeroable::zero(), to, token_id }
        )
      );
    }

    fn _transfer(
      ref self: ContractState,
      from: starknet::ContractAddress,
      to: starknet::ContractAddress,
      token_id: u256
    ) {
      assert(!to.is_zero(), 'ERC721: invalid receiver');
      let owner = self._owner_of(token_id);
      assert(from == owner, 'ERC721: wrong sender');

      // Implicit clear approvals, no need to emit an event
      self._token_approvals.write(token_id, Zeroable::zero());

      // Update balances
      self._balances.write(from, self._balances.read(from) - 1);
      self._balances.write(to, self._balances.read(to) + 1);

      // Update token_id owner
      self._owners.write(token_id, to);

      // Emit event
      self.emit(
        Event::Transfer(
          Transfer { from, to, token_id }
        )
      );
    }

    fn _burn(ref self: ContractState, token_id: u256) {
      let owner = self._owner_of(token_id);

      // Implicit clear approvals, no need to emit an event
      self._token_approvals.write(token_id, Zeroable::zero());

      // Update balances
      self._balances.write(owner, self._balances.read(owner) - 1);

      // Delete owner
      self._owners.write(token_id, Zeroable::zero());

      // Emit event
      self.emit(
        Event::Transfer(
          Transfer { from: owner, to: Zeroable::zero(), token_id }
        )
      )
    }

    fn _safe_mint(ref self: ContractState, to: starknet::ContractAddress, token_id: u256, data: Span<felt252>) {
      self._mint(to, token_id);

      assert(
        self._check_on_erc721_received(Zeroable::zero(), to, token_id, data),
        'ERC721: safe mint failed'
      );
    }

    fn _safe_transfer(
      ref self: ContractState,
      from: starknet::ContractAddress,
      to: starknet::ContractAddress,
      token_id: u256,
      data: Span<felt252>
    ) {
      self._transfer(:from, :to, :token_id);

      assert(self._check_on_erc721_received(:from, :to, :token_id, :data), 'ERC721: safe transfer failed');
    }

    fn _set_token_uri(ref self: ContractState, token_id: u256, token_uri: felt252) {
      assert(self._exists(token_id), 'ERC721: invalid token ID');

      self._token_uri.write(token_id, token_uri)
    }

    fn _check_on_erc721_received(
      self: @ContractState,
      from: starknet::ContractAddress,
      to: starknet::ContractAddress,
      token_id: u256,
      data: Span<felt252>
    ) -> bool {
      let SRC5 = DualCaseSRC5 { contract_address: to };

      if (SRC5.supports_interface(interface::IERC721_RECEIVER_ID)) {
        let ERC721Receiver = DualCaseERC721Receiver { contract_address: to };

        let caller = starknet::get_caller_address();

        ERC721Receiver.on_erc721_received(operator: caller, :from, :token_id, :data) == interface::IERC721_RECEIVER_ID
      } else {
        SRC5.supports_interface(account::interface::ISRC6_ID)
      }
    }
  }
}
