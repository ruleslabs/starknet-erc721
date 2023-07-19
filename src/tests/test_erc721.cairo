use starknet::testing;
use array::ArrayTrait;
use traits::Into;
use zeroable::Zeroable;

// locals
use rules_utils::introspection::erc165;
use rules_erc721::erc721;
use rules_erc721::erc721::erc721::ERC721;
use rules_erc721::erc721::erc721::ERC721::{
  ContractState as ERC721ContractState,
  IERC721,
  IERC721Camel,
  HelperTrait as ERC721HelperTrait,
  IERC165 as ERC721_IERC165,
};
use rules_erc721::erc721::erc721::ERC721::{
  _owners::InternalContractStateTrait as ERC721_ownersInternalContractStateTrait,
  _token_approvals::InternalContractStateTrait as ERC721_token_approvalsInternalContractStateTrait,
};

use super::utils;
use super::mocks::account::{ Account, CamelAccount };
use super::mocks::erc721_receiver::{ ERC721Receiver, CamelERC721Receiver };
use super::mocks::erc721_receiver::ERC721NonReceiver;
use super::mocks::erc721_receiver::SUCCESS;
use super::mocks::erc721_receiver::FAILURE;

const NAME: felt252 = 111;
const SYMBOL: felt252 = 222;
const URI: felt252 = 333;
const TOKEN_ID: u256 = 7;
const PUBKEY: felt252 = 444;

fn ZERO() -> starknet::ContractAddress {
  Zeroable::zero()
}
fn OWNER() -> starknet::ContractAddress {
  starknet::contract_address_const::<10>()
}
fn RECIPIENT() -> starknet::ContractAddress {
  starknet::contract_address_const::<20>()
}
fn SPENDER() -> starknet::ContractAddress {
  starknet::contract_address_const::<30>()
}
fn OPERATOR() -> starknet::ContractAddress {
  starknet::contract_address_const::<40>()
}
fn OTHER() -> starknet::ContractAddress {
  starknet::contract_address_const::<50>()
}

fn DATA(success: bool) -> Span<felt252> {
  let mut data = ArrayTrait::new();
  if success {
    data.append(SUCCESS);
  } else {
    data.append(FAILURE);
  }
  data.span()
}

//
// Setup
//

fn setup() -> ERC721ContractState {
  let mut erc721_self = ERC721::unsafe_new_contract_state();

  erc721_self.initializer(NAME, SYMBOL);

  erc721_self
}

fn setup_and_mint() -> ERC721ContractState {
  let mut erc721_self = setup();

  erc721_self._mint(OWNER(), TOKEN_ID);

  erc721_self
}

fn setup_receiver() -> starknet::ContractAddress {
  utils::deploy(ERC721Receiver::TEST_CLASS_HASH, ArrayTrait::new())
}

fn setup_camel_receiver() -> starknet::ContractAddress {
  utils::deploy(CamelERC721Receiver::TEST_CLASS_HASH, ArrayTrait::new())
}

fn setup_account() -> starknet::ContractAddress {
  utils::deploy(Account::TEST_CLASS_HASH, calldata: ArrayTrait::new())
}

fn setup_camel_account() -> starknet::ContractAddress {
  utils::deploy(CamelAccount::TEST_CLASS_HASH, calldata: ArrayTrait::new())
}

//
// Initializers
//

// #[test]
// #[available_gas(2000000)]
// fn test_constructor() {
//   ERC721::constructor(NAME, SYMBOL);

//   assert(ERC721::name() == NAME, 'Name should be NAME');
//   assert(ERC721::symbol() == SYMBOL, 'Symbol should be SYMBOL');
//   assert(ERC721::balance_of(OWNER()) == 0, 'Balance should be zero');

//   assert(ERC721::supports_interface(erc721::interface::IERC721_ID), 'Missing interface ID');
//   assert(
//     ERC721::supports_interface(erc721::interface::IERC721_METADATA_ID), 'missing interface ID'
//   );
//   assert(ERC721::supports_interface(src5::ISRC5_ID), 'missing interface ID');
// }

#[test]
#[available_gas(2000000)]
fn test_initialize() {
  let erc721_self = setup();

  assert(erc721_self.name() == NAME, 'Name should be NAME');
  assert(erc721_self.symbol() == SYMBOL, 'Symbol should be SYMBOL');
  assert(erc721_self.balance_of(OWNER()) == 0, 'Balance should be zero');

  assert(erc721_self.supports_interface(erc721::interface::IERC721_ID), 'Missing interface ID');
  assert(erc721_self.supports_interface(erc721::interface::IERC721_METADATA_ID), 'missing interface ID');
  assert(erc721_self.supports_interface(erc165::IERC165_ID), 'missing interface ID');
}

//
// Getters
//

