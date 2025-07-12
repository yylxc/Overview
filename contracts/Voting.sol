// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.20;

import "fhevm/abstracts/EIP712WithModifier.sol";
import "fhevm/lib/TFHE.sol";

contract Voting is EIP712WithModifier {
    address public owner;
    mapping(uint32 => euint32) public candidateTallies; // Encrypted vote counts per candidate
    mapping(address => bool) public hasVoted; // Track voters
    uint32 public candidateCount;
    euint32 public totalVotes; // Encrypted total vote count

    constructor(uint32 _candidateCount) EIP712WithModifier("Voting", "1") {
        owner = msg.sender;
        candidateCount = _candidateCount;
        totalVotes = TFHE.asEuint32(0); // Initialize encrypted total to 0
    }

    // Submit an encrypted vote for a candidate
    function vote(uint32 candidateId, bytes calldata encryptedVote) public {
        require(!hasVoted[msg.sender], "Already voted");
        require(candidateId < candidateCount, "Invalid candidate ID");

        // Decrypt vote locally (assumes client-side encryption)
        euint32 voteValue = TFHE.asEuint32(encryptedVote);
        require(TFHE.decrypt(TFHE.eq(voteValue, TFHE.asEuint32(1))), "Vote must be 1");

        // Update encrypted tally
        candidateTallies[candidateId] = TFHE.add(candidateTallies[candidateId], voteValue);
        totalVotes = TFHE.add(totalVotes, voteValue);
        hasVoted[msg.sender] = true;

        // Allow contract to use encrypted values
        TFHE.allowThis(candidateTallies[candidateId]);
        TFHE.allowThis(totalVotes);
    }

    // Decrypt tally for a candidate (owner only)
    function getCandidateTally(uint32 candidateId) public view onlyOwner returns (uint32) {
        require(candidateId < candidateCount, "Invalid candidate ID");
        return TFHE.decrypt(candidateTallies[candidateId]);
    }

    // Decrypt total votes (owner only)
    function getTotalVotes() public view onlyOwner returns (uint32) {
        return TFHE.decrypt(totalVotes);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }
}
