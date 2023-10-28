// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./SafeMath.sol";

contract AccountAbilityChallenge is Ownable {
    using SafeMath for uint256;

    uint256 public challengeCount;

    struct Challenge {
        uint256 id;
        string name;
        uint256 duration;
        uint256 entryFee;
        uint256 maxParticipants;
        uint256 startTime;
        uint256 endTime;
        address creator;
        bool isChallengeActive;
    }

    struct ParticipantData {
        uint256 score;
        uint256 lastProofDate;
    }

    struct Participant {
        address participantAddress;
        uint256 challengeId;
    }

    struct ScoreData {
        address participant;
        uint256 score;
    }

    mapping(uint256 => Challenge) public challenges;
    mapping(uint256 => Participant[]) public challengeParticipants;
    mapping(address => uint256[]) public participantChallenges;
    mapping(uint256 => bool) public canEndChallenge;
    mapping(uint256 => mapping(address => ParticipantData))
        public challengeParticipantsData;
    mapping(uint256 => uint256) public challengeParticipantCounts;

    address public fitTokenAddress;

    event ChallengeCreated(uint256 challengeId, address creator);
    event ParticipantJoined(uint256 challengeId, address participant);
    event WorkoutProofSubmitted(
        uint256 challengeId,
        address participant,
        string proof
    );
    event ChallengeEnded(uint256 challengeId, address winner, uint256 reward);

    modifier challengeIsActive(uint256 challengeId) {
        require(
            challenges[challengeId].isChallengeActive,
            "Challenge is not active"
        );
        _;
    }

    constructor(address _fitTokenAddress) Ownable(msg.sender) {
        fitTokenAddress = _fitTokenAddress;
    }

    function createChallenge(
        string memory _name,
        uint256 _duration,
        uint256 _entryFee,
        bool _canEndChallenge
    ) external {
        require(_duration > 0, "Duration should be greater than 0");
        require(_entryFee > 0, "Entry fee should be greater than 0");

        challengeCount++;

        challenges[challengeCount] = Challenge({
            id: challengeCount,
            name: _name,
            duration: _duration,
            entryFee: _entryFee,
            maxParticipants: 10,
            startTime: block.timestamp,
            endTime: block.timestamp + _duration,
            creator: msg.sender,
            isChallengeActive: true
        });

        if (_canEndChallenge) {
            canEndChallenge[challengeCount] = true;
        }

        emit ChallengeCreated(challengeCount, msg.sender);
    }

    function joinChallenge(
        uint256 _challengeId
    ) external payable challengeIsActive(_challengeId) {
        require(
            msg.value >= challenges[_challengeId].entryFee,
            "Insufficient entry fee"
        );

        Challenge storage challenge = challenges[_challengeId];

        require(
            challengeParticipants[_challengeId].length <
                challenge.maxParticipants,
            "Challenge is full"
        );

        payable(fitTokenAddress).transfer(msg.value);

        challengeParticipants[_challengeId].push(
            Participant({
                participantAddress: msg.sender,
                challengeId: _challengeId
            })
        );

        participantChallenges[msg.sender].push(_challengeId);
        challengeParticipantCounts[_challengeId]++;

        emit ParticipantJoined(_challengeId, msg.sender);
    }

    function submitDailyProof(
        uint256 _challengeId
    ) external challengeIsActive(_challengeId) {
        Challenge storage challenge = challenges[_challengeId];
        ParticipantData storage participantData = challengeParticipantsData[
            _challengeId
        ][msg.sender];

        require(
            challengeParticipants[_challengeId].length > 0,
            "No participants in the challenge"
        );

        uint256 today = block.timestamp / 1 days;

        require(
            participantData.lastProofDate == 0,
            "You are not a participant in this challenge"
        );
        require(challenge.isChallengeActive, "The challenge is not active");

        if (today > participantData.lastProofDate) {
            participantData.score = participantData.score.add(1);
            participantData.lastProofDate = today;
        } else {
            revert("You have already submitted proof for today");
        }

        emit WorkoutProofSubmitted(
            _challengeId,
            msg.sender,
            "Daily workout proof submitted"
        );
    }

    function endChallenge(
        uint256 _challengeId
    ) external challengeIsActive(_challengeId) onlyOwner {
        Challenge storage challenge = challenges[_challengeId];
        require(
            block.timestamp >= challenge.endTime,
            "Challenge has not ended yet"
        );

        Participant[] storage participants = challengeParticipants[
            _challengeId
        ];

        require(participants.length > 0, "No participants in the challenge");

        uint256 totalPrizePool = (challenge.entryFee *
            participants.length *
            99) / 100;
        uint256 contractOwnerReward = (challenge.entryFee *
            participants.length *
            1) / 100;

        ScoreData[3] memory topScorers;

        for (uint256 i = 0; i < participants.length; i++) {
            address participantAddress = participants[i].participantAddress;
            uint256 score = challengeParticipantsData[_challengeId][
                participantAddress
            ].score;

            if (score > topScorers[0].score) {
                topScorers[2] = topScorers[1];
                topScorers[1] = topScorers[0];
                topScorers[0] = ScoreData(participantAddress, score);
            } else if (score > topScorers[1].score) {
                topScorers[2] = topScorers[1];
                topScorers[1] = ScoreData(participantAddress, score);
            } else if (score > topScorers[2].score) {
                topScorers[2] = ScoreData(participantAddress, score);
            }
        }

        address contractOwner = owner();
        address topScorer = topScorers[0].participant;
        address secondScorer = topScorers[1].participant;
        address thirdScorer = topScorers[2].participant;

        uint256 topScorerReward = (totalPrizePool * 50) / 100;
        uint256 secondScorerReward = (totalPrizePool * 30) / 100;
        uint256 thirdScorerReward = (totalPrizePool * 19) / 100;

        payable(contractOwner).transfer(contractOwnerReward);
        payable(topScorer).transfer(topScorerReward);
        payable(secondScorer).transfer(secondScorerReward);
        payable(thirdScorer).transfer(thirdScorerReward);

        challenge.isChallengeActive = false;

        emit ChallengeEnded(_challengeId, topScorer, topScorerReward);
    }
}