#[test]
#[available_gas(2000000)]
fn test_balance_of() {
  let erc721_self = setup_and_mint();

  assert(erc721_self.balance_of(OWNER()) == 1, 'Should return balance');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid account', ))]
fn test_balance_of_zero() {
  let erc721_self = setup_and_mint();

  erc721_self.balance_of(ZERO());
}

#[test]
#[available_gas(2000000)]
fn test_owner_of() {
  let erc721_self = setup_and_mint();

  assert(erc721_self.owner_of(TOKEN_ID) == OWNER(), 'Should return owner');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid token ID', ))]
fn test_owner_of_non_minted() {
  let erc721_self = setup();

  erc721_self.owner_of(7);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid token ID', ))]
fn test_token_uri_non_minted() {
  let erc721_self = setup();

  erc721_self.token_uri(7);
}

#[test]
#[available_gas(2000000)]
fn test_get_approved() {
  let mut erc721_self = setup_and_mint();

  let spender = SPENDER();
  let token_id = TOKEN_ID;

  assert(erc721_self.get_approved(token_id) == ZERO(), 'Should return non-approval');
  erc721_self._approve(spender, token_id);
  assert(erc721_self.get_approved(token_id) == spender, 'Should return approval');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid token ID', ))]
fn test_get_approved_nonexistent() {
  let erc721_self = setup();

  erc721_self.get_approved(7);
}

#[test]
#[available_gas(2000000)]
fn test__exists() {
  let mut erc721_self = setup();

  let zero = ZERO();
  let token_id = TOKEN_ID;

  assert(!erc721_self._exists(token_id), 'Token should not exist');
  assert(erc721_self._owners.read(token_id) == zero, 'Invalid owner');

  erc721_self._mint(RECIPIENT(), token_id);

  assert(erc721_self._exists(token_id), 'Token should exist');
  assert(erc721_self._owners.read(token_id) == RECIPIENT(), 'Invalid owner');

  erc721_self._burn(token_id);

  assert(!erc721_self._exists(token_id), 'Token should not exist');
  assert(erc721_self._owners.read(token_id) == zero, 'Invalid owner');
}

//
// approve & _approve
//

#[test]
#[available_gas(2000000)]
fn test_approve_from_owner() {
  let mut erc721_self = setup_and_mint();

  testing::set_caller_address(OWNER());
  erc721_self.approve(SPENDER(), TOKEN_ID);
  assert(erc721_self.get_approved(TOKEN_ID) == SPENDER(), 'Spender not approved correctly');
}

#[test]
#[available_gas(2000000)]
fn test_approve_from_operator() {
  let mut erc721_self = setup_and_mint();

  testing::set_caller_address(OWNER());
  erc721_self.set_approval_for_all(OPERATOR(), true);

  testing::set_caller_address(OPERATOR());
  erc721_self.approve(SPENDER(), TOKEN_ID);
  assert(erc721_self.get_approved(TOKEN_ID) == SPENDER(), 'Spender not approved correctly');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: unauthorized caller', ))]
fn test_approve_from_unauthorized() {
  let mut erc721_self = setup_and_mint();

  testing::set_caller_address(OTHER());
  erc721_self.approve(SPENDER(), TOKEN_ID);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: approval to owner', ))]
fn test_approve_to_owner() {
  let mut erc721_self = setup_and_mint();

  testing::set_caller_address(OWNER());
  erc721_self.approve(OWNER(), TOKEN_ID);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid token ID', ))]
fn test_approve_nonexistent() {
  let mut erc721_self = setup();

  erc721_self.approve(SPENDER(), TOKEN_ID);
}

#[test]
#[available_gas(2000000)]
fn test__approve() {
  let mut erc721_self = setup_and_mint();

  erc721_self._approve(SPENDER(), TOKEN_ID);
  assert(erc721_self.get_approved(TOKEN_ID) == SPENDER(), 'Spender not approved correctly');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: approval to owner', ))]
fn test__approve_to_owner() {
  let mut erc721_self = setup_and_mint();

  erc721_self._approve(OWNER(), TOKEN_ID);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid token ID', ))]
fn test__approve_nonexistent() {
  let mut erc721_self = setup();

  erc721_self._approve(SPENDER(), TOKEN_ID);
}

//
// set_approval_for_all & _set_approval_for_all
//

#[test]
#[available_gas(2000000)]
fn test_set_approval_for_all() {
  let mut erc721_self = setup_and_mint();

  testing::set_caller_address(OWNER());
  assert(!erc721_self.is_approved_for_all(OWNER(), OPERATOR()), 'Invalid default value');

  erc721_self.set_approval_for_all(OPERATOR(), true);
  assert(erc721_self.is_approved_for_all(OWNER(), OPERATOR()), 'Operator not approved correctly');

  erc721_self.set_approval_for_all(OPERATOR(), false);
  assert(!erc721_self.is_approved_for_all(OWNER(), OPERATOR()), 'Approval not revoked correctly');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: self approval', ))]
fn test_set_approval_for_all_owner_equal_operator_true() {
  let mut erc721_self = setup_and_mint();

  testing::set_caller_address(OWNER());
  erc721_self.set_approval_for_all(OWNER(), true);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: self approval', ))]
fn test_set_approval_for_all_owner_equal_operator_false() {
  let mut erc721_self = setup_and_mint();

  testing::set_caller_address(OWNER());
  erc721_self.set_approval_for_all(OWNER(), false);
}

#[test]
#[available_gas(2000000)]
fn test__set_approval_for_all() {
  let mut erc721_self = setup_and_mint();

  assert(!erc721_self.is_approved_for_all(OWNER(), OPERATOR()), 'Invalid default value');

  erc721_self._set_approval_for_all(OWNER(), OPERATOR(), true);
  assert(erc721_self.is_approved_for_all(OWNER(), OPERATOR()), 'Operator not approved correctly');

  erc721_self._set_approval_for_all(OWNER(), OPERATOR(), false);
  assert(!erc721_self.is_approved_for_all(OWNER(), OPERATOR()), 'Operator not approved correctly');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: self approval', ))]
fn test__set_approval_for_all_owner_equal_operator_true() {
  let mut erc721_self = setup_and_mint();

  erc721_self._set_approval_for_all(OWNER(), OWNER(), true);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: self approval', ))]
fn test__set_approval_for_all_owner_equal_operator_false() {
  let mut erc721_self = setup_and_mint();

  erc721_self._set_approval_for_all(OWNER(), OWNER(), false);
}

//
// transfer_from & transferFrom
//

#[test]
#[available_gas(2000000)]
fn test_transfer_from_owner() {
  let mut erc721_self = setup_and_mint();

  let token_id = TOKEN_ID;
  let owner = OWNER();
  let recipient = RECIPIENT();

  // set approval to check reset
  erc721_self._approve(OTHER(), token_id);

  assert_state_before_transfer(@erc721_self, token_id, owner, recipient);
  assert(erc721_self.get_approved(token_id) == OTHER(), 'Approval not implicitly reset');

  testing::set_caller_address(owner);
  erc721_self.transfer_from(owner, recipient, token_id);

  assert_state_after_transfer(@erc721_self, token_id, owner, recipient);
}

#[test]
#[available_gas(2000000)]
fn test_transferFrom_owner() {
  let mut erc721_self = setup_and_mint();

  let token_id = TOKEN_ID;
  let owner = OWNER();
  let recipient = RECIPIENT();

  // set approval to check reset
  erc721_self._approve(OTHER(), token_id);

  assert_state_before_transfer(@erc721_self, token_id, owner, recipient);
  assert(erc721_self.get_approved(token_id) == OTHER(), 'Approval not implicitly reset');

  testing::set_caller_address(owner);
  erc721_self.transferFrom(owner, recipient, token_id);

  assert_state_after_transfer(@erc721_self, token_id, owner, recipient);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid token ID', ))]
fn test_transfer_from_nonexistent() {
  let mut erc721_self = setup();

  erc721_self.transfer_from(ZERO(), RECIPIENT(), TOKEN_ID);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid token ID', ))]
fn test_transferFrom_nonexistent() {
  let mut erc721_self = setup();

  erc721_self.transferFrom(ZERO(), RECIPIENT(), TOKEN_ID);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid receiver', ))]
fn test_transfer_from_to_zero() {
  let mut erc721_self = setup_and_mint();

  testing::set_caller_address(OWNER());
  erc721_self.transfer_from(OWNER(), ZERO(), TOKEN_ID);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid receiver', ))]
fn test_transferFrom_to_zero() {
  let mut erc721_self = setup_and_mint();

  testing::set_caller_address(OWNER());
  erc721_self.transferFrom(OWNER(), ZERO(), TOKEN_ID);
}

#[test]
#[available_gas(2000000)]
fn test_transfer_from_to_owner() {
  let mut erc721_self = setup_and_mint();

  assert(erc721_self.owner_of(TOKEN_ID) == OWNER(), 'Ownership before');
  assert(erc721_self.balance_of(OWNER()) == 1, 'Balance of owner before');

  testing::set_caller_address(OWNER());
  erc721_self.transfer_from(OWNER(), OWNER(), TOKEN_ID);

  assert(erc721_self.owner_of(TOKEN_ID) == OWNER(), 'Ownership after');
  assert(erc721_self.balance_of(OWNER()) == 1, 'Balance of owner after');
}

#[test]
#[available_gas(2000000)]
fn test_transferFrom_to_owner() {
  let mut erc721_self = setup_and_mint();

  assert(erc721_self.owner_of(TOKEN_ID) == OWNER(), 'Ownership before');
  assert(erc721_self.balance_of(OWNER()) == 1, 'Balance of owner before');

  testing::set_caller_address(OWNER());
  erc721_self.transferFrom(OWNER(), OWNER(), TOKEN_ID);

  assert(erc721_self.owner_of(TOKEN_ID) == OWNER(), 'Ownership after');
  assert(erc721_self.balance_of(OWNER()) == 1, 'Balance of owner after');
}

#[test]
#[available_gas(2000000)]
fn test_transfer_from_approved() {
  let mut erc721_self = setup_and_mint();

  let token_id = TOKEN_ID;
  let owner = OWNER();
  let recipient = RECIPIENT();

  assert_state_before_transfer(@erc721_self, token_id, owner, recipient);

  testing::set_caller_address(owner);
  erc721_self.approve(OPERATOR(), token_id);

  testing::set_caller_address(OPERATOR());
  erc721_self.transfer_from(owner, recipient, token_id);

  assert_state_after_transfer(@erc721_self, token_id, owner, recipient);
}

#[test]
#[available_gas(2000000)]
fn test_transferFrom_approved() {
  let mut erc721_self = setup_and_mint();

  let token_id = TOKEN_ID;
  let owner = OWNER();
  let recipient = RECIPIENT();

  assert_state_before_transfer(@erc721_self, token_id, owner, recipient);

  testing::set_caller_address(owner);
  erc721_self.approve(OPERATOR(), token_id);

  testing::set_caller_address(OPERATOR());
  erc721_self.transferFrom(owner, recipient, token_id);

  assert_state_after_transfer(@erc721_self, token_id, owner, recipient);
}

#[test]
#[available_gas(2000000)]
fn test_transfer_from_approved_for_all() {
  let mut erc721_self = setup_and_mint();

  let token_id = TOKEN_ID;
  let owner = OWNER();
  let recipient = RECIPIENT();

  assert_state_before_transfer(@erc721_self, token_id, owner, recipient);

  testing::set_caller_address(owner);
  erc721_self.set_approval_for_all(OPERATOR(), true);

  testing::set_caller_address(OPERATOR());
  erc721_self.transfer_from(owner, recipient, token_id);

  assert_state_after_transfer(@erc721_self, token_id, owner, recipient);
}

#[test]
#[available_gas(2000000)]
fn test_transferFrom_approved_for_all() {
  let mut erc721_self = setup_and_mint();

  let token_id = TOKEN_ID;
  let owner = OWNER();
  let recipient = RECIPIENT();

  assert_state_before_transfer(@erc721_self, token_id, owner, recipient);

  testing::set_caller_address(owner);
  erc721_self.set_approval_for_all(OPERATOR(), true);

  testing::set_caller_address(OPERATOR());
  erc721_self.transferFrom(owner, recipient, token_id);

  assert_state_after_transfer(@erc721_self, token_id, owner, recipient);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: unauthorized caller', ))]
fn test_transfer_from_unauthorized() {
  let mut erc721_self = setup_and_mint();

  testing::set_caller_address(OTHER());
  erc721_self.transfer_from(OWNER(), RECIPIENT(), TOKEN_ID);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: unauthorized caller', ))]
fn test_transferFrom_unauthorized() {
  let mut erc721_self = setup_and_mint();

  testing::set_caller_address(OTHER());
  erc721_self.transferFrom(OWNER(), RECIPIENT(), TOKEN_ID);
}

//
// safe_transfer_from & safeTransferFrom
//

#[test]
#[available_gas(2000000)]
fn test_safe_transfer_from_to_account() {
  let mut erc721_self = setup_and_mint();
  let account = setup_account();

  let token_id = TOKEN_ID;
  let owner = OWNER();

  assert_state_before_transfer(@erc721_self, token_id, owner, account);

  testing::set_caller_address(owner);
  erc721_self.safe_transfer_from(owner, account, token_id, DATA(true));

  assert_state_after_transfer(@erc721_self, token_id, owner, account);
}

#[test]
#[available_gas(2000000)]
fn test_safeTransferFrom_to_account() {
  let mut erc721_self = setup_and_mint();
  let account = setup_account();

  let token_id = TOKEN_ID;
  let owner = OWNER();

  assert_state_before_transfer(@erc721_self, token_id, owner, account);

  testing::set_caller_address(owner);
  erc721_self.safeTransferFrom(owner, account, token_id, DATA(true));

  assert_state_after_transfer(@erc721_self, token_id, owner, account);
}

#[test]
#[available_gas(2000000)]
fn test_safe_transfer_from_to_account_camel() {
  let mut erc721_self = setup_and_mint();
  let account = setup_camel_account();

  let token_id = TOKEN_ID;
  let owner = OWNER();

  assert_state_before_transfer(@erc721_self, token_id, owner, account);

  testing::set_caller_address(owner);
  erc721_self.safe_transfer_from(owner, account, token_id, DATA(true));

  assert_state_after_transfer(@erc721_self, token_id, owner, account);
}

#[test]
#[available_gas(2000000)]
fn test_safeTransferFrom_to_account_camel() {
  let mut erc721_self = setup_and_mint();
  let account = setup_camel_account();

  let token_id = TOKEN_ID;
  let owner = OWNER();

  assert_state_before_transfer(@erc721_self, token_id, owner, account);

  testing::set_caller_address(owner);
  erc721_self.safeTransferFrom(owner, account, token_id, DATA(true));

  assert_state_after_transfer(@erc721_self, token_id, owner, account);
}

#[test]
#[available_gas(2000000)]
fn test_safe_transfer_from_to_receiver() {
  let mut erc721_self = setup_and_mint();
  let receiver = setup_receiver();

  let token_id = TOKEN_ID;
  let owner = OWNER();

  assert_state_before_transfer(@erc721_self, token_id, owner, receiver);

  testing::set_caller_address(owner);
  erc721_self.safe_transfer_from(owner, receiver, token_id, DATA(true));

  assert_state_after_transfer(@erc721_self, token_id, owner, receiver);
}

#[test]
#[available_gas(2000000)]
fn test_safeTransferFrom_to_receiver() {
  let mut erc721_self = setup_and_mint();
  let receiver = setup_receiver();

  let token_id = TOKEN_ID;
  let owner = OWNER();

  assert_state_before_transfer(@erc721_self, token_id, owner, receiver);

  testing::set_caller_address(owner);
  erc721_self.safeTransferFrom(owner, receiver, token_id, DATA(true));

  assert_state_after_transfer(@erc721_self, token_id, owner, receiver);
}

#[test]
#[available_gas(2000000)]
fn test_safe_transfer_from_to_receiver_camel() {
  let mut erc721_self = setup_and_mint();
  let receiver = setup_camel_receiver();

  let token_id = TOKEN_ID;
  let owner = OWNER();

  assert_state_before_transfer(@erc721_self, token_id, owner, receiver);

  testing::set_caller_address(owner);
  erc721_self.safe_transfer_from(owner, receiver, token_id, DATA(true));

  assert_state_after_transfer(@erc721_self, token_id, owner, receiver);
}

#[test]
#[available_gas(2000000)]
fn test_safeTransferFrom_to_receiver_camel() {
  let mut erc721_self = setup_and_mint();
  let receiver = setup_camel_receiver();

  let token_id = TOKEN_ID;
  let owner = OWNER();

  assert_state_before_transfer(@erc721_self, token_id, owner, receiver);

  testing::set_caller_address(owner);
  erc721_self.safeTransferFrom(owner, receiver, token_id, DATA(true));

  assert_state_after_transfer(@erc721_self, token_id, owner, receiver);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: safe transfer failed', ))]
fn test_safe_transfer_from_to_receiver_failure() {
  let mut erc721_self = setup_and_mint();
  let receiver = setup_receiver();

  let token_id = TOKEN_ID;
  let owner = OWNER();

  testing::set_caller_address(owner);
  erc721_self.safe_transfer_from(owner, receiver, token_id, DATA(false));
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: safe transfer failed', ))]
fn test_safeTransferFrom_to_receiver_failure() {
  let mut erc721_self = setup_and_mint();
  let receiver = setup_receiver();

  let token_id = TOKEN_ID;
  let owner = OWNER();

  testing::set_caller_address(owner);
  erc721_self.safeTransferFrom(owner, receiver, token_id, DATA(false));
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: safe transfer failed', ))]
fn test_safe_transfer_from_to_receiver_failure_camel() {
    let mut erc721_self = setup_and_mint();
    let receiver = setup_camel_receiver();

    let token_id = TOKEN_ID;
    let owner = OWNER();

    testing::set_caller_address(owner);
    erc721_self.safe_transfer_from(owner, receiver, token_id, DATA(false));
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: safe transfer failed', ))]
fn test_safeTransferFrom_to_receiver_failure_camel() {
    let mut erc721_self = setup_and_mint();
    let receiver = setup_camel_receiver();

    let token_id = TOKEN_ID;
    let owner = OWNER();

    testing::set_caller_address(owner);
    erc721_self.safeTransferFrom(owner, receiver, token_id, DATA(false));
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ENTRYPOINT_NOT_FOUND', ))]
fn test_safe_transfer_from_to_non_receiver() {
  let mut erc721_self = setup_and_mint();

  let recipient = utils::deploy(ERC721NonReceiver::TEST_CLASS_HASH, ArrayTrait::new());
  let token_id = TOKEN_ID;
  let owner = OWNER();

  testing::set_caller_address(owner);
  erc721_self.safe_transfer_from(owner, recipient, token_id, DATA(true));
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ENTRYPOINT_NOT_FOUND', ))]
fn test_safeTransferFrom_to_non_receiver() {
  let mut erc721_self = setup_and_mint();

  let recipient = utils::deploy(ERC721NonReceiver::TEST_CLASS_HASH, ArrayTrait::new());
  let token_id = TOKEN_ID;
  let owner = OWNER();

  testing::set_caller_address(owner);
  erc721_self.safeTransferFrom(owner, recipient, token_id, DATA(true));
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid token ID', ))]
fn test_safe_transfer_from_nonexistent() {
  let mut erc721_self = setup();

  erc721_self.safe_transfer_from(ZERO(), RECIPIENT(), TOKEN_ID, DATA(true));
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid token ID', ))]
fn test_safeTransferFrom_nonexistent() {
  let mut erc721_self = setup();

  erc721_self.safeTransferFrom(ZERO(), RECIPIENT(), TOKEN_ID, DATA(true));
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid receiver', ))]
fn test_safe_transfer_from_to_zero() {
  let mut erc721_self = setup_and_mint();

  testing::set_caller_address(OWNER());
  erc721_self.safe_transfer_from(OWNER(), ZERO(), TOKEN_ID, DATA(true));
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid receiver', ))]
fn test_safeTransferFrom_to_zero() {
  let mut erc721_self = setup_and_mint();

  testing::set_caller_address(OWNER());
  erc721_self.safeTransferFrom(OWNER(), ZERO(), TOKEN_ID, DATA(true));
}

#[test]
#[available_gas(2000000)]
fn test_safe_transfer_from_to_owner() {
  let mut erc721_self = setup();
  let owner = setup_receiver();

  let token_id = TOKEN_ID;

  erc721_self.initializer(NAME, SYMBOL);
  erc721_self._mint(owner, token_id);

  assert(erc721_self.owner_of(token_id) == owner, 'Ownership before');
  assert(erc721_self.balance_of(owner) == 1, 'Balance of owner before');

  testing::set_caller_address(owner);
  erc721_self.safe_transfer_from(owner, owner, token_id, DATA(true));

  assert(erc721_self.owner_of(token_id) == owner, 'Ownership after');
  assert(erc721_self.balance_of(owner) == 1, 'Balance of owner after');
}

#[test]
#[available_gas(2000000)]
fn test_safeTransferFrom_to_owner() {
  let mut erc721_self = setup();
  let owner = setup_receiver();

  let token_id = TOKEN_ID;

  erc721_self.initializer(NAME, SYMBOL);
  erc721_self._mint(owner, token_id);

  assert(erc721_self.owner_of(token_id) == owner, 'Ownership before');
  assert(erc721_self.balance_of(owner) == 1, 'Balance of owner before');

  testing::set_caller_address(owner);
  erc721_self.safeTransferFrom(owner, owner, token_id, DATA(true));

  assert(erc721_self.owner_of(token_id) == owner, 'Ownership after');
  assert(erc721_self.balance_of(owner) == 1, 'Balance of owner after');
}

#[test]
#[available_gas(2000000)]
fn test_safe_transfer_from_to_owner_camel() {
  let mut erc721_self = setup();
  let owner = setup_camel_receiver();

  let token_id = TOKEN_ID;

  erc721_self.initializer(NAME, SYMBOL);
  erc721_self._mint(owner, token_id);

  assert(erc721_self.owner_of(token_id) == owner, 'Ownership before');
  assert(erc721_self.balance_of(owner) == 1, 'Balance of owner before');

  testing::set_caller_address(owner);
  erc721_self.safe_transfer_from(owner, owner, token_id, DATA(true));

  assert(erc721_self.owner_of(token_id) == owner, 'Ownership after');
  assert(erc721_self.balance_of(owner) == 1, 'Balance of owner after');
}

#[test]
#[available_gas(2000000)]
fn test_safeTransferFrom_to_owner_camel() {
  let mut erc721_self = setup();
  let owner = setup_camel_receiver();

  let token_id = TOKEN_ID;

  erc721_self.initializer(NAME, SYMBOL);
  erc721_self._mint(owner, token_id);

  assert(erc721_self.owner_of(token_id) == owner, 'Ownership before');
  assert(erc721_self.balance_of(owner) == 1, 'Balance of owner before');

  testing::set_caller_address(owner);
  erc721_self.safeTransferFrom(owner, owner, token_id, DATA(true));

  assert(erc721_self.owner_of(token_id) == owner, 'Ownership after');
  assert(erc721_self.balance_of(owner) == 1, 'Balance of owner after');
}

#[test]
#[available_gas(2000000)]
fn test_safe_transfer_from_approved() {
  let mut erc721_self = setup_and_mint();
  let receiver = setup_receiver();

  let token_id = TOKEN_ID;
  let owner = OWNER();

  assert_state_before_transfer(@erc721_self, token_id, owner, receiver);

  testing::set_caller_address(owner);
  erc721_self.approve(OPERATOR(), token_id);

  testing::set_caller_address(OPERATOR());
  erc721_self.safe_transfer_from(owner, receiver, token_id, DATA(true));

  assert_state_after_transfer(@erc721_self, token_id, owner, receiver);
}

#[test]
#[available_gas(2000000)]
fn test_safeTransferFrom_approved() {
  let mut erc721_self = setup_and_mint();
  let receiver = setup_receiver();

  let token_id = TOKEN_ID;
  let owner = OWNER();

  assert_state_before_transfer(@erc721_self, token_id, owner, receiver);

  testing::set_caller_address(owner);
  erc721_self.approve(OPERATOR(), token_id);

  testing::set_caller_address(OPERATOR());
  erc721_self.safeTransferFrom(owner, receiver, token_id, DATA(true));

  assert_state_after_transfer(@erc721_self, token_id, owner, receiver);
}

#[test]
#[available_gas(2000000)]
fn test_safe_transfer_from_approved_camel() {
  let mut erc721_self = setup_and_mint();
  let receiver = setup_camel_receiver();

  let token_id = TOKEN_ID;
  let owner = OWNER();

  assert_state_before_transfer(@erc721_self, token_id, owner, receiver);

  testing::set_caller_address(owner);
  erc721_self.approve(OPERATOR(), token_id);

  testing::set_caller_address(OPERATOR());
  erc721_self.safe_transfer_from(owner, receiver, token_id, DATA(true));

  assert_state_after_transfer(@erc721_self, token_id, owner, receiver);
}

#[test]
#[available_gas(2000000)]
fn test_safeTransferFrom_approved_camel() {
  let mut erc721_self = setup_and_mint();
  let receiver = setup_camel_receiver();

  let token_id = TOKEN_ID;
  let owner = OWNER();

  assert_state_before_transfer(@erc721_self, token_id, owner, receiver);

  testing::set_caller_address(owner);
  erc721_self.approve(OPERATOR(), token_id);

  testing::set_caller_address(OPERATOR());
  erc721_self.safeTransferFrom(owner, receiver, token_id, DATA(true));

  assert_state_after_transfer(@erc721_self, token_id, owner, receiver);
}

#[test]
#[available_gas(2000000)]
fn test_safe_transfer_from_approved_for_all() {
  let mut erc721_self = setup_and_mint();
  let receiver = setup_receiver();

  let token_id = TOKEN_ID;
  let owner = OWNER();

  assert_state_before_transfer(@erc721_self, token_id, owner, receiver);

  testing::set_caller_address(owner);
  erc721_self.set_approval_for_all(OPERATOR(), true);

  testing::set_caller_address(OPERATOR());
  erc721_self.safe_transfer_from(owner, receiver, token_id, DATA(true));

  assert_state_after_transfer(@erc721_self, token_id, owner, receiver);
}

#[test]
#[available_gas(2000000)]
fn test_safeTransferFrom_approved_for_all() {
  let mut erc721_self = setup_and_mint();
  let receiver = setup_receiver();

  let token_id = TOKEN_ID;
  let owner = OWNER();

  assert_state_before_transfer(@erc721_self, token_id, owner, receiver);

  testing::set_caller_address(owner);
  erc721_self.set_approval_for_all(OPERATOR(), true);

  testing::set_caller_address(OPERATOR());
  erc721_self.safeTransferFrom(owner, receiver, token_id, DATA(true));

  assert_state_after_transfer(@erc721_self, token_id, owner, receiver);
}

#[test]
#[available_gas(2000000)]
fn test_safe_transfer_from_approved_for_all_camel() {
  let mut erc721_self = setup_and_mint();
  let receiver = setup_camel_receiver();

  let token_id = TOKEN_ID;
  let owner = OWNER();

  assert_state_before_transfer(@erc721_self, token_id, owner, receiver);

  testing::set_caller_address(owner);
  erc721_self.set_approval_for_all(OPERATOR(), true);

  testing::set_caller_address(OPERATOR());
  erc721_self.safe_transfer_from(owner, receiver, token_id, DATA(true));

  assert_state_after_transfer(@erc721_self, token_id, owner, receiver);
}

#[test]
#[available_gas(2000000)]
fn test_safeTransferFrom_approved_for_all_camel() {
  let mut erc721_self = setup_and_mint();
  let receiver = setup_camel_receiver();

  let token_id = TOKEN_ID;
  let owner = OWNER();

  assert_state_before_transfer(@erc721_self, token_id, owner, receiver);

  testing::set_caller_address(owner);
  erc721_self.set_approval_for_all(OPERATOR(), true);

  testing::set_caller_address(OPERATOR());
  erc721_self.safeTransferFrom(owner, receiver, token_id, DATA(true));

  assert_state_after_transfer(@erc721_self, token_id, owner, receiver);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: unauthorized caller', ))]
fn test_safe_transfer_from_unauthorized() {
  let mut erc721_self = setup_and_mint();

  testing::set_caller_address(OTHER());
  erc721_self.safe_transfer_from(OWNER(), RECIPIENT(), TOKEN_ID, DATA(true));
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: unauthorized caller', ))]
fn test_safeTransferFrom_unauthorized() {
  let mut erc721_self = setup_and_mint();

  testing::set_caller_address(OTHER());
  erc721_self.safeTransferFrom(OWNER(), RECIPIENT(), TOKEN_ID, DATA(true));
}

//
// _transfer
//

#[test]
#[available_gas(2000000)]
fn test__transfer() {
  let mut erc721_self = setup_and_mint();

  let token_id = TOKEN_ID;
  let owner = OWNER();
  let recipient = RECIPIENT();

  assert_state_before_transfer(@erc721_self, token_id, owner, recipient);
  erc721_self._transfer(owner, recipient, token_id);
  assert_state_after_transfer(@erc721_self, token_id, owner, recipient);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid token ID', ))]
fn test__transfer_nonexistent() {
  let mut erc721_self = setup();

  erc721_self._transfer(ZERO(), RECIPIENT(), TOKEN_ID);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid receiver', ))]
fn test__transfer_to_zero() {
  let mut erc721_self = setup_and_mint();

  erc721_self._transfer(OWNER(), ZERO(), TOKEN_ID);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: wrong sender', ))]
fn test__transfer_from_invalid_owner() {
  let mut erc721_self = setup_and_mint();

  erc721_self._transfer(RECIPIENT(), OWNER(), TOKEN_ID);
}

//
// _mint
//

#[test]
#[available_gas(2000000)]
fn test__mint() {
  let mut erc721_self = setup();

  let recipient = RECIPIENT();
  let token_id = TOKEN_ID;

  assert_state_before_mint(@erc721_self, recipient);
  erc721_self._mint(RECIPIENT(), TOKEN_ID);
  assert_state_after_mint(@erc721_self, token_id, recipient);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid receiver', ))]
fn test__mint_to_zero() {
  let mut erc721_self = setup_and_mint();

  erc721_self._mint(ZERO(), TOKEN_ID);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: token already minted', ))]
fn test__mint_already_exist() {
  let mut erc721_self = setup_and_mint();

  erc721_self._mint(RECIPIENT(), TOKEN_ID);
}

//
// _safe_mint
//

#[test]
#[available_gas(2000000)]
fn test__safe_mint_to_receiver() {
  let mut erc721_self = setup();
  let recipient = setup_receiver();

  let token_id = TOKEN_ID;

  assert_state_before_mint(@erc721_self, recipient);
  erc721_self._safe_mint(recipient, token_id, DATA(true));
  assert_state_after_mint(@erc721_self, token_id, recipient);
}

#[test]
#[available_gas(2000000)]
fn test__safe_mint_to_receiver_camel() {
  let mut erc721_self = setup();
  let recipient = setup_camel_receiver();

  let token_id = TOKEN_ID;

  assert_state_before_mint(@erc721_self, recipient);
  erc721_self._safe_mint(recipient, token_id, DATA(true));
  assert_state_after_mint(@erc721_self, token_id, recipient);
}

#[test]
#[available_gas(2000000)]
fn test__safe_mint_to_account() {
  let mut erc721_self = setup();
  let account = setup_account();

  let token_id = TOKEN_ID;

  assert_state_before_mint(@erc721_self, account);
  erc721_self._safe_mint(account, token_id, DATA(true));
  assert_state_after_mint(@erc721_self, token_id, account);
}

#[test]
#[available_gas(2000000)]
fn test__safe_mint_to_account_camel() {
  let mut erc721_self = setup();
  let account = setup_camel_account();

  let token_id = TOKEN_ID;

  assert_state_before_mint(@erc721_self, account);
  erc721_self._safe_mint(account, token_id, DATA(true));
  assert_state_after_mint(@erc721_self, token_id, account);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ENTRYPOINT_NOT_FOUND', ))]
fn test__safe_mint_to_non_receiver() {
  let mut erc721_self = setup();

  let recipient = utils::deploy(ERC721NonReceiver::TEST_CLASS_HASH, ArrayTrait::new());
  let token_id = TOKEN_ID;

  assert_state_before_mint(@erc721_self, recipient);
  erc721_self._safe_mint(recipient, token_id, DATA(true));
  assert_state_after_mint(@erc721_self, token_id, recipient);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: safe mint failed', ))]
fn test__safe_mint_to_receiver_failure() {
  let mut erc721_self = setup();
  let recipient = setup_receiver();

  let token_id = TOKEN_ID;

  assert_state_before_mint(@erc721_self, recipient);
  erc721_self._safe_mint(recipient, token_id, DATA(false));
  assert_state_after_mint(@erc721_self, token_id, recipient);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: safe mint failed', ))]
fn test__safe_mint_to_receiver_failure_camel() {
  let mut erc721_self = setup();
  let recipient = setup_camel_receiver();

  let token_id = TOKEN_ID;

  assert_state_before_mint(@erc721_self, recipient);
  erc721_self._safe_mint(recipient, token_id, DATA(false));
  assert_state_after_mint(@erc721_self, token_id, recipient);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid receiver', ))]
fn test__safe_mint_to_zero() {
  let mut erc721_self = setup_and_mint();

  erc721_self._safe_mint(ZERO(), TOKEN_ID, DATA(true));
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: token already minted', ))]
fn test__safe_mint_already_exist() {
  let mut erc721_self = setup_and_mint();

  erc721_self._safe_mint(RECIPIENT(), TOKEN_ID, DATA(true));
}

//
// _burn
//

#[test]
#[available_gas(2000000)]
fn test__burn() {
  let mut erc721_self = setup_and_mint();

  erc721_self._approve(OTHER(), TOKEN_ID);

  assert(erc721_self.owner_of(TOKEN_ID) == OWNER(), 'Ownership before');
  assert(erc721_self.balance_of(OWNER()) == 1, 'Balance of owner before');
  assert(erc721_self.get_approved(TOKEN_ID) == OTHER(), 'Approval before');

  erc721_self._burn(TOKEN_ID);

  assert(erc721_self._owners.read(TOKEN_ID) == ZERO(), 'Ownership after');
  assert(erc721_self.balance_of(OWNER()) == 0, 'Balance of owner after');
  assert(erc721_self._token_approvals.read(TOKEN_ID) == ZERO(), 'Approval after');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid token ID', ))]
fn test__burn_nonexistent() {
  let mut erc721_self = setup();

  erc721_self._burn(TOKEN_ID);
}

//
// _set_token_uri
//

#[test]
#[available_gas(2000000)]
fn test__set_token_uri() {
  let mut erc721_self = setup_and_mint();

  assert(erc721_self.token_uri(TOKEN_ID) == 0, 'URI should be 0');
  erc721_self._set_token_uri(TOKEN_ID, URI);
  assert(erc721_self.token_uri(TOKEN_ID) == URI, 'URI should be set');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid token ID', ))]
fn test__set_token_uri_nonexistent() {
  let mut erc721_self = setup();

  erc721_self._set_token_uri(TOKEN_ID, URI);
}

//
// Helpers
//

fn assert_state_before_transfer(
  erc721_self: @ERC721ContractState,
  token_id: u256,
  owner: starknet::ContractAddress,
  recipient: starknet::ContractAddress
) {
  assert(erc721_self.owner_of(token_id) == owner, 'Ownership before');
  assert(erc721_self.balance_of(owner) == 1, 'Balance of owner before');
  assert(erc721_self.balance_of(recipient) == 0, 'Balance of recipient before');
}

fn assert_state_after_transfer(
  erc721_self: @ERC721ContractState,
  token_id: u256,
  owner: starknet::ContractAddress,
  recipient: starknet::ContractAddress
) {
  assert(erc721_self.owner_of(token_id) == recipient, 'Ownership after');
  assert(erc721_self.balance_of(owner) == 0, 'Balance of owner after');
  assert(erc721_self.balance_of(recipient) == 1, 'Balance of recipient after');
  assert(erc721_self.get_approved(token_id) == ZERO(), 'Approval not implicitly reset');
}

fn assert_state_before_mint(erc721_self: @ERC721ContractState, recipient: starknet::ContractAddress) {
  assert(erc721_self.balance_of(recipient) == 0, 'Balance of recipient before');
}

fn assert_state_after_mint(erc721_self: @ERC721ContractState,  token_id: u256, recipient: starknet::ContractAddress) {
  assert(erc721_self.owner_of(token_id) == recipient, 'Ownership after');
  assert(erc721_self.balance_of(recipient) == 1, 'Balance of recipient after');
  assert(erc721_self.get_approved(token_id) == ZERO(), 'Approval implicitly set');
}
