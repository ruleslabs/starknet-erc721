use array::ArrayTrait;
use starknet::SyscallResultTrait;

// locals
use rules_utils::utils::serde::SerdeTraitExt;
use rules_utils::utils::try_selector_with_fallback;
use rules_utils::utils::unwrap_and_cast::UnwrapAndCast;

mod selectors {
  const name: felt252 = 0x361458367e696363fbcc70777d07ebbd2394e89fd0adcaf147faccd1d294d60;

  const symbol: felt252 = 0x216b05c387bab9ac31918a3e61672f4618601f3c598a2f3f2710f37053e1ea4;

  const token_uri: felt252 = 0x226ad7e84c1fe08eb4c525ed93cccadf9517670341304571e66f7c4f95cbe54;
  const tokenUri: felt252 = 0x362dec5b8b67ab667ad08e83a2c3ba1db7fdb4ab8dc3a33c057c4fddec8d3de;

  const balance_of: felt252 = 0x35a73cd311a05d46deda634c5ee045db92f811b4e74bca4437fcb5302b7af33;
  const balanceOf: felt252 = 0x2e4263afad30923c891518314c3c95dbe830a16874e8abc5777a9a20b54c76e;

  const owner_of: felt252 = 0x3552df12bdc6089cf963c40c4cf56fbfd4bd14680c244d1c5494c2790f1ea5c;
  const ownerOf: felt252 = 0x2962ba17806af798afa6eaf4aa8c93a9fb60a3e305045b6eea33435086cae9;

  const get_approved: felt252 = 0x309065f1424d76d4a4ace2ff671391d59536e0297409434908d38673290a749;
  const getApproved: felt252 = 0xb180e2fe9f14914416216da76338ac0beb980443725c802af615f8431fdb1e;

  const is_approved_for_all: felt252 = 0x2aa3ea196f9b8a4f65613b67fcf185e69d8faa9601a3382871d15b3060e30dd;
  const isApprovedForAll: felt252 = 0x21cdf9aedfed41bc4485ae779fda471feca12075d9127a0fc70ac6b3b3d9c30;

  const approve: felt252 = 0x219209e083275171774dab1df80982e9df2096516f06319c5c6d71ae0a8480c;

  const set_approval_for_all: felt252 = 0xd86ca3d41635e20c180181046b11abcf19e1bdef3dcaa4c180300ccca1813f;
  const setApprovalForAll: felt252 = 0x2d4c8ea4c8fb9f571d1f6f9b7692fff8e5ceaf73b1df98e7da8c1109b39ae9a;

  const transfer_from: felt252 = 0x3704ffe8fba161be0e994951751a5033b1462b918ff785c0a636be718dfdb68;
  const transferFrom: felt252 = 0x41b033f4a31df8067c24d1e9b550a2ce75fd4a29e1147af9752174f0e6cb20;

  const safe_transfer_from: felt252 = 0x16f0218b33b5cf273196787d7cf139a9ad13d58e6674dcdce722b3bf8389863;
  const safeTransferFrom: felt252 = 0x19d59d013d4aa1a8b1ce4c8299086f070733b453c02d0dc46e735edc04d6444;

  const supports_interface: felt252 = 0xfe80f537b66d12a00b6d3c072b44afbb716e78dde5c3f0ef116ee93d3e3283;
  const supportsInterface: felt252 = 0x29e211664c0b63c79638fbea474206ca74016b3e9a3dc4f9ac300ffd8bdf2cd;
}

#[derive(Copy, Drop)]
struct DualCaseERC721 {
  contract_address: starknet::ContractAddress
}

trait DualCaseERC721Trait {
  fn name(self: @DualCaseERC721) -> felt252;

  fn symbol(self: @DualCaseERC721) -> felt252;

  fn token_uri(self: @DualCaseERC721, token_id: u256) -> felt252;

  fn balance_of(self: @DualCaseERC721, account: starknet::ContractAddress) -> u256;

  fn owner_of(self: @DualCaseERC721, token_id: u256) -> starknet::ContractAddress;

  fn get_approved(self: @DualCaseERC721, token_id: u256) -> starknet::ContractAddress;

  fn approve(self: @DualCaseERC721, to: starknet::ContractAddress, token_id: u256);

  fn set_approval_for_all(self: @DualCaseERC721, operator: starknet::ContractAddress, approved: bool);

  fn transfer_from(
    self: @DualCaseERC721,
    from: starknet::ContractAddress,
    to: starknet::ContractAddress,
    token_id: u256
  );

  fn is_approved_for_all(
    self: @DualCaseERC721,
    owner: starknet::ContractAddress,
    operator: starknet::ContractAddress
  ) -> bool;

