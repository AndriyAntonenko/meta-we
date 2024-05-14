// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IOwnership {
  /*//////////////////////////////////////////////////////////////
                      USER-FACING PUBLIC METHODS
  //////////////////////////////////////////////////////////////*/

  /// @notice Mint a new ownership token to `_to` with identifier `_identifier`
  /// @dev This token will be used to control the ERC-6551 account
  /// @param _to The address to mint the token to
  /// @param _identifier The identifier of the token
  /// @return The token ID
  function mint(address _to, string calldata _identifier) external returns (uint256);

  /*//////////////////////////////////////////////////////////////
                      USER-FACING READ METHODS
  //////////////////////////////////////////////////////////////*/

  /// @notice Get the next token ID for minting
  /// @return The next token ID
  function nextTokenId() external view returns (uint256);

  /// @notice Get the token ID by identifier
  /// @param _identifier The identifier of the token
  /// @return The token ID
  function getTokenIdByIdentifier(string calldata _identifier) external view returns (uint256);

  /// @notice Get the owned token IDs by owner
  /// @param _owner The owner address
  /// @return The array of owned token IDs
  function getOwnedTokenIds(address _owner) external view returns (uint256[] memory);
}
