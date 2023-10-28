// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {AbilityToken} from "../src/abilitytoken.sol";
import {Script} from "../lib/forge-std/src/Script.sol";

contract Deployabilitytoken is Script {
    AbilityToken ability;

    function run() external returns (AbilityToken) {
        vm.startBroadcast();
        ability = new AbilityToken(7000000 * 1e18);
        vm.stopBroadcast();
        return ability;
    }
}
