// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";

import { Deploy } from "../../script/Deploy.s.sol";
import { Errors } from "../../src/libraries/Errors.sol";
import { IERC6551Executable } from "../../src/erc-6551/IERC6551Executable.sol";
import { MetaWeHub } from "../../src/MetaWeHub.sol";
import { MetaWeFollowNFT } from "../../src/MetaWeFollowNFT.sol";
import { MetaWeAccount } from "../../src/MetaWeAccount.sol";
import { MetaWeRegistry } from "../../src/MetaWeRegistry.sol";
import { MetaWeOwnership } from "../../src/MetaWeOwnership.sol";
import { MetaWeFollowNFT } from "../../src/MetaWeFollowNFT.sol";
import { AccountsLib, FollowingLib } from "../../src/libraries/DataTypes.sol";
import { IFollowNFT } from "../../src/interfaces/IFollowNFT.sol";

contract MetaWeHubTest is Test {
  MetaWeHub public hub;
  Deploy public deployer;
  address public user = makeAddr("user");
  address public followee = makeAddr("followee");

  function setUp() public {
    deployer = new Deploy();
    (,,,, hub) = deployer.run();
  }

  function test_createAccount() public {
    string memory nickname = "nickname";
    (uint256 predictedTokenId, address predictedAccount) = hub.predictAccountAddress(nickname);

    vm.prank(user);
    (uint256 tokenId, address account) = hub.createAccount(nickname);

    assertEq(tokenId, predictedTokenId);
    assertEq(account, predictedAccount);
  }

  function test_getFolloweeNFT() public {
    string memory nickname = "nickname";
    vm.prank(user);
    (, address account) = hub.createAccount(nickname);

    IFollowNFT followNFT = hub.getFollowNftAddress(account);
    assertEq(followNFT.followee(), account);
  }

  function test_follow() public {
    string memory nickname1 = "nickname1";
    string memory nickname2 = "nickname2";

    vm.prank(user);
    (, address userAccount) = hub.createAccount(nickname1);

    vm.prank(followee);
    (, address followeeAccount) = hub.createAccount(nickname2);

    bytes memory data = abi.encodeWithSelector(bytes4(keccak256("follow(address)")), followeeAccount);
    vm.prank(user);
    MetaWeAccount(payable(userAccount)).execute(address(hub), 0, data, IERC6551Executable.Op.CALL);

    FollowingLib.FollowingInfo[] memory followers = hub.getFollowNftAddress(followeeAccount).getFollowersList();

    assertEq(followers.length, 1);
    assertEq(followers[0].follower, userAccount);
    assertEq(followers[0].timestamp, block.timestamp);
  }

  function test_followRevertsForNonExistentAccount() public {
    string memory nickname = "nickname";
    vm.prank(followee);
    (, address followeeAccount) = hub.createAccount(nickname);

    address nonAccountUser = makeAddr("nonAccountUser");
    vm.startPrank(nonAccountUser);
    vm.expectRevert(abi.encodeWithSelector(Errors.AccountsStorage__AccountDoesNotExist.selector, nonAccountUser));
    hub.follow(followeeAccount);
    vm.stopPrank();
  }

  function test_unfollow() public {
    string memory nickname1 = "nickname1";
    string memory nickname2 = "nickname2";

    vm.prank(user);
    (, address userAccount) = hub.createAccount(nickname1);

    vm.prank(followee);
    (, address followeeAccount) = hub.createAccount(nickname2);

    bytes memory data = abi.encodeWithSelector(bytes4(keccak256("follow(address)")), followeeAccount);
    vm.prank(user);
    MetaWeAccount(payable(userAccount)).execute(address(hub), 0, data, IERC6551Executable.Op.CALL);

    bytes memory unfollowData = abi.encodeWithSelector(bytes4(keccak256("unfollow(address)")), followeeAccount);
    vm.prank(user);
    MetaWeAccount(payable(userAccount)).execute(address(hub), 0, unfollowData, IERC6551Executable.Op.CALL);

    FollowingLib.FollowingInfo[] memory followers = hub.getFollowNftAddress(followeeAccount).getFollowersList();

    assertEq(followers.length, 0);
    assertEq(hub.getFollowNftAddress(followeeAccount).getTokenIdByFollower(userAccount), 0);
  }

  function test_getOwnedAccounts() public {
    string memory nickname1 = "nickname1";
    string memory nickname2 = "nickname2";

    vm.prank(user);
    (uint256 tokenId1,) = hub.createAccount(nickname1);

    vm.prank(user);
    (uint256 tokenId2,) = hub.createAccount(nickname2);

    address otherUser = makeAddr("otherUser");
    vm.prank(otherUser);
    hub.createAccount("otherUser");

    AccountsLib.Account[] memory accounts = hub.getOwnedAccounts(user);
    assertEq(accounts.length, 2);
    assertEq(tokenId1, accounts[0].tokenId);
    assertEq(tokenId2, accounts[1].tokenId);
  }
}
