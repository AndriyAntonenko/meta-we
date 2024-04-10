// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";

import { MetaWeHub } from "../../src/MetaWeHub.sol";

contract MetaWeHubTest is Test {
  MetaWeHub public hub;
  address public user = makeAddr("user");

  function setUp() public {
    hub = new MetaWeHub();
  }

  function test_createAccount() public {
    string memory nickname = "nickname";
    (uint256 predictedTokenId, address predictedAccount) = hub.predictAccountAddress(nickname);

    vm.prank(user);
    (uint256 tokenId, address account) = hub.createAccount(nickname);

    assertEq(tokenId, predictedTokenId);
    assertEq(account, predictedAccount);
  }
}
