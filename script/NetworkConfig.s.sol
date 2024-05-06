// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script } from "forge-std/Script.sol";
import { VmSafe } from "forge-std/Vm.sol";

contract NetworkConfig is Script {
  Config public activeNetworkConfig;

  uint256 public constant ANVIL_FIRST_PK = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

  struct Config {
    VmSafe.Wallet deployer;
  }

  constructor() {
    if (block.chainid == 11_155_111) {
      activeNetworkConfig = getSepoliaConfig();
    } else {
      activeNetworkConfig = getAnvilConfig();
    }
  }

  function getSepoliaConfig() public returns (Config memory) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    VmSafe.Wallet memory deployerWallet = vm.createWallet(deployerPrivateKey);

    return Config({ deployer: deployerWallet });
  }

  function getAnvilConfig() public returns (Config memory) {
    VmSafe.Wallet memory deployerWallet = vm.createWallet(ANVIL_FIRST_PK);
    return Config({ deployer: deployerWallet });
  }
}
