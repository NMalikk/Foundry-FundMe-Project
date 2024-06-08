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

// contract FundMeTest is CodeConstants, StdCheats, Test {
//     FundMe public fundMe;
//     HelperConfig public helperConfig;

//     uint256 public constant SEND_VALUE = 0.1 ether; // just a value to make sure we are sending enough!
//     uint256 public constant STARTING_USER_BALANCE = 10 ether;
//     uint256 public constant GAS_PRICE = 1;

//     address public constant USER = address(1);

//     // uint256 public constant SEND_VALUE = 1e18;
//     // uint256 public constant SEND_VALUE = 1_000_000_000_000_000_000;
//     // uint256 public constant SEND_VALUE = 1000000000000000000;

//     function setUp() external {

//         DeployFundMe deployer = new DeployFundMe();
//         (fundMe, helperConfig) = deployer.deployFundMe();

//         vm.deal(USER, STARTING_USER_BALANCE);
//     }

//     function testPriceFeedSetCorrectly() public {
//         address retreivedPriceFeed = address(fundMe.getPriceFeed());
//         // (address expectedPriceFeed) = helperConfig.activeNetworkConfig();
//         address expectedPriceFeed = helperConfig.activeNetworkConfig();
//         assertEq(retreivedPriceFeed, expectedPriceFeed);
//     }

//     function testFundFailsWithoutEnoughETH() public {
//         vm.expectRevert();
//         fundMe.fund();
//     }

//     function testFundUpdatesFundedDataStructure() public {
//         vm.startPrank(USER);
//         fundMe.fund{value: SEND_VALUE}();
//         vm.stopPrank();

//         uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
//         assertEq(amountFunded, SEND_VALUE);
//     }

//     function testAddsFunderToArrayOfFunders() public {
//         vm.startPrank(USER);
//         fundMe.fund{value: SEND_VALUE}();
//         vm.stopPrank();

//         address funder = fundMe.getFunder(0);
//         assertEq(funder, USER);
//     }

//     // https://twitter.com/PaulRBerg/status/1624763320539525121

//     modifier funded() {
//         vm.prank(USER);
//         fundMe.fund{value: SEND_VALUE}();
//         assert(address(fundMe).balance > 0);
//         _;
//     }

//     function testOnlyOwnerCanWithdraw() public funded {
//         vm.expectRevert();
//         vm.prank(address(3)); // Not the owner
//         fundMe.withdraw();
//     }

//     function testWithdrawFromASingleFunder() public funded {
//         // Arrange
//         uint256 startingFundMeBalance = address(fundMe).balance;
//         uint256 startingOwnerBalance = fundMe.getOwner().balance;

//         // vm.txGasPrice(GAS_PRICE);
//         // uint256 gasStart = gasleft();
//         // // Act
//         vm.startPrank(fundMe.getOwner());
//         fundMe.withdraw();
//         vm.stopPrank();

//         // uint256 gasEnd = gasleft();
//         // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;

//         // Assert
//         uint256 endingFundMeBalance = address(fundMe).balance;
//         uint256 endingOwnerBalance = fundMe.getOwner().balance;
//         assertEq(endingFundMeBalance, 0);
//         assertEq(
//             startingFundMeBalance + startingOwnerBalance,
//             endingOwnerBalance // + gasUsed
//         );
//     }

//     // Can we do our withdraw function a cheaper way?
//     function testWithdrawFromMultipleFunders() public funded {
//         uint160 numberOfFunders = 10;
//         uint160 startingFunderIndex = 2;
//         for (
//             uint160 i = startingFunderIndex;
//             i < numberOfFunders + startingFunderIndex;
//             i++
//         ) {
//             // we get hoax from stdcheats
//             // prank + deal
//             hoax(address(i), STARTING_USER_BALANCE);
//             fundMe.fund{value: SEND_VALUE}();
//         }

//         uint256 startingFundMeBalance = address(fundMe).balance;
//         uint256 startingOwnerBalance = fundMe.getOwner().balance;

//         vm.startPrank(fundMe.getOwner());
//         fundMe.withdraw();
//         vm.stopPrank();

//         assert(address(fundMe).balance == 0);
//         assert(
//             startingFundMeBalance + startingOwnerBalance ==
//                 fundMe.getOwner().balance
//         );
//         assert(
//             (numberOfFunders + 1) * SEND_VALUE ==
//                 fundMe.getOwner().balance - startingOwnerBalance
//         );
//     }
// }
