// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import {Test, console2} from "forge-std/Test.sol";
import {NFTRoulette} from "../../../src/games/NFTRoulette.sol";
import {NFT} from "./utils/NFT.sol";

contract NFTRouletteTest is Test {
    NFTRoulette roulette;
    NFT nft;
    NFT prizeNFT;

    address owner = address(1);
    address player1 = address(2);
    address player2 = address(3);

    uint256 constant ENTRY_FEE = 0.1 ether;
    uint256 constant MAX_RANGE = 100;

    function setUp() public {
        vm.startPrank(owner);
        nft = new NFT("TestNFT", "TNFT", "test");
        prizeNFT = new NFT("PrizeNFT", "PNFT", "prize");
        roulette = new NFTRoulette(address(prizeNFT));
        vm.stopPrank();

        // Setup players with ETH
        vm.deal(player1, 1 ether);
        vm.deal(player2, 1 ether);
    }

    function testCreateRound() public {
        vm.prank(owner);
        roulette.createRound(ENTRY_FEE, MAX_RANGE);

        // Verify round data
        (
            uint256 entryFee,
            uint256 prizePool,
            uint256 maxRange,
            bool active,
            bool completed,
            uint256 entriesCount
        ) = roulette.getRoundData(1);

        assertEq(entryFee, ENTRY_FEE);
        assertEq(prizePool, 0);
        assertEq(maxRange, MAX_RANGE);
        assertTrue(active);
        assertFalse(completed);
        assertEq(entriesCount, 0);
    }

    function test_RevertWhen_CreateRoundNotOwner() public {
        vm.prank(player1);
        vm.expectRevert();
        roulette.createRound(ENTRY_FEE, MAX_RANGE);
    }

    function testStakeNFT() public {
        // Create round
        vm.prank(owner);
        roulette.createRound(ENTRY_FEE, MAX_RANGE);

        // Mint and stake NFT
        vm.startPrank(player1);
        uint256 tokenId = nft.mintTo(player1);
        nft.approve(address(roulette), tokenId);
        roulette.stakeNFT{value: ENTRY_FEE}(1, address(nft), tokenId);
        vm.stopPrank();

        // Verify entry
        NFTRoulette.Entry[] memory entries = roulette.getRoundEntries(1);
        assertEq(entries.length, 1);
        assertEq(entries[0].player, player1);
        assertEq(entries[0].tokenId, tokenId);
        assertEq(entries[0].nftContract, address(nft));
        assertFalse(entries[0].returned);
    }

    function test_RevertWhen_StakeNFTInactiveRound() public {
        vm.startPrank(player1);
        uint256 tokenId = nft.mintTo(player1);
        nft.approve(address(roulette), tokenId);
        vm.expectRevert();
        roulette.stakeNFT{value: ENTRY_FEE}(1, address(nft), tokenId);
        vm.stopPrank();
    }

    function test_RevertWhen_StakeNFTIncorrectFee() public {
        // Create round
        vm.prank(owner);
        roulette.createRound(ENTRY_FEE, MAX_RANGE);

        // Try to stake with incorrect fee
        vm.startPrank(player1);
        uint256 tokenId = nft.mintTo(player1);
        nft.approve(address(roulette), tokenId);
        vm.expectRevert();
        roulette.stakeNFT{value: ENTRY_FEE - 0.01 ether}(
            1,
            address(nft),
            tokenId
        );
        vm.stopPrank();
    }

    function testSpinRoulette() public {
        // Create round and stake NFTs
        vm.prank(owner);
        roulette.createRound(ENTRY_FEE, MAX_RANGE);

        vm.startPrank(player1);
        uint256 tokenId1 = nft.mintTo(player1);
        nft.approve(address(roulette), tokenId1);
        roulette.stakeNFT{value: ENTRY_FEE}(1, address(nft), tokenId1);
        vm.stopPrank();

        vm.startPrank(player2);
        uint256 tokenId2 = nft.mintTo(player2);
        nft.approve(address(roulette), tokenId2);
        roulette.stakeNFT{value: ENTRY_FEE}(1, address(nft), tokenId2);
        vm.stopPrank();

        // Spin roulette
        vm.prank(owner);
        roulette.spinRoulette(1);

        // Verify round completion
        (, , , bool active, bool completed, ) = roulette.getRoundData(1);
        assertFalse(active);
        assertTrue(completed);
    }

    function test_RevertWhen_SpinRouletteNotOwner() public {
        vm.prank(owner);
        roulette.createRound(ENTRY_FEE, MAX_RANGE);

        vm.prank(player1);
        vm.expectRevert();
        roulette.spinRoulette(1);
    }

    function testReturnNFTs() public {
        // Create round and stake NFTs
        vm.prank(owner);
        roulette.createRound(ENTRY_FEE, MAX_RANGE);

        vm.startPrank(player1);
        uint256 tokenId1 = nft.mintTo(player1);
        nft.approve(address(roulette), tokenId1);
        roulette.stakeNFT{value: ENTRY_FEE}(1, address(nft), tokenId1);
        vm.stopPrank();

        vm.startPrank(player2);
        uint256 tokenId2 = nft.mintTo(player2);
        nft.approve(address(roulette), tokenId2);
        roulette.stakeNFT{value: ENTRY_FEE}(1, address(nft), tokenId2);
        vm.stopPrank();

        // Spin and return NFTs
        vm.prank(owner);
        roulette.spinRoulette(1);

        roulette.returnNFTs(1, 0, 2);

        // Verify NFTs are returned
        NFTRoulette.Entry[] memory entries = roulette.getRoundEntries(1);
        assertTrue(entries[0].returned);
        assertTrue(entries[1].returned);
    }

    function test_RevertWhen_ReturnNFTsActiveRound() public {
        vm.prank(owner);
        roulette.createRound(ENTRY_FEE, MAX_RANGE);

        vm.expectRevert();
        roulette.returnNFTs(1, 0, 1);
    }

    // function testEmergencyWithdraw() public {
    //     // Send some ETH to contract
    //     vm.deal(address(roulette), 1 ether);

    //     uint256 ownerBalanceBefore = owner.balance;

    //     vm.prank(owner);
    //     roulette.emergencyWithdraw();

    //     assertEq(address(roulette).balance, 0);
    //     assertEq(owner.balance, ownerBalanceBefore + 1 ether);
    // }

    function test_RevertWhen_EmergencyWithdrawNotOwner() public {
        vm.deal(address(roulette), 1 ether);

        vm.prank(player1);
        vm.expectRevert();
        roulette.emergencyWithdraw();
    }
}
