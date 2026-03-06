// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./Vault.sol"; // the vault contract that will store the ERC20 token
import "./VaultNFT.sol"; // used to mint the NFt used to represent each vault
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VaultFactory {

    Sky  public sky; // state variable used to store the address of the NFT contract that mints vault NFT

    /// @notice vault address for each ERC20 token
    mapping(address => address) public tokenvault;
    /// @notice tokenId representing a vault NFT for each vault address
    mapping(address => uint256) public vaultToTokenId;

    constructor() {
        sky = new Sky();
    }

    /// @notice create or get existing vault for a token and deposit amount
    /// @param token ERC20 token contract address
    /// @param user address on whose behalf the deposit is made
    /// @param amount number of tokens to deposit (in smallest units)
    function createVault(address token, address user, uint256 amount) external {
        require(amount > 0, "NO_AMOUNT");

        address vault = tokenvault[token]; // checks if a vault has been created already for the token

        // if the mapping returns a 0 address, it means a vault does not exist
        if (vault == address(0)) {
            vault = _deployVault(token);
            tokenvault[token] = vault; // after deployment, the vault address is stored in the mapping
            // mint NFT to the provided user and remember id
            vaultToTokenId[vault] = sky.mint(user, vault, token, amount);
        }

        IERC20(token).transferFrom(msg.sender, vault, amount); // The ERC20 tokens are transferred from the user to the vault contract.
        TokenVault(vault).deposit(amount, msg.sender); // the vault contract records the deposit internally so it can track user balances.

        // update nft metadata with new total
        _updateNFT(vault);
    }

    /// @notice deposit further tokens into an existing vault
    function depositToVault(address token, uint256 amount) external {
        require(amount > 0, "NO_AMOUNT");
        address vault = tokenvault[token];
        require(vault != address(0), "NO_VAULT");

        IERC20(token).transferFrom(msg.sender, vault, amount);
        TokenVault(vault).deposit(amount, msg.sender);
        _updateNFT(vault);
    }



// Add this function to update NFT metadata (e.g., for SVG URI)

    function _updateNFT(address vault) internal {
        uint256 id = vaultToTokenId[vault];
        uint256 total = TokenVault(vault).totaldeposits();
        sky.updateAmount(id, total);
    }

    function _deployVault(address token) internal returns(address vault) {
        bytes32 salt = bytes32(uint256(uint160(token)));
        vault = address(
            new TokenVault{salt: salt}(IERC20(token))
        );
    }
}