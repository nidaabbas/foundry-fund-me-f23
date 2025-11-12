// SPDX-License-Identifier: MIT

// 1. Deploy mock when we are on a local anvil chain
// 2. Keep track of contract addresses on different chains
//    - Sepolia ETH/USD
//    - Mainnet ETH/USD

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // If we are on a local anvil chain, we deploy a mock
    // Otherwise, grab the existing address from the live network
    NetworkConfig public activeNetworkConfig;

    uint8 public constant  DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        }else if (block.chainid == 1){
            activeNetworkConfig = getMainnetEthConfig();
        }
        
        else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // Sepolia ETH/USD price feed
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x514910771AF9Ca656af840dff83E8264EcF986CA
        });
        return ethConfig;
    }
    function getOrCreateAnvilConfig() public  returns (NetworkConfig memory){
        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }
        //1. Deploy the mocks
        //2. Return the mocks address
        
        vm.startBroadcast();
        MockV3Aggregator mockpriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
            );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockpriceFeed)
            });
            return anvilConfig;                                                            
    }
}
