// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {VaultFactory} from "../src/VaultFactory.sol";
import {Sky} from "../src/VaultNFT.sol";
import {TokenVault} from "../src/Vault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract VaultFactoryTest is Test {
    VaultFactory public factory;
    Sky public nft;
    IERC20 public token;

    // usdc token, will be set in setUp
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    function setUp() public {
        // fork mainnet at current head (requires env variable MAINNET_RPC_URL)
        string memory url;
        try vm.envString("MAINNET_RPC_URL") returns (string memory _url) {
            url = _url;
        } catch {
            // variable not provided, skip tests later
            return;
        }
        if (bytes(url).length == 0) return;
        vm.createSelectFork(url);

        factory = new VaultFactory();
        nft = factory.sky();
        token = IERC20(USDC);

        // prepare an account with tokens: first take from a impersonated signer into this contract
        address impersonatedSigner = 0x55FE002aefF02F77364de339a1292923A15844B8; // example USDC holder
        vm.prank(impersonatedSigner);
        token.transfer(address(this), 1_000_000e6); // transfer 1M USDC

        // send some tokens to a fake depositor and approve factory from that user
        address depositor = address(0xdead);
        token.transfer(depositor, 500_000e6);
        vm.prank(depositor);
        token.approve(address(factory), type(uint256).max);

        // also approve factory from this contract just in case
        token.approve(address(factory), type(uint256).max);
    }

    function test_createVault_and_deposit() public {
        if (address(factory) == address(0)) return; // skip when no fork
        // deposit 100 USDC as an EOA
        address depositor = address(0xdead);
        uint256 amount = 100e6;
        // impersonate user for the action
        vm.prank(depositor);
        factory.createVault(address(token), depositor, amount);

        address vault = factory.tokenvault(address(token));
        assertTrue(vault != address(0));

        // verify vault balance and NFT amount
        assertEq(token.balanceOf(vault), amount);
        uint256 tokenId = factory.vaultToTokenId(vault);
        assertEq(nft.amountOf(tokenId), amount);

        // // deposit more money
        // factory.depositToVault(address(token), 50e6);
        // assertEq(token.balanceOf(vault), 150e6);
        // assertEq(nft.amountOf(tokenId), 150e6);
    }

    function test_svg_contains_symbol_and_amount() public {
        if (address(factory) == address(0)) return;
        uint256 amount = 10000;
        address depositor = address(0xdead);
        vm.prank(depositor);
        factory.createVault(address(token), depositor, amount);
        uint256 tokenId = factory.vaultToTokenId(factory.tokenvault(address(token)));
        string memory uri = nft.tokenURI(tokenId);
        assertTrue(bytes(uri).length > 0);
        // basic sanity: URI should start with data:
        assertTrue(bytes(uri)[0] == "d");
    }
}