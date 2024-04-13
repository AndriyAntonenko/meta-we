// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFollowNFT {
  event Follow(address indexed follower, uint256 tokenId, uint256 timestamp);
  event Unfollow(address indexed follower, uint256 tokenId, uint256 timestamp);

  struct FollowingInfo {
    address follower;
    uint256 timestamp;
  }

  error FollowNFT__AlreadyFollowing(address follower);
  error FollowNFT__NotFollowing(address follower);

  function follow(address _follower) external;
  function unfollow(address _follower) external;
  function getTokenIdByFollower(address _follower) external view returns (uint256);
  function followee() external view returns (address);
}
