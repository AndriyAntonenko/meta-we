// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";

import { MetaWeOwnership } from "../../src/MetaWeOwnership.sol";
import { MetaWeRegistry } from "../../src/MetaWeRegistry.sol";
import { MetaWeAccount } from "../../src/MetaWeAccount.sol";

contract MetaWeRegistryTest is Test {
  address public owner = makeAddr("owner");
  MetaWeAccount public accountImpl;
  MetaWeRegistry public registry;
  MetaWeOwnership public ownership;

  function setUp() public {
    accountImpl = new MetaWeAccount();
    registry = new MetaWeRegistry(owner);
    ownership = new MetaWeOwnership(owner);
  }

  function test_createAccount() public {
    bytes32 salt = keccak256(abi.encodePacked("nickname"));
    uint256 chainId = block.chainid;
    uint256 tokenId = 1;

    address expectedAccount = registry.account(address(accountImpl), salt, chainId, address(ownership), tokenId);

    vm.prank(owner);
    address account = registry.createAccount(address(accountImpl), salt, chainId, address(ownership), tokenId);

    assertEq(account, expectedAccount);
  }

  function test_createAccountWithoutOwnerReverts() public {
    bytes32 salt = keccak256(abi.encodePacked("nickname"));
    uint256 chainId = block.chainid;
    uint256 tokenId = 1;

    vm.prank(makeAddr("random"));
    vm.expectRevert();
    registry.createAccount(address(accountImpl), salt, chainId, address(ownership), tokenId);
  }
}
