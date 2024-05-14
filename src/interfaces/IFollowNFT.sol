// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { FollowingLib } from "../libraries/DataTypes.sol";

/// @title IFollowNFT
/// @notice Interface for following NFTs. This NFT is used to follow to followee.
/// @dev This interface defines the functions and events for following NFTs.
interface IFollowNFT {
  /*//////////////////////////////////////////////////////////////
                                 EVENTS
  //////////////////////////////////////////////////////////////*/
  event Follow(address indexed follower, uint256 tokenId, uint256 timestamp);
  event Unfollow(address indexed follower, uint256 tokenId, uint256 timestamp);

  /*//////////////////////////////////////////////////////////////
                      USER-FACING PUBLIC METHODS
  //////////////////////////////////////////////////////////////*/

  /// @dev Mint NFT for follower to follow followee.
  /// @dev This method MUST emit Follow event.
  /// @dev This method can be called only by the owner of this contract.
  /// @param _follower Follower address
  function follow(address _follower) external;

  /// @dev Burn NFT for follower to unfollow followee.
  /// @dev This method MUST emit Unfollow event.
  /// @dev This method can be called only by the owner of this contract.
  /// @param _follower Follower address
  function unfollow(address _follower) external;

  /*//////////////////////////////////////////////////////////////
                      USER-FACING READ METHODS
  //////////////////////////////////////////////////////////////*/

  /// @dev Return the next token ID for minting.
  function nextTokenId() external view returns (uint256);

  /// @dev Return the ERC721 token ID for follower.
  /// @param _follower Follower address
  function getTokenIdByFollower(address _follower) external view returns (uint256);

  /// @dev Return the address of the contract followee.
  /// @return followee Followee address
  function followee() external view returns (address followee);

  /// @dev Return the list of followers for followee.
  /// @return followers Array of followers
  function getFollowersList() external view returns (FollowingLib.FollowingInfo[] memory followers);
}
