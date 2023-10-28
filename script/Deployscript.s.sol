// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title all Scripts Page
 * @author 0xhope7
 * @notice a container of all scripts of projects essential to learn testing.
 */

import {AccountAbilityChallenge} from "../src/AccountAbility.sol";
import {Script} from "../lib/forge-std/src/Script.sol";

contract DeployAccountability is Script {
    AccountAbilityChallenge accountability;

    function run() external returns (AccountAbilityChallenge) {
        accountability = new AccountAbilityChallenge(
            0xC7f2Cf4845C6db0e1a1e91ED41Bcd0FcC1b0E141
        );
        return accountability;
    }
}
