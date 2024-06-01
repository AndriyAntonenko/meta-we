// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { MetaWeRegistry } from "./MetaWeRegistry.sol";
import { MetaWeOwnership } from "./MetaWeOwnership.sol";
import { MetaWeAccount } from "./MetaWeAccount.sol";
import { MetaWeFollowNFT } from "./MetaWeFollowNFT.sol";

import { IMetaWeHub } from "./interfaces/IMetaWeHub.sol";
import { IFollowNFT } from "./interfaces/IFollowNFT.sol";
import { AccountsStorage } from "./base/AccountsStorage.sol";
import { AccountsLib } from "./libraries/DataTypes.sol";

/*
███╗   ███╗███████╗████████╗ █████╗     ██╗    ██╗███████╗          
████╗ ████║██╔════╝╚══██╔══╝██╔══██╗    ██║    ██║██╔════╝          
██╔████╔██║█████╗     ██║   ███████║    ██║ █╗ ██║█████╗            
██║╚██╔╝██║██╔══╝     ██║   ██╔══██║    ██║███╗██║██╔══╝            
██║ ╚═╝ ██║███████╗   ██║   ██║  ██║    ╚███╔███╔╝███████╗          
╚═╝     ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝     ╚══╝╚══╝ ╚══════╝          
                                                                    
██████╗ ██████╗  ██████╗ ████████╗ ██████╗  ██████╗ ██████╗ ██╗     
██╔══██╗██╔══██╗██╔═══██╗╚══██╔══╝██╔═══██╗██╔════╝██╔═══██╗██║     
██████╔╝██████╔╝██║   ██║   ██║   ██║   ██║██║     ██║   ██║██║     
██╔═══╝ ██╔══██╗██║   ██║   ██║   ██║   ██║██║     ██║   ██║██║     
██║     ██║  ██║╚██████╔╝   ██║   ╚██████╔╝╚██████╗╚██████╔╝███████╗
╚═╝     ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝  ╚═════╝ ╚═════╝ ╚══════╝
*/

/// @title MetaWeHub
/// @author Andrii Antonenko <andriyantonenko3.16@gmail.com>
/// @notice This contract is the main hub of the MetaWe system. It is responsible for creating accounts, managing
/// follow/unfollow actions and storing account addresses. It is the main entry point for the MetaWe system.
/// @dev This contract is the main hub of the MetaWe system.
contract MetaWeHub is AccountsStorage, IMetaWeHub {
  MetaWeRegistry private immutable i_registry;
  MetaWeOwnership private immutable i_ownership;
  address private immutable i_accountImpl;
  address private immutable i_followNftImpl;

  mapping(address => address) private s_followNfts;

  constructor(address _accountImpl, address _registry, address _ownership, address _followNftImpl) {
    i_accountImpl = _accountImpl;
    i_followNftImpl = _followNftImpl;
    i_registry = MetaWeRegistry(_registry);
    i_ownership = MetaWeOwnership(_ownership);
  }

  /*//////////////////////////////////////////////////////////////
                      USER-FACING PUBLIC METHODS
  //////////////////////////////////////////////////////////////*/

  /// @inheritdoc IMetaWeHub
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

  /// @inheritdoc IMetaWeHub
  function follow(address followee) external onlyAccount(followee) onlyAccount(msg.sender) {
    MetaWeFollowNFT followNft = MetaWeFollowNFT(s_followNfts[followee]);
    followNft.follow(msg.sender);
  }

  /// @inheritdoc IMetaWeHub
  function unfollow(address followee) external onlyAccount(followee) onlyAccount(msg.sender) {
    MetaWeFollowNFT followNft = MetaWeFollowNFT(s_followNfts[followee]);
    followNft.unfollow(msg.sender);
  }

  /*//////////////////////////////////////////////////////////////
                      USER-FACING READ METHODS
  //////////////////////////////////////////////////////////////*/

  /// @inheritdoc IMetaWeHub
  function predictAccountAddress(string calldata nickname) external view returns (uint256 tokenId, address account) {
    bytes32 salt = keccak256(abi.encodePacked(nickname));
    tokenId = i_ownership.nextTokenId();
    account = i_registry.account(i_accountImpl, salt, block.chainid, address(i_ownership), tokenId);
  }

  /// @inheritdoc IMetaWeHub
  function getOwnedAccounts(address owner) external view returns (AccountsLib.Account[] memory) {
    if (i_ownership.balanceOf(owner) == 0) return new AccountsLib.Account[](0);
    uint256[] memory tokenIds = i_ownership.getOwnedTokenIds(owner);
    AccountsLib.Account[] memory accounts = new AccountsLib.Account[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      accounts[i] = AccountsLib.Account({ tokenId: tokenIds[i], account: tokenIdToAccount[tokenIds[i]] });
    }
    return accounts;
  }

  /// @inheritdoc IMetaWeHub
  function isNicknameAvailable(string calldata nickname) external view returns (bool) {
    return i_ownership.getTokenIdByIdentifier(nickname) == 0;
  }

  /// @inheritdoc IMetaWeHub
  function getFollowNftAddress(address account)
    external
    view
    onlyAccount(account)
    returns (IFollowNFT followNftAddress)
  {
    return IFollowNFT(s_followNfts[account]);
  }
}
