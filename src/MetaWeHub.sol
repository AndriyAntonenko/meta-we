// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { MetaWeRegistry } from "./MetaWeRegistry.sol";
import { MetaWeOwnership } from "./MetaWeOwnership.sol";
import { MetaWeAccount } from "./MetaWeAccount.sol";

import { MetaWeFollowNFT } from "./MetaWeFollowNFT.sol";
import { AccountsStorage } from "./base/AccountsStorage.sol";

contract MetaWeHub is AccountsStorage {
  MetaWeRegistry private immutable i_registry;
  MetaWeOwnership private immutable i_ownership;
  MetaWeAccount private immutable i_accountImpl;

  mapping(address => address) private s_followNfts;

  event AccountCreated(address indexed account, uint256 indexed tokenId, string nickname);

  constructor(address _accountImpl, address _registry, address _ownership) {
    i_accountImpl = MetaWeAccount(payable(_accountImpl));
    i_registry = MetaWeRegistry(_registry);
    i_ownership = MetaWeOwnership(_ownership);
  }

  function createAccount(string calldata nickname) external returns (uint256 tokenId, address account) {
    bytes32 salt = keccak256(abi.encodePacked(nickname));
    tokenId = i_ownership.mint(msg.sender, nickname);
    account = i_registry.createAccount(address(i_accountImpl), salt, block.chainid, address(i_ownership), tokenId);
    saveAccount(account);
    emit AccountCreated(account, tokenId, nickname);

    MetaWeFollowNFT followNft = new MetaWeFollowNFT(account, address(this));
    s_followNfts[account] = address(followNft);
  }

  function follow(address followee) external onlyAccount(followee) onlyAccount(msg.sender) {
    MetaWeFollowNFT followNft = MetaWeFollowNFT(s_followNfts[followee]);
    followNft.follow(msg.sender);
  }

  function unfollow(address followee) external onlyAccount(followee) onlyAccount(msg.sender) {
    MetaWeFollowNFT followNft = MetaWeFollowNFT(s_followNfts[followee]);
    followNft.unfollow(msg.sender);
  }

  /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
  //////////////////////////////////////////////////////////////*/

  function predictAccountAddress(string calldata nickname) external view returns (uint256 tokenId, address account) {
    bytes32 salt = keccak256(abi.encodePacked(nickname));
    tokenId = i_ownership.nextTokenId();
    account = i_registry.account(address(i_accountImpl), salt, block.chainid, address(i_ownership), tokenId);
  }

  function getFollowNftAddress(address followee) public view returns (address) {
    return s_followNfts[followee];
  }

  function getOwnershipAddress() external view returns (address) {
    return address(i_ownership);
  }

  function getRegistryAddress() external view returns (address) {
    return address(i_registry);
  }

  function getAccountImplAddress() external view returns (address) {
    return address(i_accountImpl);
  }

  function isNicknameAvailable(string calldata nickname) external view returns (bool) {
    return i_ownership.getTokenIdByIdentifier(nickname) == 0;
  }
}
