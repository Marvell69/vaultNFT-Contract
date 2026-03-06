// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/VaultFactory.sol";
import "../src/IERC20.sol";

contract VaultTest is Test {

    VaultFactory factory;
    // Variable to hold the deployed VaultFactory instance

    address USDC =
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    // USDC token contract address on Ethereum mainnet

    function setUp() public {
        // Setup function that runs before each test

        vm.createSelectFork(vm.envString("MAINNET_RPC_URL"));
        // Creates a fork of the Ethereum mainnet using the RPC URL from environment variables

        factory = new VaultFactory();
        // Deploys a new VaultFactory instance on the fork
    }

    function testDeposit() public {
        // Test function to simulate a deposit into the vault

        address whale =
            0x55FE002aefF02F77364de339a1292923A15844B8;
        // Address of an account with a large USDC balance for testing

        vm.startPrank(whale);
        // Simulates all subsequent transactions as if sent from the whale account

        IERC20(USDC).approve(address(factory), 1000e6);
        // Approves the VaultFactory to spend 1000 USDC from the whale account

        factory.deposit(USDC, 1000e6);
        // Calls deposit on the factory, sending 1000 USDC to the vault

        vm.stopPrank();
        // Stops simulating transactions from the whale account
    }
}