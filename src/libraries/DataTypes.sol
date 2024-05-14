// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library AccountsLib {
  struct Account {
    uint256 tokenId;
    address account;
  }
}

library FollowingLib {
  struct FollowingInfo {
    address follower;
    uint256 timestamp;
  }
}
