use array::ArrayTrait;
use starknet::SyscallResultTrait;
use rules_utils::utils::try_selector_with_fallback;
use rules_utils::utils::serde::SerdeTraitExt;
use rules_utils::utils::unwrap_and_cast::UnwrapAndCast;

mod selectors {
  const on_erc721_received: felt252 = 0x38c7ee9f0855dfe219aea022b141d9b2ec0f6b68395d221c3f331c7ca4fb608;
  const onERC721Received: felt252 = 0xfa119a8fafc6f1a02deb36fe5efbcc4929ef2021e50cf1cb6d1a780ccd009b;
}

#[derive(Copy, Drop)]
struct DualCaseERC721Receiver {
  contract_address: starknet::ContractAddress
}

trait DualCaseERC721ReceiverTrait {
  fn on_erc721_received(
    self: @DualCaseERC721Receiver,
    operator: starknet::ContractAddress,
    from: starknet::ContractAddress,
    token_id: u256,
    data: Span<felt252>
  ) -> felt252;
}

impl DualCaseERC721ReceiverImpl of DualCaseERC721ReceiverTrait {
  fn on_erc721_received(
    self: @DualCaseERC721Receiver,
    operator: starknet::ContractAddress,
    from: starknet::ContractAddress,
    token_id: u256,
    data: Span<felt252>
  ) -> felt252 {
    let mut args = ArrayTrait::new();
    args.append_serde(operator);
    args.append_serde(from);
    args.append_serde(token_id);
    args.append_serde(data);

    try_selector_with_fallback(
      *self.contract_address,
      selectors::on_erc721_received,
      selectors::onERC721Received,
      args.span()
    ).unwrap_and_cast()
  }
}
