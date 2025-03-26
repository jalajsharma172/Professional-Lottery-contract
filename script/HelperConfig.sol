// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

abstract contract CodeConstants {
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
    uint96 public constant MOCK_BASE_FEE = 0.1 ether;
    uint96 public constant MOCK_GAS_PRICE_LINK = 100000000000; // 100 gwei
    int256 public constant MOCK_WEI_PER_UNIT_LINK = 86400; // 1 day
}
/**https://docs.chain.link/vrf/v2-5/supported-networks */
//  We'll set up these functions for Sepolia and a local network.
    contract HelperConfig is Script,CodeConstants {
        error Helper__InvaidChainID();
        struct NetworkConfig { // For Constructor Input 
            uint256 entranceFee;
            uint256 interval;
            address vrfCoordinator;
            bytes32 gasLane;
            uint256 subscriptionId;
            uint32 callbackGasLimit;
        }
        // NetworkConfig private localNetworkConfig;
        // NetworkConfig private sepoliaNetworkConfig;
        mapping (uint256 chainID => NetworkConfig) private networkConfigs;
        NetworkConfig private localNetworkConfig;
        constructor (){
            networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
            // networkConfigs[LOCAL_CHAIN_ID] = getLocalEthConfig();
        }


        function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
            NetworkConfig memory sepoliaNetworkConfig = NetworkConfig({
                entranceFee: .001 ether,//1000000000000000 wei
                interval:30,//30 sec
                vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
                gasLane:0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                subscriptionId: 0,
                callbackGasLimit: 300000
            });
            return sepoliaNetworkConfig;            
        }
        function getLocalEthConfig() public pure returns (NetworkConfig memory) {
            NetworkConfig memory localNetwork=  NetworkConfig({
                entranceFee: .001 ether,//1000000000000000 wei
                interval:30,//30 sec
                vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
                gasLane:0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                subscriptionId: 0,
                callbackGasLimit: 300000
            });
            return localNetwork;           
        }
        function getConfigByChainID(uint256 chainID) public returns (NetworkConfig memory) {//. Return based on ChainID .
            if (networkConfigs[chainID].vrfCoordinator != address(0)) { // Fixed condition
                revert Helper__InvaidChainID();
            }
            if (chainID == LOCAL_CHAIN_ID) {
                return getorcreateAnvilEthConfig(); // Correctly return the local config
            } else {
                return networkConfigs[chainID];
            }
        }

        function getChain() public returns (NetworkConfig memory) {
            return getConfigByChainID(block.chainid);//1. get the chain id
        }

        function getorcreateAnvilEthConfig() public  returns (NetworkConfig memory) {
            //check to see if wee see an active network config 
            if(localNetworkConfig.vrfCoordinator != address(0)) {
              return  localNetworkConfig; 
            }
            //Deploy mocks and such Always use VRFCoordinatorV2_5Mock to deploy
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock vrfcoordinator =new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE, MOCK_GAS_PRICE_LINK, MOCK_WEI_PER_UNIT_LINK);
            vm.stopBroadcast();

            localNetworkConfig = NetworkConfig({
                entranceFee: .001 ether,//1000000000000000 wei
                interval:30,//30 sec
                vrfCoordinator: address(vrfcoordinator),
                gasLane:0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                subscriptionId: 0,//have to set this up
                callbackGasLimit: 300000
            });
            return localNetworkConfig;
        }

}