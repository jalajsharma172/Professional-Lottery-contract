// Ctl+ Move Down
// Alt+Down
// Ct
// Ctl+ P IMP For Opening Library Files's
// Order of Function
// Functions should be grouped according to their visibility and ordered:
//1. constructor
//2. receive function (if exists)
//3. fallback function (if exists)
//4. external
//5. public
//6. internal
//7. private
//8.Within a grouping, place the view and pure functions last.

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
 * @title Lottery Contract
 * @author Jalaj Sharma
 * @notice This contract is a simple raffle contract that allows users to enter the raffle by sending 0.01 ether.
 *@dev This contract is a simple raffle contract that allows users to enter the raffle by sending 0.01 ether.
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/dev/vrf/libraries/VRFV2PlusClient.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/dev/vrf/VRFConsumerBaseV2Plus.sol";

contract Raffle is VRFConsumerBaseV2Plus {
    error Raffle__NotEnoughEthSent();
    error Zero_error();
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();

    // @dev Duration of the lottery in seconds
    uint16 private constant RequestConfirmations = 2;
    uint32 private constant NUM_Words = 1;
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    address private s_recentWinner;
    enum RaffleState {
        // Type declarations
        OPEN, // 0
        CALCULATING // 1
    }
    RaffleState private s_raffleState;
    event EnteredRaffle(address indexed player);
     event PickedWinner(address winner);   
    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN; //Entry Start's
    }

    function enterRaffle() external payable {
        //Checks :
        if (msg.value < i_entranceFee) revert Raffle__NotEnoughEthSent();
        if (s_raffleState != RaffleState.OPEN) revert Raffle__RaffleNotOpen(); // If not open you don't enter.
        //Effects :
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }
    //Checks-Effects-Interactions (CEI) Pattern
    function pickWinner() external returns (uint256) {      
        //Checks :
        if (block.timestamp - s_lastTimeStamp < i_interval) revert();  // check to see if enough time has passed
           s_raffleState = RaffleState.CALCULATING;  //Stop Entry for now
        //Effects :
        // check to see if there are any players
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: RequestConfirmations,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_Words,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            });

        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
        return requestId;
    }

    //     function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
    //     uint256 indexOfWinner = randomWords[0] % s_players.length;
    //     address payable winner = s_players[indexOfWinner];
    // }
    
    //Checks-Effects-Interactions (CEI) Pattern
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        //Checks
        //Effect
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner = winner;//Save it
        s_players = new address payable[](0);
        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;       
        //Interaction (External Contract Interaction)
        (bool success, ) = winner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
       emit PickedWinner(msg.sender);
    }
}
