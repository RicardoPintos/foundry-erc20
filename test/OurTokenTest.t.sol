// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public view {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }

    function testAllowancesWork() public {
        uint256 initialAllowance = 1000;

        // Bob aproves Alice to spend tokens on his behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
        assertEq(initialAllowance - transferAmount, ourToken.allowance(bob, alice));
    }

    function testInitialSupply() public view {
        assertEq(ourToken.totalSupply(), INITIAL_SUPPLY);
    }

    function testTotalSupplyAfterTransfer() public {
        uint256 transferAmount = 20 ether;

        // Bob transfers to Alice
        vm.prank(bob);
        ourToken.transfer(alice, transferAmount);

        // Total supply should remain unchanged
        assertEq(ourToken.totalSupply(), INITIAL_SUPPLY);
    }

    function testTransfersWorkCorrectly() public {
        uint256 transferAmount = 10 ether;

        // Bob transfers to Alice
        vm.prank(bob);
        ourToken.transfer(alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testZeroTransferDoesNotFail() public {
        vm.prank(bob);
        ourToken.transfer(alice, 0);

        assertEq(ourToken.balanceOf(alice), 0);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE);
    }
}
