use array::ArrayTrait;

// locals
use super::mocks::erc721_receiver_mocks::{
  SUCCESS,
  FAILURE,
  SnakeERC721ReceiverMock,
  CamelERC721ReceiverMock,
  SnakeERC721ReceiverPanicMock,
  CamelERC721ReceiverPanicMock,
};
use super::mocks::non_implementing_mock::NonImplementingMock;

use erc721::erc721::interface::IERC721_RECEIVER_ID;

use super::utils;

// Dispatchers
use erc721::erc721::interface::{
  IERC721ReceiverDispatcher,
  IERC721ReceiverDispatcherTrait,
  IERC721ReceiverCamelDispatcher,
  IERC721ReceiverCamelDispatcherTrait,
};
use erc721::erc721::dual_erc721_receiver::{ DualCaseERC721Receiver, DualCaseERC721ReceiverTrait };

//
// Constants
//

const TOKEN_ID: u256 = 7;

fn DATA(success: bool) -> Span<felt252> {
  if success {
    array![SUCCESS].span()
  } else {
    array![FAILURE].span()
  }
}

fn OWNER() -> starknet::ContractAddress {
  starknet::contract_address_const::<10>()
}

fn OPERATOR() -> starknet::ContractAddress {
  starknet::contract_address_const::<20>()
}

//
// Setup
//

fn setup_snake_receiver() -> (DualCaseERC721Receiver, IERC721ReceiverDispatcher) {
  let contract_address = utils::deploy(SnakeERC721ReceiverMock::TEST_CLASS_HASH, calldata: array![]);

  (DualCaseERC721Receiver { contract_address }, IERC721ReceiverDispatcher { contract_address })
}

fn setup_camel_receiver() -> (DualCaseERC721Receiver, IERC721ReceiverCamelDispatcher) {
  let contract_address = utils::deploy(CamelERC721ReceiverMock::TEST_CLASS_HASH, calldata: array![]);

  (DualCaseERC721Receiver { contract_address }, IERC721ReceiverCamelDispatcher { contract_address })
}

fn setup_non_erc721_receiver() -> DualCaseERC721Receiver {
  let contract_address = utils::deploy(NonImplementingMock::TEST_CLASS_HASH, calldata: array![]);

  DualCaseERC721Receiver { contract_address }
}

fn setup_erc721_receiver_panic() -> (DualCaseERC721Receiver, DualCaseERC721Receiver) {
  let snake_contract_address = utils::deploy(
    SnakeERC721ReceiverPanicMock::TEST_CLASS_HASH,
    calldata: array![]
  );
  let camel_contract_address = utils::deploy(
    CamelERC721ReceiverPanicMock::TEST_CLASS_HASH,
    calldata: array![]
  );

  (
    DualCaseERC721Receiver { contract_address: snake_contract_address },
    DualCaseERC721Receiver { contract_address: camel_contract_address }
  )
}

//
// snake_case target
//

#[test]
#[available_gas(20000000)]
fn test_dual_on_erc721_received() {
  let (dispatcher, _) = setup_snake_receiver();

  assert(
    dispatcher.on_erc721_received(OPERATOR(), OWNER(), TOKEN_ID, DATA(true)) == IERC721_RECEIVER_ID,
    'Should return interface id'
  );
}

#[test]
#[available_gas(20000000)]
#[should_panic(expected: ('Some error', 'ENTRYPOINT_FAILED', ))]
fn test_dual_on_erc721_received_exists_and_panics() {
  let (dispatcher, _) = setup_erc721_receiver_panic();

  dispatcher.on_erc721_received(OPERATOR(), OWNER(), TOKEN_ID, DATA(true));
}

//
// camelCase target
//

#[test]
#[available_gas(20000000)]
fn test_dual_onERC721Received() {
  let (dispatcher, _) = setup_camel_receiver();

  assert(
    dispatcher
      .on_erc721_received(OPERATOR(), OWNER(), TOKEN_ID, DATA(true)) == IERC721_RECEIVER_ID,
    'Should return interface id'
  );
}

#[test]
#[available_gas(20000000)]
#[should_panic(expected: ('Some error', 'ENTRYPOINT_FAILED', ))]
fn test_dual_onERC721Received_exists_and_panics() {
  let (_, dispatcher) = setup_erc721_receiver_panic();

  dispatcher.on_erc721_received(OPERATOR(), OWNER(), TOKEN_ID, DATA(true));
}

//
// Non ERC721 receiver
//

#[test]
#[available_gas(20000000)]
#[should_panic(expected: ('ENTRYPOINT_NOT_FOUND', ))]
fn test_dual_no_on_erc721_received() {
  let dispatcher = setup_non_erc721_receiver();

  dispatcher.on_erc721_received(OPERATOR(), OWNER(), TOKEN_ID, DATA(true));
}
