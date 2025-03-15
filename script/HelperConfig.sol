pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

abstract contract CodeConstants {
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
}
/**https://docs.chain.link/vrf/v2-5/supported-networks */
//  We'll set up these functions for Sepolia and a local network.
    contract HelperConfig is Script,CodeConstants {
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

        constructor (){
            networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
            networkConfigs[LOCAL_CHAIN_ID] = getLocalEthConfig();
        }

        function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
            return (NetworkConfig{
                entranceFee: .001 ether,//1000000000000000 wei
                interval:30,//30 sec
                vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
                gasLane:0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                subscriptionId: 0,
                callbackGasLimit: 300000
            });
            
        }
        function getLocalEthConfig() public view returns (NetworkConfig memory) {
            return NetworkConfig{
                entranceFee: .001 ether,//1000000000000000 wei
                interval:30,//30 sec
                vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
                gasLane:0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                subscriptionId: 0,
                callbackGasLimit: 300000
            };
            
        }
        function getConfigByChainID(uint256 chainID) public view returns (NetworkConfig memory) {
            return networkConfigs[chainID];
        }

}   