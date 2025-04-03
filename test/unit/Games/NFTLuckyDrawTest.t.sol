// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import { Test, console2, Vm } from "forge-std/Test.sol";
import { HelperConfig } from "../../../script/HelperConfig.s.sol";
import { NFTLuckyDraw } from "../../../src/games/NFTLuckyDraw.sol";
import { DeployNFTLuckyDraw } from "../../../script/Games/DeployNFTLuckyDraw.s.sol";

contract NFTLuckyDrawTest is Test {
    HelperConfig config;
    NFTLuckyDraw ldGame;
    DeployNFTLuckyDraw deployer;

    address owner = address(1);
    address personA = address(98);
    address personB = address(99);

    function setUp() public {
        config = new HelperConfig();
        // deployer = new DeployNFTLuckyDraw();
        vm.prank(owner);
        ldGame = new NFTLuckyDraw();
        vm.deal(personA, 0.0001 ether);
        vm.deal(personB, 0.0001 ether);
    }

    // function testEnterGame() public {
    //     vm.startPrank(personA);
    //     uint256 tokenId = ldGame.mintLuckyCard{ value: 0.0001 ether }(1 ether);
    //     assertGt(tokenId, 0);
    //     uint256 prizePool = ldGame.();
    //     assertEq(prizePool, 0.0001 ether);
    //     vm.stopPrank();
    // }

    // function testSelectWinner() public {
    //     vm.prank(personA);
    //     ldGame.mintLuckyCard{ value: 0.0001 ether }(1 ether);
    //     vm.prank(personB);
    //     ldGame.mintLuckyCard{ value: 0.0001 ether }(1 ether);
    //     vm.startPrank(owner);
    //     vm.warp(1_641_070_800);
    //     vm.prevrandao(bytes32(uint256(42)));
    //     address winner = ldGame.selectWinner(0);
    //     vm.stopPrank();
    //     assert(winner != address(0));
    //     assertEq(personA.balance, 0.0002 ether);
    // }
}
