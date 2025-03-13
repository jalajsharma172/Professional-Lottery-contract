// Order of Function
// Functions should be grouped according to their visibility and ordered:
//1. constructor
//2. receive function (if exists)
//3. fallback function (if exists)
//4. external
//5. public
//6. internal
//7. private
//8.Within a grouping, place the view and pure functions las

// Order of Layout
// 1. Contract elements should be laid out in the following order:
//             Pragma statements
//             Import statements
//             Events
//             Errors
//             Interfaces
//             Libraries
//             Contracts
// 2. Inside each contract, library or interface, use the following order:
//             Type declarations
//             State variables
//             Events
//             Errors
//             Modifiers
//             Functions

/*
 * @title Raffle
 * @author Jalaj Sharma
 * @notice This contract is a simple raffle contract that allows users to enter the raffle by sending 0.01 ether.
 *@dev This contract is a simple raffle contract that allows users to enter the raffle by sending 0.01 ether.
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
contract Raffle {
    error Raffle__NotEnoughEthSent();

    uint256 private immutable i_entranceFee;
    // @dev Duration of the lottery in seconds
    uint256 private immutable i_interval;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;

    event EnteredRaffle(address indexed player);

    constructor(uint256 entranceFee, uint256 interval) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp
    }
    // 1. Get a random number[from Chainlink VRF]
    // 2. Use the random number to pick a player
    // 3. Automatically called
    function pickWinner() external view {
        // check to see if enough time has passed
        if (block.timestamp - s_lastTimeStamp < i_interval) revert();

        // requestId = COORDINATOR.requestRandomWords(
        //     keyHash,
        //     s_subscriptionId,
        //     requestConfirmations,
        //     callbackGasLimit,
        //     numWords
        // );
    }
}
