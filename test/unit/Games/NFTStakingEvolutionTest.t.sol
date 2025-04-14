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

        // Verify stake details
        (address stakedOwner, uint256 stakedAt, uint256 points) = ldGame.stakes(tokenId);
        assertEq(stakedOwner, personA);
        assertGt(stakedAt, 0);
        assertEq(points, 0);
        assertEq(testNFT.ownerOf(tokenId), address(ldGame));
        vm.stopPrank();
    }

    function test_RevertWhen_StakeNFTNotOwner() public {
        uint256 tokenId = testNFT.mintTo(personA);
        vm.prank(personB);
        vm.expectRevert();
        ldGame.stakeNFT(tokenId);
    }

    function test_RevertWhen_UnstakeNFTNotOwner() public {
        vm.startPrank(personA);
        uint256 tokenId = testNFT.mintTo(personA);
        testNFT.approve(address(ldGame), tokenId);
        ldGame.stakeNFT(tokenId);
        vm.stopPrank();

        vm.prank(personB);
        vm.expectRevert();
        ldGame.unstakeNFT(tokenId);
    }

    function test_RevertWhen_EvolveNFTInsufficientPoints() public {
        vm.startPrank(personA);
        uint256 tokenId = testNFT.mintTo(personA);
        testNFT.approve(address(ldGame), tokenId);
        ldGame.stakeNFT(tokenId);
        vm.stopPrank();

        vm.prank(personA);
        vm.expectRevert();
        ldGame.evolveNFT(tokenId);
    }

    function test_RevertWhen_SetPointsPerDayNotOwner() public {
        vm.prank(personA);
        vm.expectRevert();
        ldGame.setPointsPerDay(20);
    }

    function testEvolveNFT() public {
        vm.startPrank(personA);
        uint256 tokenId = testNFT.mintTo(personA);
        testNFT.approve(address(ldGame), tokenId);
        ldGame.stakeNFT(tokenId);

        // Warp time forward by 5 days to accumulate 50 points (10 points per day)
        vm.warp(block.timestamp + 5 days);

        // Evolution to level 1 requires 50 points
        ldGame.evolveNFT(tokenId);

        // Verify evolution
        assertEq(ldGame.evolutionLevel(tokenId), 1);

        // Verify points were deducted
        (,, uint256 remainingPoints) = ldGame.stakes(tokenId);
        assertLt(remainingPoints, 50);
        vm.stopPrank();
    }

    function test_RevertWhen_EvolveNFTInsufficientPoints2() public {
        vm.startPrank(personA);
        uint256 tokenId = testNFT.mintTo(personA);
        testNFT.approve(address(ldGame), tokenId);
        ldGame.stakeNFT(tokenId);

        // Only wait 2 days (20 points)
        vm.warp(block.timestamp + 2 days);

        vm.expectRevert();
        ldGame.evolveNFT(tokenId); // Should fail as 20 points < 50 required points
        vm.stopPrank();
    }

    function testUnstakeNFT() public {
        vm.startPrank(personA);
        uint256 tokenId = testNFT.mintTo(personA);
        testNFT.approve(address(ldGame), tokenId);
        ldGame.stakeNFT(tokenId);

        // Warp time forward by 2 days to accumulate points
        vm.warp(block.timestamp + 2 days);

        // Calculate expected points before unstaking
        uint256 expectedPoints = ldGame.calculatePoints(tokenId);
        ldGame.unstakeNFT(tokenId);

        // Verify NFT is returned and stake is cleared
        assertEq(testNFT.ownerOf(tokenId), personA);
        (address stakedOwner,,) = ldGame.stakes(tokenId);
        assertEq(stakedOwner, address(0));
        vm.stopPrank();
    }

    function test_RevertWhen_UnstakeNFTNotOwner2() public {
        vm.startPrank(personA);
        uint256 tokenId = testNFT.mintTo(personA);
        testNFT.approve(address(ldGame), tokenId);
        ldGame.stakeNFT(tokenId);
        vm.stopPrank();

        vm.prank(personB);
        vm.expectRevert();
        ldGame.unstakeNFT(tokenId); // Should fail as personB is not the staker
    }

    function testCalculatePoints() public {
        vm.startPrank(personA);
        uint256 tokenId = testNFT.mintTo(personA);
        testNFT.approve(address(ldGame), tokenId);
        ldGame.stakeNFT(tokenId);

        // Warp time forward by 3 days
        vm.warp(block.timestamp + 3 days);

        // Should have accumulated 30 points (10 points per day)
        uint256 points = ldGame.calculatePoints(tokenId);
        assertEq(points, 30);
        vm.stopPrank();
    }

    function testSetPointsPerDay() public {
        vm.prank(owner);
        ldGame.setPointsPerDay(20);
        assertEq(ldGame.pointsPerDay(), 20);
    }

    function test_RevertWhen_SetPointsPerDayNotOwner2() public {
        vm.prank(personA);
        vm.expectRevert();
        ldGame.setPointsPerDay(20); // Should fail as personA is not the owner
    }
}
