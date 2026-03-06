// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/VaultFactory.sol";

contract Deploy is Script {
    // Defines a new contract named Deploy that inherits Foundry's Script

    function run() external {
        // Entry point for the deployment script

        vm.startBroadcast();
        // Starts broadcasting transactions to the blockchain 

        VaultFactory factory = new VaultFactory();
        // Deploys a new VaultFactory contract and saves its address in `factory`

        vm.stopBroadcast();
        // Stops broadcasting transactions to the blockchain
    }
}