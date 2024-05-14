// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { AccountsLib } from "../libraries/DataTypes.sol";
import { IFollowNFT } from "./IFollowNFT.sol";

interface IMetaWeHub {
  /*//////////////////////////////////////////////////////////////
                                 EVENTS
  //////////////////////////////////////////////////////////////*/
  event AccountCreated(address indexed account, uint256 indexed tokenId, address indexed owner, string nickname);

  /*//////////////////////////////////////////////////////////////
                      USER-FACING PUBLIC METHODS
  //////////////////////////////////////////////////////////////*/

  /// @dev Create an account for caller (mint ownership and create account in registry). Also create follow NFT for
  /// account.
  /// @dev This method MUST emit AccountCreated event.
  /// @param nickname Account nickname
  /// @return tokenId Account token ID
  /// @return account Account address
  function createAccount(string calldata nickname) external returns (uint256 tokenId, address account);

  /// @dev Follow to followee(mint follow NFT for caller in NFT associated with followee).
  /// @dev Caller must be an account
  /// @dev Followee must be an account
  /// @param followee Followee address
  function follow(address followee) external;

  /// @dev Unfollow from followee(burn follow NFT for caller in NFT associated with followee).
  /// @dev Caller must be an account
  /// @dev Followee must be an account
  /// @param followee Followee address
  function unfollow(address followee) external;

  /*//////////////////////////////////////////////////////////////
                      USER-FACING READ METHODS
  //////////////////////////////////////////////////////////////*/

  /// @dev Predict account address for nickname. Be aware that the addres depdends on the token ID too.
  /// @param nickname Account nickname
  /// @return tokenId Account token ID
  /// @return account Account address
  function predictAccountAddress(string calldata nickname) external view returns (uint256 tokenId, address account);

  /// @dev Get accounts owned by provided owner.
  /// @param owner Owner address
  /// @return accounts Array of accounts
  function getOwnedAccounts(address owner) external view returns (AccountsLib.Account[] memory);

  /// @dev Return true if nickname is not placed yet.
  /// @param nickname Account nickname
  /// @return available True if nickname is available
  function isNicknameAvailable(string calldata nickname) external view returns (bool available);

  /// @dev Get the address of the ERC-721 contract that represents the follow NFT for the provided account.
  /// @dev Should revert if the account does not exist.
  /// @param account Account address
  /// @return followNftAddress Follow NFT address
  function getFollowNftAddress(address account) external view returns (IFollowNFT followNftAddress);
}
