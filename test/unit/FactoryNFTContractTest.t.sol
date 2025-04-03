// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import { Test, console2, Vm } from "forge-std/Test.sol";
import { HelperConfig } from "../../script/HelperConfig.s.sol";
import { FactoryNFTContract } from "../../src/marketplace/FactoryNFTContract.sol";
import { DeployFactoryNFTContract } from "../../script/DeployFactoryNFTContract.s.sol";

contract FactoryNFTContractTest is Test {
    HelperConfig config;
    FactoryNFTContract factory;
    DeployFactoryNFTContract deployer;

    event CollectionCreated(
        address indexed collectionAddress,
        string indexed name,
        string indexed symbol,
        uint256 maxSupply,
        address owner,
        uint256 royaltyPercentage,
        uint256 mintPrice
    );

    string name = "MY NFT COLLECTION";
    string symbol = "MYCOL";
    string baseURI = "https://silver-selective-kite-794.mypinata.cloud/ipfs/";
    uint256 maxSupply = 10;
    address payable PERSONAL = payable(address(uint160(123)));
    uint96 royaltyPercentage = 10;
    uint256 mintPrice = 0;
    string metadataURI = "https://silver-selective-kite-794.mypinata.cloud/ipfs/";

    function setUp() public {
        config = new HelperConfig();
        deployer = new DeployFactoryNFTContract();
        factory = deployer.run();

        vm.deal(factory.owner(), 10 ether);
    }

    function testRevertOnUnsupportedNetwork() public {
        vm.chainId(1); // Ethereum mainnet, which is not supported in your script
        vm.expectRevert("Unsupported network");
        deployer.run();
    }

    function testFactoryConstructorSetsInitialOwnerCorrectly() public {
        vm.startPrank(msg.sender);
        FactoryNFTContract testFactory = new FactoryNFTContract(msg.sender, 0);
        assertEq(testFactory.owner(), msg.sender);
        vm.stopPrank();
    }

    function testSuccessfulCreateCollection() public {
        vm.prank(factory.owner());
        factory.createCollection(name, symbol, maxSupply, factory.owner(), royaltyPercentage, mintPrice, metadataURI);
        assertEq(factory.getAllCollections().length, 1);
    }

    function test_FactoryNFTContract__InsufficientFunds() public {
        uint256 testPrice = 1 ether;

        vm.startPrank(factory.owner());
        factory.setFee(1 ether);
        assertEq(factory.getFee(), 1 ether, "Fee was not set correctly");
        vm.stopPrank();

        vm.startPrank(PERSONAL);
        vm.expectRevert(FactoryNFTContract.FactoryNFTContract__InsufficientFunds.selector);
        factory.createCollection{ value: 0 ether }(
            name, symbol, maxSupply, PERSONAL, royaltyPercentage, testPrice, metadataURI
        );
        vm.stopPrank();
    }

    function test_FactoryNFTContract_WithdrawSuccessful() public {
        uint256 testPrice = 1 ether;

        vm.startPrank(factory.owner());
        factory.setFee(1 ether);
        vm.stopPrank();

        vm.startPrank(factory.owner());
        factory.createCollection{ value: testPrice }(
            name, symbol, maxSupply, factory.owner(), royaltyPercentage, mintPrice, metadataURI
        );
        vm.stopPrank();

        assertEq(factory.getAllCollections().length, 1);

        vm.startPrank(factory.owner());
        factory.withdraw(PERSONAL, testPrice);
        vm.stopPrank();

        assertEq(address(PERSONAL).balance, testPrice);
    }

    function test_FactoryNFTContract__CantBeZeroAddress() public {
        uint256 testPrice = 1 ether;

        vm.startPrank(factory.owner());
        factory.setFee(1 ether);
        vm.stopPrank();

        vm.startPrank(factory.owner());
        factory.createCollection{ value: testPrice }(
            name, symbol, maxSupply, factory.owner(), royaltyPercentage, mintPrice, metadataURI
        );
        vm.stopPrank();

        vm.startPrank(factory.owner());
        vm.expectRevert(FactoryNFTContract.FactoryNFTContract__CantBeZeroAddress.selector);
        factory.withdraw(payable(address(0)), testPrice);
        vm.stopPrank();
    }

    function test_FactoryNFTContract__CantBeZeroAmount() public {
        uint256 testPrice = 1 ether;

        vm.startPrank(factory.owner());
        factory.setFee(1 ether);
        vm.stopPrank();

        vm.startPrank(factory.owner());
        factory.createCollection{ value: testPrice }(
            name, symbol, maxSupply, factory.owner(), royaltyPercentage, mintPrice, metadataURI
        );
        vm.stopPrank();

        vm.startPrank(factory.owner());
        vm.expectRevert(FactoryNFTContract.FactoryNFTContract__CantBeZeroAmount.selector);
        factory.withdraw(PERSONAL, 0);
        vm.stopPrank();
    }

    function testSetFee() public {
        vm.startPrank(factory.owner());
        uint256 expectedFee = 1 ether;
        factory.setFee(expectedFee);
        vm.stopPrank();

        assertEq(factory.getFee(), expectedFee);
    }
}
