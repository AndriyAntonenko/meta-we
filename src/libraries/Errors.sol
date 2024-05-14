// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library Errors {
  /*//////////////////////////////////////////////////////////////
                           FOLLOW-NFT ERRORS
  //////////////////////////////////////////////////////////////*/

  error FollowNFT__AlreadyFollowing(address follower);

  error FollowNFT__NotFollowing(address follower);

  /*//////////////////////////////////////////////////////////////
                          OWNERSHIP ERRORS
  //////////////////////////////////////////////////////////////*/

  error MetaWeOwnership__IdentifierAlreadyExists(string);
}
