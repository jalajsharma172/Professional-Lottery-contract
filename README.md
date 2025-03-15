## Proveably random raffle contracts
##  Wat do we want it to do?
    1. 
    2. Chainlink Automation -> Time based trigger's

## Tests!
1. Write deply scripts
    1. Note, these will not work on zkSync
2. Write tests
    1. Local chain
    2. Forked testnet
    3. Forked mainnet

### The `HelperConfig.s.sol` Contract
To retrieve the correct network configuration, we can create a new file in the same directory called `HelperConfig.s.sol` and define a **Network Configuration Structure**:
1.         struct NetworkConfig { // For Constructor Input 
            uint256 entranceFee;
            uint256 interval;
            address vrfCoordinator;
            bytes32 gasLane;
            uint256 subscriptionId;
            uint32 callbackGasLimit;
        }
### We'll then define two functions that return the _network-specific configuration_.
2.  We'll set up these functions for Sepolia and a local network.( https://docs.chain.link/vrf/v2-5/supported-networks)
-getSepoliaEthConfig() 
-getLocalEthConfig()
### We have stored them in  'networkConfigs' mapping 'mapping (uint256 chainID => NetworkConfig) private networkConfigs; '
 We'll then use these functions to set up the network configuration for our contracts.










## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**







Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
