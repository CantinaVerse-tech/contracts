// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import { Test, console2, Vm } from "forge-std/Test.sol";
import { HelperConfig } from "../../../script/HelperConfig.s.sol";
import { NFTStakingEvolution } from "../../../src/games/NFTStakingEvolution.sol";
import { NFT } from "./utils/NFT.sol";

contract NFTStakingEvolutionTest is Test {
    HelperConfig config;
    NFTStakingEvolution ldGame;
    NFT testNFT;

    address owner = address(1);
    address personA = address(98);
    address personB = address(99);

    function setUp() public {
        config = new HelperConfig();
        // deployer = new DeployNFTLuckyDraw();
        vm.startPrank(owner);
        testNFT = new NFT("test", "NFT", "hello");
        ldGame = new NFTStakingEvolution(address(testNFT));
        ldGame.setPointsPerDay(10);
        vm.stopPrank();
    }

    function testStakeNFT() public {
        vm.startPrank(personA);
        uint256 tokenId = testNFT.mintTo(personA);
        testNFT.approve(address(ldGame), tokenId);
        ldGame.stakeNFT(tokenId);
        vm.warp(123_456_789_454);
        assertGt(ldGame.calculatePoints(tokenId), 0);
        vm.stopPrank();
    }

    function testEvolveNFT() public {
        vm.startPrank(personA);
        uint256 tokenId = testNFT.mintTo(personA);
        testNFT.approve(address(ldGame), tokenId);
        ldGame.stakeNFT(tokenId);
        vm.warp(123_456_789_454);
        ldGame.evolveNFT(tokenId);
        vm.stopPrank();
    }

    function testUnstakeNFT() public {
        vm.startPrank(personA);
        uint256 tokenId = testNFT.mintTo(personA);
        testNFT.approve(address(ldGame), tokenId);
        ldGame.stakeNFT(tokenId);
        vm.warp(123_456_789_454);
        ldGame.unstakeNFT(tokenId);
        vm.stopPrank();
    }
}
