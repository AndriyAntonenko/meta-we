// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";

import { MetaWeOwnership } from "../../src/MetaWeOwnership.sol";

contract MetaWeOwnershipTest is Test {
  MetaWeOwnership public ownership;
  address public contractOwner = makeAddr("contractOwner");

  function setUp() public {
    ownership = new MetaWeOwnership(contractOwner);
  }

  function test_mint() public {
    address randomReceiver = makeAddr("randomReceiver");
    string memory nickname = "nickname";
    uint256 expectedTokenId = ownership.nextTokenId();
    vm.prank(contractOwner);
    uint256 tokenId = ownership.mint(randomReceiver, nickname);
    assertEq(tokenId, expectedTokenId);
  }

  function test_mintWithoutOwnerReverts() public {
    address randomMinter = makeAddr("randomMinter");
    string memory nickname = "nickname";
    vm.prank(randomMinter);
    vm.expectRevert();
    ownership.mint(randomMinter, nickname);
  }

  function test_doubleMintReverts() public {
    address randomReceiver = makeAddr("randomReceiver");
    string memory nickname = "nickname";
    vm.prank(contractOwner);
    ownership.mint(randomReceiver, nickname);
    vm.expectRevert();
    ownership.mint(randomReceiver, nickname);
  }
}
