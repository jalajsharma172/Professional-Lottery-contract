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

/**
 * @title Lottery Contract
 * @author Jalaj Sharma
 * @notice This contract is a simple raffle contract that allows users to enter the raffle by sending 0.01 ether.
 * @dev This contract is a simple raffle contract that allows users to enter the raffle by sending 0.01 ether.
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/dev/vrf/libraries/VRFV2PlusClient.sol";
//It Is Used To Get s_vrfCoordinator,fulfillRandomWords, rawFulfillRandomWords ,fulfillRandomWords[uint256 requestId, uint256[] memory randomWords]
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/dev/vrf/VRFConsumerBaseV2Plus.sol";
// AutomationCompatibleInterface, which is required for Chainlink automation.
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";

contract Raffle is VRFConsumerBaseV2Plus, AutomationCompatibleInterface {
    error Raffle__NotEnoughEthSent();
    error Zero_error();
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();
    error Raffle__UpkeepNotNeeded(
        uint256 currentBalance,
        uint256 numPlayers,
        uint256 raffleState
    );
    /**
   @dev Duration of the lottery in seconds
    */
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
    // bool private upkeepNeeded;
    enum RaffleState {
        // Type declarations
        OPEN, // 0
        CALCULATING // 1
    }
    RaffleState private s_raffleState;
    event PickedWinner(address winner);
    event RequestedRaffleWinner(uint256 indexed requestId);
    event RaffleEnter(address indexed player);
    event WinnerPicked(address indexed player);

    // Check me if I am working
    /**
     * @dev Constructor for the Raffle contract
     * @param entranceFee The fee to enter the raffle
     * @param interval The interval between raffles
     * @param vrfCoordinator The address of the VRF Coordinator
     * @param gasLane The gas limit for the VRF
     * @param subscriptionId The subscription id for the VRF
     * @param callbackGasLimit The gas limit for the VRF
     */
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
        s_raffleState = RaffleState.OPEN;
    }
    //Raffle Entery Starts
    function enterRaffle() external payable {
        //Checks :
        if (msg.value < i_entranceFee) revert Raffle__NotEnoughEthSent();
        if (s_raffleState != RaffleState.OPEN) revert Raffle__RaffleNotOpen(); // If not open you don't enter.
        //Effects :
        s_players.push(payable(msg.sender));
        emit RaffleEnter(msg.sender);
        //Interactions :
    }
    /**   
    *@dev When should the winner be picked?
    *@dev This is the function that the function that the chainlink node will call
    *to see if the lottery is ready to have winner picked.
    *the follwing should be true in order for upkeepneeded to be true :
        *1. The time internal has passed between raffle runs.(>i_interval)
        *2. The Lotter is opeen.
        *3. the contract have eth.
        *4. There are players registered.  

    * 5. Implicitly, your subscription is funded with LINK.
    */
    function checkUpkeep(
        bytes calldata /* checkData */
    ) public view returns (bool upkeepNeeded, bytes memory /* performData */) {
        bool isOpen = s_raffleState == RaffleState.OPEN;
        bool timeHashPassed = block.timestamp - s_lastTimeStamp >= i_interval;
        bool hasPlayer = s_players.length > 0;
        bool hasBalance = address(this).balance > 0;
        upkeepNeeded = timeHashPassed && isOpen && hasBalance && hasPlayer;

        return (upkeepNeeded, "0x0");
    }
        //     How VRF processes your request
        // After you submit your request, it is processed using the Request & Receive Data cycle. The VRF coordinator processes the request and determines the final charge to your subscription using the following steps:
        // The VRF coordinator emits an event.
        // The VRF service picks up the event and waits for the specified number of block confirmations to respond back to the VRF coordinator with the random values and a proof 
        // (
//     requestConfirmations
        // ).
        // The VRF coordinator verifies the proof onchain, then it calls back the consuming contract 
//  fulfillRandomWords function.
            //The contract autonomously picks a winner when specific conditions are met.

    function performUpkeep(bytes calldata /*performData*/) external override { // Find's A Winner 
        //Checks :
        (bool upkeepNeeded, ) = this.checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint(s_raffleState)//Current raffle state. 0/1
            );
        }

        //Effects : 
        //The raffle is no longer open for entries.
        s_raffleState = RaffleState.CALCULATING;// Changes the state to CALCULATING.
            /** 
            * @dev  This block constructs a random number request using Chainlink VRF (Verifiable Random Function).  
            * @dev keyHash: i_keyHash → Identifies the VRF key for randomness.
            * @dev subId: i_subscriptionId → Subscription ID that funds the request.
            * @dev requestConfirmations: RequestConfirmations → Number of block confirmations before fulfillment (reduces manipulation risk).
            * @dev callbackGasLimit: i_callbackGasLimit → Limits the gas used for the callback.
            * @dev numWords: NUM_Words → Number of random words requested                             [Obly 1]                                  (1 in this case).
            * @dev extraArgs → Encodes extra arguments. Here, it specifies that LINK payment is not in native tokens.
           */
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient // From VRFV2PlusClient.sol Created A Struct
            .RandomWordsRequest({
                keyHash: i_keyHash,     
                subId: i_subscriptionId,
                requestConfirmations: RequestConfirmations,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_Words,
                extraArgs: VRFV2PlusClient._argsToBytes( // Called  abi.encodeWithSelector(EXTRA_ARGS_V1_TAG, extraArgs);
                        VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                    )
            });
        //Requests a random number from Chainlink VRF.
        //
        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
        emit RequestedRaffleWinner(requestId);
    }

    //Checks-Effects-Interactions (CEI) Pattern
    // 1. Get a random number .
    // 2. Use the random number to pick a player .
    // 3. Automatically called .
    /*Your contract must implement the fulfillRandomWords function, 
    which is the callback VRF function. 
    Here, you add logic to handle the random values after they are returned to your contra  
    https://docs.chain.link/vrf/v2/subscription
    
     */
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        //Checks
        //Effect
        uint256 indexOfWinner = randomWords[0] % s_players.length; // 1. Get a random number .
        address payable winner = s_players[indexOfWinner]; // 2. Use the random number to pick a player .
        s_recentWinner = winner; //Save it
        s_players = new address payable[](0); //Delete Loser's
        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp; // Update The Time For Checking For Next Interval
        emit PickedWinner(msg.sender);

        //Interaction (External Contract Interaction)
        (bool success, ) = winner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
        emit RequestedRaffleWinner(requestId);
    }
    function getRaffleState() external view returns (RaffleState) {
        return s_raffleState;
    }
    function getPlayer(uint256 indexOfPlayer) external view returns (address) {
        return s_players[indexOfPlayer];
    }
}
