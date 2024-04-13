// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { HubRestricted } from "./base/HubRestricted.sol";

import { MetaWeAccount } from "./MetaWeAccount.sol";
import { MetaWeOwnership } from "./MetaWeOwnership.sol";
import { IFollowNFT } from "./interfaces/IFollowNFT.sol";

contract MetaWeFollowNFT is ERC721, HubRestricted, IFollowNFT {
  string public constant NAME_PREFIX = "MetaWe-Follow-NFT-";
  string public constant SYMBOL = "MWFNFT-";
  address private immutable i_followee;

  /*//////////////////////////////////////////////////////////////
                              STORAGE
  //////////////////////////////////////////////////////////////*/
  mapping(address => uint256) private s_tokenIdByFollower;
  mapping(address => uint256) private s_followersIndexes;
  FollowingInfo[] private s_followers;

  constructor(
    address _followee,
    address _hub
  )
    HubRestricted(_hub)
    ERC721(string(abi.encodePacked(NAME_PREFIX, _followee)), string(abi.encodePacked(SYMBOL, _followee)))
  {
    i_followee = _followee;
  }

  /*//////////////////////////////////////////////////////////////
                                LOGIC
  //////////////////////////////////////////////////////////////*/

  modifier notFollowed(address _follower) {
    if (s_tokenIdByFollower[_follower] != 0) {
      revert FollowNFT__AlreadyFollowing(_follower);
    }
    _;
  }

  modifier onlyFollower(address _follower) {
    if (s_tokenIdByFollower[_follower] == 0) {
      revert FollowNFT__NotFollowing(_follower);
    }
    _;
  }

  function follow(address _follower) external onlyHub notFollowed(_follower) {
    uint256 tokenId = nextTokenId();
    _mint(_follower, tokenId);

    s_tokenIdByFollower[_follower] = tokenId;
    s_followersIndexes[_follower] = s_followers.length;

    FollowingInfo memory _followerInfo = FollowingInfo({ follower: _follower, timestamp: block.timestamp });
    s_followers.push(_followerInfo);

    emit Follow(_follower, tokenId, block.timestamp);
  }

  function unfollow(address _follower) external onlyHub onlyFollower(_follower) {
    uint256 tokenId = s_tokenIdByFollower[_follower];
    _burn(tokenId);

    uint256 index = s_followersIndexes[_follower];
    uint256 lastIndex = s_followers.length - 1;
    if (index != lastIndex) {
      s_followers[index] = s_followers[lastIndex];
      s_followersIndexes[s_followers[lastIndex].follower] = index;
    }

    s_followers.pop();
    delete s_tokenIdByFollower[_follower];
    delete s_followersIndexes[_follower];

    emit Unfollow(_follower, tokenId, block.timestamp);
  }

  /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
  //////////////////////////////////////////////////////////////*/

  function nextTokenId() public view returns (uint256) {
    return s_followers.length + 1;
  }

  function getTokenIdByFollower(address _follower) external view returns (uint256) {
    return s_tokenIdByFollower[_follower];
  }

  function followee() external view returns (address) {
    return i_followee;
  }

  function getFollowersList() external view returns (FollowingInfo[] memory) {
    return s_followers;
  }
}
