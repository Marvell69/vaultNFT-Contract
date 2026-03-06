// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC20} from "../src/IERC20.sol";
contract Vault {
// custom errors
    error ZeroAmount();
    error TransferFailed();
    error NotFactory(); 
    error InvalidToken();
    error InsufficientBalance();

    address public immutable token;
    // Stores the ERC20 token address used in the vault (cannot be changed)

    address public immutable factory;
    // Stores the factory contract address that deployed this vault

    uint256 public totalLiquidity;
    // Tracks the total amount of tokens deposited in the vault

    // Events
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    mapping(address => uint256) public balances;
    // Keeps track of how many tokens each user has deposited

    uint256 public creationTime;
  

    constructor(address _token, address _factory) {
     

        if (_token == address(0)) {
            // Checks if the token address is the zero address
            revert InvalidToken();
            // Reverts the transaction if the token address is invalid
        }

        token = _token;
        // Saves the ERC20 token address

        factory = _factory;
        // Saves the factory contract address

        creationTime = block.timestamp;
        // Records the current block timestamp as the creation time
    }

    function deposit(uint256 amount) external {
        // Allows a user to deposit tokens into the vault

        if (amount == 0) {
            // Prevents depositing zero tokens
            revert ZeroAmount();
        }

        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        // Transfers tokens from the user to this contract

        if (!success) {
            // Checks if the transfer failed
            revert TransferFailed();
        }

        balances[msg.sender] += amount;
        // Increases the user's stored balance

        totalLiquidity += amount;
        // Updates the total liquidity in the vault

        emit Deposit(msg.sender, amount);
        // Emits a Deposit event for tracking
    }

    function withdraw(uint256 amount) external {
        // Allows a user to withdraw tokens from the vault

        if (amount == 0) {
            // Prevents withdrawing zero tokens
            revert ZeroAmount();
        }

        uint256 userBalance = balances[msg.sender];
        // Gets the user's current balance in the vault

        if (userBalance < amount) {
            // Checks if the user has enough balance
            revert InsufficientBalance();
        }

        balances[msg.sender] -= amount;
        // Reduces the user's stored balance

        totalLiquidity -= amount;
        // Reduces the total liquidity in the vault

        bool success = IERC20(token).transfer(msg.sender, amount);
        // Transfers tokens from the vault back to the user

        if (!success) {
            // Checks if the transfer failed
            revert TransferFailed();
        }

        emit Withdraw(msg.sender, amount);
        // Emits a Withdraw event for tracking
    }

    function getTokenBalance() external view returns (uint256) {
        // Returns the actual ERC20 token balance held by this contract

        return IERC20(token).balanceOf(address(this));
        // Calls the ERC20 balanceOf function to get this contract's token balance
    }
}