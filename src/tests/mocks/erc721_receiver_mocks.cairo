mod snake_erc721_receiver_mock;
use snake_erc721_receiver_mock::SnakeERC721ReceiverMock;

mod camel_erc721_receiver_mock;
use camel_erc721_receiver_mock::CamelERC721ReceiverMock;

mod erc721_receiver_panic_mocks;
use erc721_receiver_panic_mocks::{ SnakeERC721ReceiverPanicMock, CamelERC721ReceiverPanicMock };

const SUCCESS: felt252 = 'SUCCESS';
const FAILURE: felt252 = 'FAILURE';

#[starknet::contract]
mod ERC721NonReceiver {
  #[storage]
  struct Storage { }
}
