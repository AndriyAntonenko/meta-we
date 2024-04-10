// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC6551Executable {
  enum Op {
    CALL,
    DELEGATECALL,
    CREATE,
    CREATE2
  }

  /**
   * @dev Executes a low-level operation if the caller is a valid signer on the account.
   *
   * Reverts and bubbles up error if operation fails.
   *
   * Accounts implementing this interface MUST accept the following operation parameter values:
   * - 0 = CALL
   * - 1 = DELEGATECALL
   * - 2 = CREATE
   * - 3 = CREATE2
   *
   * Accounts implementing this interface MAY support additional operations or restrict a signer's
   * ability to execute certain operations.
   *
   * @param to        The target address of the operation
   * @param value     The Ether value to be sent to the target
   * @param data      The encoded operation calldata
   * @param operation A value indicating the type of operation to perform
   * @return The result of the operation
   */
  function execute(
    address to,
    uint256 value,
    bytes calldata data,
    Op operation
  )
    external
    payable
    returns (bytes memory);
}
