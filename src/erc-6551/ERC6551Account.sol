// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC1271 } from "@openzeppelin/contracts/interfaces/IERC1271.sol";
import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

import { IERC6551Account } from "./IERC6551Account.sol";
import { IERC6551Executable } from "./IERC6551Executable.sol";

/**
 * The code layout for any ERC-6551 account is as follows:
 *
 * ERC-1167 Header               (10 bytes)
 * <implementation (address)>    (20 bytes)
 * ERC-1167 Footer               (15 bytes)
 * <salt (bytes32)>              (32 bytes)
 * <chainId (uint256)>           (32 bytes)
 * <tokenContract (address)>     (32 bytes)
 * <tokenId (uint256)>           (32 bytes)
 */
contract ERC6551Account is IERC165, IERC1271, IERC6551Account, IERC6551Executable {
  error ERC6551Account__InvalidSigner();
  error ERC6551Account__InvalidOperation();

  uint256 public state;

  receive() external payable { }

  function execute(
    address to,
    uint256 value,
    bytes calldata data,
    Op operation
  )
    external
    payable
    returns (bytes memory result)
  {
    if (!_isValidSigner(msg.sender)) {
      revert ERC6551Account__InvalidSigner();
    }

    // @TODO: for now, we only support CALL operations
    if (operation != Op.CALL) {
      revert ERC6551Account__InvalidOperation();
    }

    bool success;
    (success, result) = to.call{ value: value }(data);

    if (!success) {
      assembly {
        revert(add(result, 32), mload(result))
      }
    }
  }

  function isValidSigner(address signer, bytes calldata) public view returns (bytes4 magicValue) {
    return _isValidSigner(signer) ? IERC1271(this).isValidSignature.selector : bytes4(0);
  }

  /**
   * @inheritdoc IERC1271
   */
  function isValidSignature(bytes32 hash, bytes memory signature) public view returns (bytes4 magicValue) {
    bool isValid = SignatureChecker.isValidSignatureNow(owner(), hash, signature);

    return isValid ? IERC1271(this).isValidSignature.selector : bytes4(0);
  }

  /**
   * Reads the chain ID, token contract address, and token ID from the account contract metadata.
   * @return chainId - the chain ID encoded in the account contract
   * @return tokenContract - the address of the ERC721 token encoded in the account contract
   * @return tokenId - the token ID encoded in the account contract
   */
  function token() public view returns (uint256 chainId, address tokenContract, uint256 tokenId) {
    bytes memory footer = new bytes(0x60);

    assembly {
      extcodecopy(address(), add(footer, 0x20), 0x4d, 0x60)
    }

    return abi.decode(footer, (uint256, address, uint256));
  }

  /**
   * Read the owner of the ERC721 token encoded in the account contract.
   * Only the owner of the token can sign transactions for the account.
   * @return owner - the address of the owner of the ERC721 token
   */
  function owner() public view returns (address) {
    (uint256 chainId, address tokenContract, uint256 tokenId) = token();
    if (chainId != block.chainid) {
      return address(0);
    }

    return IERC721(tokenContract).ownerOf(tokenId);
  }

  function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
    return interfaceId == type(IERC6551Account).interfaceId || interfaceId == type(IERC1271).interfaceId
      || interfaceId == type(IERC6551Executable).interfaceId || interfaceId == type(IERC165).interfaceId;
  }

  function _isValidSigner(address signer) internal view returns (bool) {
    return signer == owner();
  }
}
