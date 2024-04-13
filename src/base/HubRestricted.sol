// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HubRestricted {
  error HubRestricted__NotHub();

  address public immutable i_hub;

  constructor(address _hub) {
    i_hub = _hub;
  }

  modifier onlyHub() {
    if (msg.sender != i_hub) revert HubRestricted__NotHub();
    _;
  }
}
