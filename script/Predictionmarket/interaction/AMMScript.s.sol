// // SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../../HelperConfig.s.sol";
import { AMMContract } from "../../../src/predictionmarket//AMMContract.sol";

contract AMMScript is Script {
    function run() external {
        // HelperConfig helperConfig = new HelperConfig();
        vm.startBroadcast();
        AMMContract amm = AMMContract(0xC61Ba80Ab399e6F199aA4f5c0302eF7e0C66B7F8);
        address tokenA = 0x036CbD53842c5426634e7929541eC2318f3dCF7e;
        address tokenB = 0x808456652fdb597867f38412077A9182bf77359F;
        uint24 fee = 5_000_000;
        bytes32 marketId = 0x0000000000000000000000000000000000000000000000000000000000000001;
        amm.initializePool(tokenA, tokenB, fee, marketId);
        console2.log("Pool Address: ", address(amm));
        vm.stopBroadcast();
    }
}
