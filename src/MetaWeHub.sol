// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { MetaWeRegistry } from "./MetaWeRegistry.sol";
import { MetaWeOwnership } from "./MetaWeOwnership.sol";
import { MetaWeAccount } from "./MetaWeAccount.sol";

contract MetaWeHub {
  MetaWeRegistry private registry;
  MetaWeOwnership private ownership;
  MetaWeAccount private accountImpl;

  constructor() {
    accountImpl = new MetaWeAccount();
    registry = new MetaWeRegistry(address(this));
    ownership = new MetaWeOwnership(address(this));
  }

  function createAccount(string calldata nickname) public returns (uint256 tokenId, address account) {
    bytes32 salt = keccak256(abi.encodePacked(nickname));
    tokenId = ownership.mint(msg.sender, nickname);
    account = registry.createAccount(address(accountImpl), salt, block.chainid, address(ownership), tokenId);
  }

  function predictAccountAddress(string calldata nickname) public view returns (uint256 tokenId, address account) {
    bytes32 salt = keccak256(abi.encodePacked(nickname));
    tokenId = ownership.nextTokenId();
    account = registry.account(address(accountImpl), salt, block.chainid, address(ownership), tokenId);
  }

  function getOwnershipAddress() public view returns (address) {
    return address(ownership);
  }

  function getRegistryAddress() public view returns (address) {
    return address(registry);
  }

  function getAccountImplAddress() public view returns (address) {
    return address(accountImpl);
  }
}
