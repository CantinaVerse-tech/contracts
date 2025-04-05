// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";

contract HelperConfig is Script {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error HelperConfig__InvalidChainId();

    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/
    struct NetworkConfig {
        address initialOwner;
        address GelatoDedicatedMsgSender;
        uint256 serviceFee;
        address usdc;
        address weth;
        address finder;
        address currency;
        address optimisticOracleV3;
        address uniswapV3Factory;
        address uniswapV3SwapRouter;
        address uniswapNonFungiblePositionManager;
    }

    /*//////////////////////////////////////////////////////////////
                                CONFIGS
    //////////////////////////////////////////////////////////////*/
    function getSepoliaConfig() public view returns (NetworkConfig memory) {
        NetworkConfig memory SepoliaConfig = NetworkConfig({
            initialOwner: msg.sender,
            GelatoDedicatedMsgSender: 0x823F9f50f6A6E52CC4073Ff1493D4a8482D8Aba4,
            serviceFee: 0,
            usdc: address(0),
            weth: address(0),
            finder: 0xf4C48eDAd256326086AEfbd1A53e1896815F8f13,
            currency: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238, // Testnet USDC address
            optimisticOracleV3: 0xFd9e2642a170aDD10F53Ee14a93FcF2F31924944,
            uniswapV3Factory: address(0),
            uniswapV3SwapRouter: address(0),
            uniswapNonFungiblePositionManager: address(0)
        });
        return SepoliaConfig;
    }

    function getBaseSepoliaConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            initialOwner: msg.sender,
            GelatoDedicatedMsgSender: 0x823F9f50f6A6E52CC4073Ff1493D4a8482D8Aba4,
            serviceFee: 0,
            weth: 0x4200000000000000000000000000000000000006,
            usdc: 0x036CbD53842c5426634e7929541eC2318f3dCF7e,
            finder: 0xfF4Ec014E3CBE8f64a95bb022F1623C6e456F7dB,
            currency: 0x036CbD53842c5426634e7929541eC2318f3dCF7e, // Testnet USDC address
            optimisticOracleV3: 0x0F7fC5E6482f096380db6158f978167b57388deE,
            uniswapV3Factory: 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24,
            uniswapV3SwapRouter: 0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4,
            uniswapNonFungiblePositionManager: 0x27F971cb582BF9E50F397e4d29a5C7A34f11faA2
        });
    }

    function getOPSepoliaConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            initialOwner: msg.sender,
            GelatoDedicatedMsgSender: 0x823F9f50f6A6E52CC4073Ff1493D4a8482D8Aba4,
            serviceFee: 0,
            usdc: 0x5425890298aed601595a70AB815c96711a31Bc65,
            weth: 0x93567d6B6553bDe2b652FB7F197a229b93813D3f,
            finder: address(0),
            currency: address(0),
            optimisticOracleV3: address(0),
            uniswapV3Factory: address(0),
            uniswapV3SwapRouter: address(0),
            uniswapNonFungiblePositionManager: address(0)
        });
    }

    function getEthMainnetConfig() public view returns (NetworkConfig memory) {
        NetworkConfig memory EthMainnetConfig = NetworkConfig({
            initialOwner: msg.sender,
            GelatoDedicatedMsgSender: 0x823F9f50f6A6E52CC4073Ff1493D4a8482D8Aba4,
            serviceFee: 0,
            usdc: 0x5425890298aed601595a70AB815c96711a31Bc65,
            weth: 0x93567d6B6553bDe2b652FB7F197a229b93813D3f,
            finder: address(0),
            currency: address(0),
            optimisticOracleV3: address(0),
            uniswapV3Factory: address(0),
            uniswapV3SwapRouter: address(0),
            uniswapNonFungiblePositionManager: address(0)
        });
        return EthMainnetConfig;
    }

    function getCeloMainnetConfig() public view returns (NetworkConfig memory) {
        NetworkConfig memory CeloMainnetConfig = NetworkConfig({
            initialOwner: msg.sender,
            GelatoDedicatedMsgSender: 0x823F9f50f6A6E52CC4073Ff1493D4a8482D8Aba4,
            serviceFee: 0,
            usdc: 0x5425890298aed601595a70AB815c96711a31Bc65,
            weth: 0x93567d6B6553bDe2b652FB7F197a229b93813D3f,
            finder: address(0),
            currency: address(0),
            optimisticOracleV3: address(0),
            uniswapV3Factory: address(0),
            uniswapV3SwapRouter: address(0),
            uniswapNonFungiblePositionManager: address(0)
        });
        return CeloMainnetConfig;
    }

    function getModeMainnetConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            initialOwner: msg.sender,
            GelatoDedicatedMsgSender: 0x823F9f50f6A6E52CC4073Ff1493D4a8482D8Aba4,
            serviceFee: 0,
            usdc: 0x5425890298aed601595a70AB815c96711a31Bc65,
            weth: 0x93567d6B6553bDe2b652FB7F197a229b93813D3f,
            finder: address(0),
            currency: address(0),
            optimisticOracleV3: address(0),
            uniswapV3Factory: address(0),
            uniswapV3SwapRouter: address(0),
            uniswapNonFungiblePositionManager: address(0)
        });
    }

    function getOpMainnetConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            initialOwner: msg.sender,
            GelatoDedicatedMsgSender: 0x823F9f50f6A6E52CC4073Ff1493D4a8482D8Aba4,
            serviceFee: 0,
            usdc: 0x5425890298aed601595a70AB815c96711a31Bc65,
            weth: 0x93567d6B6553bDe2b652FB7F197a229b93813D3f,
            finder: address(0),
            currency: address(0),
            optimisticOracleV3: address(0),
            uniswapV3Factory: address(0),
            uniswapV3SwapRouter: address(0),
            uniswapNonFungiblePositionManager: address(0)
        });
    }

    function getBaseMainnetConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            initialOwner: msg.sender,
            GelatoDedicatedMsgSender: 0x823F9f50f6A6E52CC4073Ff1493D4a8482D8Aba4,
            serviceFee: 0,
            usdc: 0x5425890298aed601595a70AB815c96711a31Bc65,
            weth: 0x93567d6B6553bDe2b652FB7F197a229b93813D3f,
            finder: address(0),
            currency: address(0),
            optimisticOracleV3: address(0),
            uniswapV3Factory: address(0),
            uniswapV3SwapRouter: address(0),
            uniswapNonFungiblePositionManager: address(0)
        });
    }

    /*//////////////////////////////////////////////////////////////
                              LOCAL CONFIG
    //////////////////////////////////////////////////////////////*/
    function getAnvilConfig() public pure returns (NetworkConfig memory) {
        console2.log("Testing On Anvil Network");
        NetworkConfig memory AnvilConfig = NetworkConfig({
            initialOwner: address(1),
            GelatoDedicatedMsgSender: address(2),
            serviceFee: 0,
            usdc: 0x5425890298aed601595a70AB815c96711a31Bc65,
            weth: 0x93567d6B6553bDe2b652FB7F197a229b93813D3f,
            finder: address(0),
            currency: address(0),
            optimisticOracleV3: address(0),
            uniswapV3Factory: address(0),
            uniswapV3SwapRouter: address(0),
            uniswapNonFungiblePositionManager: address(0)
        });
        return AnvilConfig;
    }
}
