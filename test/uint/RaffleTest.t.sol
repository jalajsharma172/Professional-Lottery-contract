// SPDX-License-Identifier: MIT

//Act+Enter
// / @title A title that should describe the contract/interface
// / @author The name of the author
// / @notice Explain to an end user what this does
// / @dev Explain to a developer any extra details
pragma solidity ^0.8.19;
 import {Raffle} from "../../src/Raffle.sol";
 import {HelperConfig} from "../../script/HelperConfig.sol";
 import {DeployRaffle} from "../../script/DeployRaffle.sol"; // Corrected spelling
 import {Test} from "@forge-std/src/Test.sol";


contract RaffleTest is Test{
    Raffle public raffle;
    HelperConfig public config;
    address public PLAYER=makeAddr("player");
    uint256 public Starting_PLAYER_BALANCE = 10 ether;
    
    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint256 subscriptionId;
    uint32 callbackGasLimit;

    event PickedWinner(address winner);
    event RequestedRaffleWinner(uint256 indexed requestId);
    event RaffleEnter(address indexed player);
    event WinnerPicked(address indexed player);
    
    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle(); // Corrected spelling
        (raffle, config) = deployRaffle.deployContract();
        HelperConfig.NetworkConfig memory helperConfig = config.getChain();
        entranceFee = helperConfig.entranceFee;
        interval = helperConfig.interval;
        vrfCoordinator = helperConfig.vrfCoordinator;
        gasLane = helperConfig.gasLane;
        subscriptionId = helperConfig.subscriptionId;
        callbackGasLimit = helperConfig.callbackGasLimit;
        vm.deal(PLAYER,Starting_PLAYER_BALANCE);
    }
    // function testRaffleInitializesInOpenState() public view { // Corrected spelling
    //     assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    // }

    function testRaffleRevertsWhenYouDontPayEnough() public {
        // Arrange
        vm.prank(PLAYER);

        // Act / Assert
        // vm.expectRevert(Raffle.Raffle__NotEnoughEthSent.selector);
        raffle.enterRaffle();
    }

    // function testRaffleRecordsPlayersWhenTheyEnter() public {
    //     // Arrange
    //     vm.prank(PLAYER);
    //     // Act
    //     raffle.enterRaffle{value: entranceFee}();
    //     // Assert
    //     address playerRecorded = raffle.getPlayer(0);
    //     assert(playerRecorded == PLAYER);
    // }

    // function test_EnterRaffle__EmittingEvents() public { // Corrected spelling
    //     // Arrange
    //     vm.prank(PLAYER);
    //     // Act
    //     vm.expectEmit(true, false, false, false, address(raffle));
    //     emit RaffleEnter(PLAYER);
    //     // Assert 
    //     raffle.enterRaffle{value: entranceFee}();
    // }

    // function testDontAllowPlayerToEnterWhileRaffleIsCalculating() public {
    //     // Arrange
    //     vm.prank(PLAYER);
    //     raffle.enterRaffle{value: entranceFee}();
        
    //     vm.warp(block.timestamp + interval + 1);
    //     vm.roll(block.number + 1);
        
    //     // Act
    //     vm.expectRevert("Raffle is calculating"); // Assuming this is the revert message
    //     raffle.enterRaffle{value: entranceFee}(); // Assert that player cannot enter
    // }

   
}
