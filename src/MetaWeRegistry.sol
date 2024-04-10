// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC6551Registry } from "./erc-6551/ERC6551Registry.sol";
import { ERC6551Account } from "./erc-6551/ERC6551Account.sol";

contract MetaWeRegistry is ERC6551Registry, Ownable {
  constructor(address _owner) Ownable(_owner) { }

  function createAccount(
    address _account,
    bytes32 _salt,
    uint256 _chainId,
    address _ownership,
    uint256 _tokenId
  )
    public
    override
    onlyOwner
    returns (address)
  {
    return super.createAccount(_account, _salt, _chainId, _ownership, _tokenId);
  }

  function account(
    address _account,
    bytes32 _salt,
    uint256 _chainId,
    address _ownership,
    uint256 _tokenId
  )
    public
    view
    override
    returns (address)
  {
    return super.account(_account, _salt, _chainId, _ownership, _tokenId);
  }
}
