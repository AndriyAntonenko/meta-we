// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";

import { AccountsStorage } from "../../src/base/AccountsStorage.sol";
import { IERC6551Executable } from "../../src/erc-6551/IERC6551Executable.sol";
import { MetaWeHub } from "../../src/MetaWeHub.sol";
import { MetaWeFollowNFT } from "../../src/MetaWeFollowNFT.sol";
import { MetaWeAccount } from "../../src/MetaWeAccount.sol";
import { MetaWeRegistry } from "../../src/MetaWeRegistry.sol";
import { MetaWeOwnership } from "../../src/MetaWeOwnership.sol";
import { MetaWeFollowNFT } from "../../src/MetaWeFollowNFT.sol";

contract MetaWeHubTest is Test {
  MetaWeHub public hub;
  address public user = makeAddr("user");
  address public followee = makeAddr("followee");

  function setUp() public {
    address accountImpl = address(new MetaWeAccount());
    address registry = address(new MetaWeRegistry(address(this)));
    address ownership = address(new MetaWeOwnership(address(this)));
    address followNftImpl = address(new MetaWeFollowNFT());

    hub = new MetaWeHub(accountImpl, registry, ownership, followNftImpl);

    MetaWeRegistry(registry).transferOwnership(address(hub));
    MetaWeOwnership(ownership).transferOwnership(address(hub));
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

    address followNFT = hub.getFollowNftAddress(account);
    assertEq(MetaWeFollowNFT(followNFT).followee(), account);
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

    MetaWeFollowNFT.FollowingInfo[] memory followers =
      MetaWeFollowNFT(hub.getFollowNftAddress(followeeAccount)).getFollowersList();

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
    vm.expectRevert(
      abi.encodeWithSelector(AccountsStorage.AccountsStorage__AccountDoesNotExist.selector, nonAccountUser)
    );
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

    MetaWeFollowNFT.FollowingInfo[] memory followers =
      MetaWeFollowNFT(hub.getFollowNftAddress(followeeAccount)).getFollowersList();

    assertEq(followers.length, 0);
    assertEq(MetaWeFollowNFT(hub.getFollowNftAddress(followeeAccount)).getTokenIdByFollower(userAccount), 0);
  }
}
