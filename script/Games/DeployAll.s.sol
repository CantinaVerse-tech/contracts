// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { CoinFlip } from "../../src/games/CoinFlip.sol";
import { NFTLuckyDraw } from "../../src/games/NFTLuckyDraw.sol";
import { NFTRoulette } from "../../src/games/NFTRoulette.sol";
import { PrizeNFT } from "../../src/games/NFTRoulette/PrizeNFT.sol";
import { NFTStakingEvolution } from "../../src/games/NFTStakingEvolution.sol";
import { EvolvableNFT } from "../../src/games/NFTStakingEvolution/EvolvableNFT.sol";

contract DeployAll is Script {
    function run() external {
        HelperConfig helpConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config;

        config = helpConfig.getBaseSepoliaConfig();

        vm.startBroadcast();
        CoinFlip coinflip = new CoinFlip();
        NFTLuckyDraw nftluckydraw = new NFTLuckyDraw();
        PrizeNFT prizenft = new PrizeNFT("Test Collection", "TEST", "https://impfs.io/ipfs/");
        NFTRoulette nftroulette = new NFTRoulette();
        EvolvableNFT evolvableNFT = new EvolvableNFT("https://ipfs.io/ipfs/");
        NFTStakingEvolution nftstakingevolution = new NFTStakingEvolution(address(evolvableNFT));
        vm.stopBroadcast();
        console2.log("CoinFlip deployed at:", address(coinflip));
        console2.log("NFTLuckyDraw deployed at:", address(nftluckydraw));
        console2.log("PrizeNFT deployed at:", address(prizenft));
        console2.log("NFTRoulette deployed at:", address(nftroulette));
        console2.log("EvolvableNFT deployed at:", address(evolvableNFT));
        console2.log("NFTStakingEvolution deployed at:", address(nftstakingevolution));
        console2.log("Initial owner:", config.initialOwner);
    }
}
