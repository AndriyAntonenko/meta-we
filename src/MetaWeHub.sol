// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { MetaWeRegistry } from "./MetaWeRegistry.sol";
import { MetaWeOwnership } from "./MetaWeOwnership.sol";
import { MetaWeAccount } from "./MetaWeAccount.sol";

import { MetaWeFollowNFT } from "./MetaWeFollowNFT.sol";
import { AccountsStorage } from "./base/AccountsStorage.sol";

contract MetaWeHub is AccountsStorage {
  MetaWeRegistry private immutable i_registry;
  MetaWeOwnership private immutable i_ownership;
  address private immutable i_accountImpl;
  address private immutable i_followNftImpl;

  mapping(address => address) private s_followNfts;

  event AccountCreated(address indexed account, uint256 indexed tokenId, address indexed owner, string nickname);

  constructor(address _accountImpl, address _registry, address _ownership, address _followNftImpl) {
    i_accountImpl = _accountImpl;
    i_followNftImpl = _followNftImpl;
    i_registry = MetaWeRegistry(_registry);
    i_ownership = MetaWeOwnership(_ownership);
  }

  /// @dev Create an account for caller (mint ownership and create account in registry). Also create follow NFT for
  /// account.
  /// @param nickname Account nickname
  /// @return tokenId Account token ID
  /// @return account Account address
  function createAccount(string calldata nickname) external returns (uint256 tokenId, address account) {
    bytes32 salt = keccak256(abi.encodePacked(nickname));
    tokenId = i_ownership.mint(msg.sender, nickname);
    account = i_registry.createAccount(i_accountImpl, salt, block.chainid, address(i_ownership), tokenId);
    saveAccount(account, tokenId);
    emit AccountCreated(account, tokenId, msg.sender, nickname);

    ERC1967Proxy followNftProxy = new ERC1967Proxy(i_followNftImpl, "");
    MetaWeFollowNFT followNft = MetaWeFollowNFT(address(followNftProxy));
    followNft.initialize(account, address(this), nickname);
    s_followNfts[account] = address(followNftProxy);
  }

  /// @dev Follow to followee(mint follow NFT for caller in NFT associated with followee).
  /// @param followee Followee address
  function follow(address followee) external onlyAccount(followee) onlyAccount(msg.sender) {
    MetaWeFollowNFT followNft = MetaWeFollowNFT(s_followNfts[followee]);
    followNft.follow(msg.sender);
  }

  /// @dev Unfollow from followee(burn follow NFT for caller in NFT associated with followee).
  /// @param followee Followee address
  function unfollow(address followee) external onlyAccount(followee) onlyAccount(msg.sender) {
    MetaWeFollowNFT followNft = MetaWeFollowNFT(s_followNfts[followee]);
    followNft.unfollow(msg.sender);
  }

  /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
  //////////////////////////////////////////////////////////////*/

  /// @dev Predict account address for nickname. Be aware that the addres depdends on the token ID too.
  /// @param nickname Account nickname
  /// @return tokenId Account token ID
  /// @return account Account address
  function predictAccountAddress(string calldata nickname) external view returns (uint256 tokenId, address account) {
    bytes32 salt = keccak256(abi.encodePacked(nickname));
    tokenId = i_ownership.nextTokenId();
    account = i_registry.account(i_accountImpl, salt, block.chainid, address(i_ownership), tokenId);
  }

  function getOwnedAccounts(address owner) external view returns (Account[] memory) {
    uint256[] memory tokenIds = i_ownership.getOwnedTokenIds(owner);
    Account[] memory accounts = new Account[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      accounts[i] = Account({ tokenId: tokenIds[i], account: tokenIdToAccount[tokenIds[i]] });
    }
    return accounts;
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
    return i_accountImpl;
  }

  function isNicknameAvailable(string calldata nickname) external view returns (bool) {
    return i_ownership.getTokenIdByIdentifier(nickname) == 0;
  }
}
