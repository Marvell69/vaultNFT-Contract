// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../src/Vault.sol";
import "../src/VaultNFT.sol";
import "../src/IERC20.sol";
contract VaultFactory {

    mapping(address => address) public vaults;
    // Maps a token address to the vault address created for that token

    Sky public nft;
    // Stores the NFT contract instance used for minting reward NFTs

    constructor() {
        // Constructor runs once when the factory is deployed

        nft = new Sky();
        // Deploys a new Sky NFT contract and saves its address
    }

    function deployVault(address token) public returns (address) {
        // Deploys a vault for a specific ERC20 token

        if (vaults[token] != address(0)) {
            // Checks if a vault for this token already exists
            return vaults[token];
            // If it exists, return the existing vault address
        }

        bytes32 salt = keccak256(abi.encode(token));
        // Creates a deterministic salt value based on the token address

        Vault vault = new Vault{salt: salt}(token, address(this));
        // Deploys a new Vault contract using CREATE2 with the salt
        // Passes the token address and this factory's address to the constructor

        vaults[token] = address(vault);
        // Saves the deployed vault address in the mapping

        return address(vault);
        // Returns the address of the deployed vault
    }

    function deposit(address token, uint256 amount) external {
        // Allows a user to deposit tokens into the vault for a specific token

        address vault = deployVault(token);
        // Gets the vault for this token or deploys a new one if it doesn't exist

        // transfer tokens to vault
        bool success = IERC20(token).transferFrom(msg.sender, vault, amount);
        // Transfers tokens from the user directly to the vault

        require(success, "Transfer failed");
        // Reverts if the token transfer fails

        // FIX: deposit only accepts amount
        Vault(vault).deposit(amount);
        // Calls the deposit function in the vault contract

        // FIX: mint() takes no arguments
        nft.mint();
        // Mints an NFT reward for the user after depositing
    }
}