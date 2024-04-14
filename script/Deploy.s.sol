// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script } from "forge-std/Script.sol";
import { VmSafe } from "forge-std/Vm.sol";

import { MetaWeHub } from "../src/MetaWeHub.sol";
import { MetaWeAccount } from "../src/MetaWeAccount.sol";
import { MetaWeRegistry } from "../src/MetaWeRegistry.sol";
import { MetaWeOwnership } from "../src/MetaWeOwnership.sol";
import { MetaWeFollowNFT } from "../src/MetaWeFollowNFT.sol";

contract Deploy is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    VmSafe.Wallet memory deployerWallet = vm.createWallet(deployerPrivateKey);

    MetaWeAccount accountImpl = new MetaWeAccount();
    MetaWeFollowNFT followNftImpl = new MetaWeFollowNFT();
    MetaWeRegistry registry = new MetaWeRegistry(deployerWallet.addr);
    MetaWeOwnership ownership = new MetaWeOwnership(deployerWallet.addr);

    MetaWeHub hub = new MetaWeHub(address(accountImpl), address(registry), address(ownership), address(followNftImpl));

    registry.transferOwnership(address(hub));
    ownership.transferOwnership(address(hub));

    vm.stopBroadcast();
  }
}
