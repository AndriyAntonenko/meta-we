// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HubRestricted {
  error HubRestricted__NotHub();

  address internal i_hub;

  modifier onlyHub() {
    if (msg.sender != i_hub) revert HubRestricted__NotHub();
    _;
  }

  function __HubRestricted_init(address _hub) internal {
    i_hub = _hub;
  }
}
