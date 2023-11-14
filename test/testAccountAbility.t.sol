// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "../src/AccountAbility.sol";

contract AccountAbilityChallengeTest is DSTest {
    AccountAbilityChallenge challenge;
    address fitTokenAddress;
    address ownerAddress;

    function setUp() public {
        fitTokenAddress = address(0x32cd5ecdA7f2B8633C00A0434DE28Db111E60636); // Replace with your FitToken contract address
        ownerAddress = address(this);
        challenge = new AccountAbilityChallenge(fitTokenAddress);
        challenge.createChallenge("Test Challenge", 100, 10, false);
    }

    function testCreateChallenge() public {
        (
            uint256 id,
            string memory name,
            uint256 duration,
            uint256 entryFee,
            uint256 maxParticipants,
            uint256 startTime,
            uint256 endTime,
            address creator,
            bool isChallengeActive
        ) = challenge.challenges(1);

        assertEq(id, 1);
        assertEq(name, "Test Challenge");
        assertEq(duration, 100);
        assertEq(entryFee, 10);
        assertEq(maxParticipants, 10);
        assertTrue(startTime <= block.timestamp);
        assertTrue(endTime > block.timestamp);
        assertEq(creator, ownerAddress);
        assertTrue(isChallengeActive);
    }

    function testJoinChallenge() public {
        uint256 challengeId = 1;
        uint256 entryFee = 10;

        challenge.joinChallenge{value: entryFee}(challengeId);
        challenge.joinChallenge{value: entryFee}(challengeId);
        challenge.joinChallenge{value: entryFee}(challengeId);

        AccountAbilityChallenge.Participant[] memory participants = challenge
            .getChallengeParticipants(challengeId);

        assertEq(participants.length, 3);

        assertEq(participants[0].participantAddress, ownerAddress);
        assertEq(participants[1].participantAddress, ownerAddress);
        assertEq(participants[2].participantAddress, ownerAddress);
    }

    function testSubmitDailyProof() public {
        uint256 challengeId = 1;

        challenge.submitDailyProof(challengeId);
        challenge.submitDailyProof(challengeId);

        (uint256 score, ) = challenge.challengeParticipantsData(
            challengeId,
            ownerAddress
        );
        address participantAddress = ownerAddress;

        assertEq(participantAddress, ownerAddress);
        assertEq(score, 2);
    }

    function testEndChallenge() public {
        uint256 challengeId = 1;

        challenge.joinChallenge{value: 10 ether}(challengeId);
        challenge.submitDailyProof(challengeId);
        challenge.submitDailyProof(challengeId);

        challenge.joinChallenge{value: 10 ether}(challengeId);
        challenge.submitDailyProof(challengeId);

        uint256 initialBalanceOwner = address(this).balance;

        challenge.endChallenge(challengeId);

        uint256 finalBalanceOwner = address(this).balance;

        assertEq(finalBalanceOwner, initialBalanceOwner + 9 ether);
    }
}
