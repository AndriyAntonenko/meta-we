// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { MetaWeFollowNFT } from "../../src/MetaWeFollowNFT.sol";
import { IFollowNFT } from "../../src/interfaces/IFollowNFT.sol";

contract MetaWeFollowNFTTest is Test {
  event Follow(address indexed follower, uint256 tokenId, uint256 timestamp);
  event Unfollow(address indexed follower, uint256 tokenId, uint256 timestamp);

  string public constant nickname = "nickname";
  address public immutable hub = makeAddr("hub");
  address public immutable folowee = makeAddr("followee");
  address public immutable follower = makeAddr("follower");

  MetaWeFollowNFT public followNFT;

  function setUp() public {
    followNFT = new MetaWeFollowNFT();
    followNFT.initialize(folowee, hub, nickname);
  }

  function test_follow() public {
    uint256 expectedTokenId = followNFT.nextTokenId();
    vm.prank(hub);
    followNFT.follow(follower);
    assertEq(followNFT.ownerOf(expectedTokenId), follower);
  }

  function test_followEmitFollowEvent() public {
    vm.expectEmit(true, true, true, false);
    emit Follow(follower, followNFT.nextTokenId(), block.timestamp);
    vm.prank(hub);
    followNFT.follow(follower);
  }

  function test_followWithoutHubReverts() public {
    address randomAddress = makeAddr("random");
    vm.prank(randomAddress);
    vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, randomAddress));
    followNFT.follow(follower);
  }

  function test_doubleFollowReverts() public {
    vm.prank(hub);
    followNFT.follow(follower);
    vm.prank(hub);

    vm.expectRevert(abi.encodeWithSelector(IFollowNFT.FollowNFT__AlreadyFollowing.selector, follower));
    followNFT.follow(follower);
  }

  function test_getTokenIdByFollower() public {
    uint256 expectedTokenId = followNFT.nextTokenId();
    vm.prank(hub);
    followNFT.follow(follower);
    assertEq(followNFT.getTokenIdByFollower(follower), expectedTokenId);
  }

  function test_folowee() public {
    assertEq(followNFT.followee(), folowee);
  }

  function test_nameIsCorrect() public {
    assertEq(followNFT.name(), string(abi.encodePacked("MetaWe-Follow-NFT-", nickname)));
  }

  function test_symbolIsCorrect() public {
    assertEq(followNFT.symbol(), string(abi.encodePacked("MWF-", nickname)));
  }

  function test_unfollow() public {
    vm.prank(hub);
    followNFT.follow(follower);

    vm.prank(hub);
    followNFT.unfollow(follower);

    assertEq(followNFT.getFollowersList().length, 0);
    assertEq(followNFT.getTokenIdByFollower(follower), 0);
  }

  function test_unfollowEmitUnfollowEvent() public {
    uint256 tokenId = followNFT.nextTokenId();
    vm.prank(hub);
    followNFT.follow(follower);

    vm.prank(hub);
    vm.expectEmit(true, true, true, false);
    emit Unfollow(follower, tokenId, block.timestamp);
    followNFT.unfollow(follower);
  }

  function test_unfollowWithoutHubReverts() public {
    vm.prank(hub);
    followNFT.follow(follower);

    address randomAddress = makeAddr("random");
    vm.prank(randomAddress);
    vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, randomAddress));
    followNFT.unfollow(follower);
  }

  function test_doubleUnfollowReverts() public {
    vm.prank(hub);
    followNFT.follow(follower);

    vm.prank(hub);
    followNFT.unfollow(follower);

    vm.expectRevert(abi.encodeWithSelector(IFollowNFT.FollowNFT__NotFollowing.selector, follower));
    vm.prank(hub);
    followNFT.unfollow(follower);
  }
}
