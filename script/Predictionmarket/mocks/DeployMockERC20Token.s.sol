// // SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { MockERC20Token } from "./MockERC20Token.sol";

contract DeployMockERC20Token is Script {
    function run() external returns (MockERC20Token) {
        MockERC20Token mockToken = new MockERC20Token("MockToken", "MOCK", msg.sender);
        console2.log("MockToken deployed to: ", address(mockToken));
        return mockToken;
    }
}
