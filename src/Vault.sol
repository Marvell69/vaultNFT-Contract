// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenVault {
    IERC20 public token;

    address public factory;

    uint256 public totaldeposits;

    mapping (address => uint) public deposits;

    constructor(IERC20 _token) {
        token = _token;
        factory = msg.sender;
    }

    function deposit(uint256 amount, address user) external  {
        require(msg.sender == factory, "ONLY_FACTORY");

        deposits[user] += amount;
        totaldeposits += amount;
    }
}