// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script } from "forge-std/Script.sol";
import { VmSafe } from "forge-std/Vm.sol";

contract NetworkConfig is Script {
  Config public activeNetworkConfig;

  uint256 public constant ERIGON_DEV_CHAIN_FIRST_PK = 0x26e86e45f6fc45ec6e2ecd128cec80fa1d1505e5507dcd2ae58c3130a7a97b48;

  struct Config {
    VmSafe.Wallet deployer;
  }

  constructor() {
    if (block.chainid == 11_155_111) {
      activeNetworkConfig = getSepoliaConfig();
    } else {
      activeNetworkConfig = getErgionDevChainConfig();
    }
  }

  function getSepoliaConfig() public returns (Config memory) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    VmSafe.Wallet memory deployerWallet = vm.createWallet(deployerPrivateKey);

    return Config({ deployer: deployerWallet });
  }

  function getErgionDevChainConfig() public returns (Config memory) {
    VmSafe.Wallet memory deployerWallet = vm.createWallet(ERIGON_DEV_CHAIN_FIRST_PK);
    return Config({ deployer: deployerWallet });
  }
}
