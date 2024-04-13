// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AccountsStorage {
  error AccountsStorage__AccountAlreadyExists(address account);
  error AccountsStorage__AccountDoesNotExist(address account);

  mapping(address => bool) public accounts;

  modifier onlyAccount(address account) {
    if (!isAccount(account)) revert AccountsStorage__AccountDoesNotExist(account);
    _;
  }

  function isAccount(address account) public view returns (bool) {
    return accounts[account];
  }

  function saveAccount(address account) public {
    if (accounts[account]) revert AccountsStorage__AccountAlreadyExists(account);
    accounts[account] = true;
  }
}
