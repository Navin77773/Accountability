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
            0x32cd5ecdA7f2B8633C00A0434DE28Db111E60636
        );
        return accountability;
    }
}
