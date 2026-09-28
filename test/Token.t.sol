// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Token} from "../src/Token.sol";
import {vm} from "./Vm.sol";

contract TokenTest {
    Token token;
    address alice = address(0xA11CE);
    address bob = address(0xB0B);

    function setUp() public {
        token = new Token("Test", "TST", 1_000e18);
    }

    function test_InitialSupplyGoesToDeployer() public view {
        require(token.totalSupply() == 1_000e18, "supply");
        require(token.balanceOf(address(this)) == 1_000e18, "balance");
        require(token.owner() == address(this), "owner");
    }

    function test_Transfer() public {
        token.transfer(alice, 10e18);
        require(token.balanceOf(alice) == 10e18, "alice");
        require(token.balanceOf(address(this)) == 990e18, "sender");
    }

    function test_TransferFromSpendsAllowance() public {
        token.approve(alice, 5e18);
        vm.prank(alice);
        token.transferFrom(address(this), bob, 3e18);
        require(token.balanceOf(bob) == 3e18, "bob");
        require(token.allowance(address(this), alice) == 2e18, "allowance left");
    }

    function test_InfiniteAllowanceIsNotDecremented() public {
        token.approve(alice, type(uint256).max);
        vm.prank(alice);
        token.transferFrom(address(this), bob, 1e18);
        require(token.allowance(address(this), alice) == type(uint256).max, "allowance changed");
    }

    function test_RevertWhen_BalanceTooLow() public {
        vm.prank(alice);
        vm.expectRevert(Token.InsufficientBalance.selector);
        token.transfer(bob, 1);
    }

    function test_RevertWhen_AllowanceTooLow() public {
        token.approve(alice, 1);
        vm.prank(alice);
        vm.expectRevert(Token.InsufficientAllowance.selector);
        token.transferFrom(address(this), bob, 2);
    }

    function test_OnlyOwnerCanMint() public {
        token.mint(alice, 7);
        require(token.totalSupply() == 1_000e18 + 7, "supply after mint");
        vm.prank(alice);
        vm.expectRevert(Token.NotOwner.selector);
        token.mint(alice, 1);
    }

    function test_Burn() public {
        token.burn(100e18);
        require(token.totalSupply() == 900e18, "supply after burn");
    }
}
