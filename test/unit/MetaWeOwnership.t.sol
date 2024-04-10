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

  function test_mint(address randomReceiver) public {
    vm.assume(randomReceiver != address(0));
    vm.assume(!_isContract(randomReceiver));

    string memory nickname = "nickname";
    uint256 expectedTokenId = ownership.nextTokenId();
    vm.prank(contractOwner);
    uint256 tokenId = ownership.mint(randomReceiver, nickname);
    assertEq(tokenId, expectedTokenId);
  }

  function test_mintWithoutOwnerReverts(address randomMinter) public {
    vm.assume(randomMinter != address(0));
    vm.assume(!_isContract(randomMinter));

    string memory nickname = "nickname";
    vm.prank(randomMinter);
    vm.expectRevert();
    ownership.mint(randomMinter, nickname);
  }

  function test_doubleMintReverts(address randomReceiver) public {
    vm.assume(randomReceiver != address(0));
    vm.assume(!_isContract(randomReceiver));

    string memory nickname = "nickname";
    vm.prank(contractOwner);
    ownership.mint(randomReceiver, nickname);
    vm.expectRevert();
    ownership.mint(randomReceiver, nickname);
  }

  /*//////////////////////////////////////////////////////////////
                            HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/
  // Borrowed from an Old Openzeppelin codebase
  function _isContract(address account) internal view returns (bool) {
    // This method relies on extcodesize, which returns 0 for contracts in
    // construction, since the code is only stored at the end of the
    // constructor execution.

    uint256 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }
}
