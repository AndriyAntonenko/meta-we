// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { IERC721Metadata } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract MetaWeOwnership is ERC721, ERC721Enumerable, Ownable {
  error MetaWeOwnership__IdentifierAlreadyExists(string);

  mapping(string => uint256) private s_identifierToTokenId;

  constructor(address _owner) ERC721("MetaWe Ownership", "MWO") Ownable(_owner) { }

  /*//////////////////////////////////////////////////////////////
                              MODIFIERS
  //////////////////////////////////////////////////////////////*/

  modifier identifierNotExists(string calldata _identifier) {
    if (s_identifierToTokenId[_identifier] != 0) {
      revert MetaWeOwnership__IdentifierAlreadyExists(_identifier);
    }
    _;
  }

  /*//////////////////////////////////////////////////////////////
                          EXTERNAL FUNCTIONS
  //////////////////////////////////////////////////////////////*/

  /// @notice mint a new ownership token to `_to` with identifier `_identifier`
  /// @dev this token will be used to control the ERC-6551 account
  /// @param _to the address to mint the token to
  /// @param _identifier the identifier of the token
  /// @return the token ID
  function mint(
    address _to,
    string calldata _identifier
  )
    external
    onlyOwner
    identifierNotExists(_identifier)
    returns (uint256)
  {
    uint256 tokenId = nextTokenId(); // Token ID starts from 1
    s_identifierToTokenId[_identifier] = tokenId;
    _safeMint(_to, tokenId);
    return tokenId;
  }

  /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
  //////////////////////////////////////////////////////////////*/

  function nextTokenId() public view returns (uint256) {
    return totalSupply() + 1;
  }

  function getTokenIdByIdentifier(string calldata _identifier) external view returns (uint256) {
    return s_identifierToTokenId[_identifier];
  }

  /*//////////////////////////////////////////////////////////////
                          INTERNAL FUNCTIONS
  //////////////////////////////////////////////////////////////*/

  /// @notice this function allows to receive all tokens for a specific owner
  function getOwnedTokenIds(address _owner) external view onlyOwner returns (uint256[] memory) {
    uint256 balance = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](balance);
    for (uint256 i = 0; i < balance; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function _update(
    address to,
    uint256 tokenId,
    address auth
  )
    internal
    override(ERC721, ERC721Enumerable)
    returns (address)
  {
    return super._update(to, tokenId, auth);
  }

  function _increaseBalance(address account, uint128 amount) internal override(ERC721, ERC721Enumerable) {
    super._increaseBalance(account, amount);
  }

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
    return super.supportsInterface(interfaceId);
  }
}
