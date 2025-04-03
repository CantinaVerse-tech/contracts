// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Test, console2 } from "forge-std/Test.sol";
import { HelperConfig } from "../../script/HelperConfig.s.sol";

contract HelperConfigTest is Test {
    HelperConfig public helperConfig;

    function setUp() public {
        helperConfig = new HelperConfig();
    }
}
