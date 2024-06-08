//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig, CodeConstants} from "../../script/HelperConfig.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract FundMeTest is StdCheats, CodeConstants, Test {
    FundMe fundMe;
    HelperConfig helperConfig;

    function setUp() external {
        //always runs first
        helperConfig = new HelperConfig();
        vm.startBroadcast();
        fundMe = new FundMe(helperConfig.activeNetworkConfig()); // PROBLEM SOLVED: was not broadcasting fundMe onto chain. But then how did rest of tests pass?
        vm.stopBroadcast();
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testPriceFeedVersion() public {
        assertEq(fundMe.getVersion(), 4);
    }

    function testPriceFeedIsCorrect() public {
        address retreivedPriceFeed = address(fundMe.getPriceFeed());
        address expectedPriceFeed = helperConfig.activeNetworkConfig();
        assertEq(retreivedPriceFeed, expectedPriceFeed);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesDataStructure() public {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assert(address(fundMe).balance > 0);
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(address(2)); //addres 1 is owner, address 2 = not owner;
        fundMe.withdraw();
    }

    function testWithdrawFromSingleFunder() public funded {
        uint256 startingContractBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endContractBalance = address(fundMe).balance;
        uint256 endOwnerBalance = fundMe.getOwner().balance;

        assertEq(endContractBalance, 0); // contract balance should be empty after withdraw
        assertEq(
            startingContractBalance + startingOwnerBalance,
            endOwnerBalance // + GasUsed but since on anvil there are no gas costs.
        );
    }

    function testAddsFunderToArrayofFunders() public {
        //Adding funds to fund array
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        //Checking funders Array
        assertEq(USER, fundMe.getFunder(0)); //first index
    }
}
