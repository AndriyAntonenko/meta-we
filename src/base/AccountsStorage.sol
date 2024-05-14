// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title AccountsStorage
/// @dev This contract is used to store accounts addresses and contains helpers and modifiers for interaction with
/// storage. This contract is used as a base contract for other contracts that need to store accounts, like MetaWeHub.
/// @author Andrii Antoneno <andriyantonenko3.16@gmail.com>
contract AccountsStorage {
  error AccountsStorage__AccountAlreadyExists(address account);
  error AccountsStorage__AccountDoesNotExist(address account);

  /// @dev Mapping of accounts addresses to tokenId.
  mapping(address => uint256) internal accountToTokenId;

  /// @dev Mapping of tokenId to account address.
  mapping(uint256 => address) internal tokenIdToAccount;

  modifier onlyAccount(address account) {
    if (!isAccount(account)) revert AccountsStorage__AccountDoesNotExist(account);
    _;
  }

  /// @dev Check if account exists in storage.
  /// @param account Account address.
  function isAccount(address account) public view returns (bool) {
    return accountToTokenId[account] != 0;
  }

  /// @dev Save account to storage.
  /// @param account Account address.
  function saveAccount(address account, uint256 tokenId) public {
    if (accountToTokenId[account] != 0) revert AccountsStorage__AccountAlreadyExists(account);
    accountToTokenId[account] = tokenId;
    tokenIdToAccount[tokenId] = account;
  }

  function getAccountTokenId(address account) external view returns (uint256) {
    return accountToTokenId[account];
  }

  function getAccountByTokenId(uint256 tokenId) public view returns (address) {
    return tokenIdToAccount[tokenId];
  }
}
