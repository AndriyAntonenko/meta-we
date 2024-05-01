// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title AccountsStorage
/// @dev This contract is used to store accounts addresses and contains helpers and modifiers for interaction with
/// storage. This contract is used as a base contract for other contracts that need to store accounts, like MetaWeHub.
/// @author Andrii Antoneno <andriyantonenko3.16@gmail.com>
contract AccountsStorage {
  error AccountsStorage__AccountAlreadyExists(address account);
  error AccountsStorage__AccountDoesNotExist(address account);

  /// @dev Mapping of accounts addresses to boolean values.
  mapping(address => bool) public accounts;

  modifier onlyAccount(address account) {
    if (!isAccount(account)) revert AccountsStorage__AccountDoesNotExist(account);
    _;
  }

  /// @dev Check if account exists in storage.
  /// @param account Account address.
  function isAccount(address account) public view returns (bool) {
    return accounts[account];
  }

  /// @dev Save account to storage.
  /// @param account Account address.
  function saveAccount(address account) public {
    if (accounts[account]) revert AccountsStorage__AccountAlreadyExists(account);
    accounts[account] = true;
  }
}