  fn safe_transfer_from(
    self: @DualCaseERC721,
    from: starknet::ContractAddress,
    to: starknet::ContractAddress,
    token_id: u256,
    data: Span<felt252>
  );

  fn supports_interface(self: @DualCaseERC721, interface_id: felt252) -> bool;
}

impl DualCaseERC721Impl of DualCaseERC721Trait {
  fn name(self: @DualCaseERC721) -> felt252 {
    starknet::call_contract_syscall(*self.contract_address, selectors::name, ArrayTrait::<felt252>::new().span())
      .unwrap_and_cast()
  }

  fn symbol(self: @DualCaseERC721) -> felt252 {
    starknet::call_contract_syscall(*self.contract_address, selectors::symbol, ArrayTrait::<felt252>::new().span())
      .unwrap_and_cast()
  }

  fn token_uri(self: @DualCaseERC721, token_id: u256) -> felt252 {
    let mut args = ArrayTrait::new();
    args.append_serde(token_id);

    try_selector_with_fallback(*self.contract_address, selectors::token_uri, selectors::tokenUri, args.span())
      .unwrap_and_cast()
  }

  fn balance_of(self: @DualCaseERC721, account: starknet::ContractAddress) -> u256 {
    let mut args = ArrayTrait::new();
    args.append_serde(account);

    try_selector_with_fallback(*self.contract_address, selectors::balance_of, selectors::balanceOf, args.span())
      .unwrap_and_cast()
  }

  fn owner_of(self: @DualCaseERC721, token_id: u256) -> starknet::ContractAddress {
    let mut args = ArrayTrait::new();
    args.append_serde(token_id);

    try_selector_with_fallback(*self.contract_address, selectors::owner_of, selectors::ownerOf, args.span())
      .unwrap_and_cast()
  }

  fn get_approved(self: @DualCaseERC721, token_id: u256) -> starknet::ContractAddress {
    let mut args = ArrayTrait::new();
    args.append_serde(token_id);

    try_selector_with_fallback(*self.contract_address, selectors::get_approved, selectors::getApproved, args.span())
      .unwrap_and_cast()
  }

  fn is_approved_for_all(
    self: @DualCaseERC721,
    owner: starknet::ContractAddress,
    operator: starknet::ContractAddress
  ) -> bool {
    let mut args = ArrayTrait::new();
    args.append_serde(owner);
    args.append_serde(operator);

    try_selector_with_fallback(
      *self.contract_address,
      selectors::is_approved_for_all,
      selectors::isApprovedForAll,
      args.span()
    ).unwrap_and_cast()
  }

  fn approve(self: @DualCaseERC721, to: starknet::ContractAddress, token_id: u256) {
    let mut args = ArrayTrait::new();
    args.append_serde(to);
    args.append_serde(token_id);

    starknet::call_contract_syscall(*self.contract_address, selectors::approve, args.span()).unwrap_syscall();
  }

  fn set_approval_for_all(self: @DualCaseERC721, operator: starknet::ContractAddress, approved: bool) {
    let mut args = ArrayTrait::new();
    args.append_serde(operator);
    args.append_serde(approved);

    try_selector_with_fallback(
      *self.contract_address,
      selectors::set_approval_for_all,
      selectors::setApprovalForAll,
      args.span()
    ).unwrap_syscall();
  }

  fn transfer_from(
    self: @DualCaseERC721,
    from: starknet::ContractAddress,
    to: starknet::ContractAddress,
    token_id: u256
  ) {
    let mut args = ArrayTrait::new();
    args.append_serde(from);
    args.append_serde(to);
    args.append_serde(token_id);

    try_selector_with_fallback(*self.contract_address, selectors::transfer_from, selectors::transferFrom, args.span())
      .unwrap_syscall();
  }

  fn safe_transfer_from(
    self: @DualCaseERC721,
    from: starknet::ContractAddress,
    to: starknet::ContractAddress,
    token_id: u256,
    data: Span<felt252>
  ) {
    let mut args = ArrayTrait::new();
    args.append_serde(from);
    args.append_serde(to);
    args.append_serde(token_id);
    args.append_serde(data);

    try_selector_with_fallback(
      *self.contract_address,
      selectors::safe_transfer_from,
      selectors::safeTransferFrom,
      args.span()
    ).unwrap_syscall();
  }

  fn supports_interface(self: @DualCaseERC721, interface_id: felt252) -> bool {
    let mut args = ArrayTrait::new();
    args.append_serde(interface_id);

    try_selector_with_fallback(
      *self.contract_address,
      selectors::supports_interface,
      selectors::supportsInterface,
      args.span()
    ).unwrap_and_cast()
  }
}
