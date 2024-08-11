// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "lib/forge-std/src/Test.sol";
import {IRouterClient, WETH9, LinkToken, BurnMintERC677Helper, CCIPLocalSimulator} from "@chainlink/local/src/ccip/CCIPLocalSimulator.sol";
import {CrossChainNameServiceRegister} from "../contracts/CrossChainNameServiceRegister.sol";
import {CrossChainNameServiceReceiver} from "../contracts/CrossChainNameServiceReceiver.sol";
import {CrossChainNameServiceLookup} from "../contracts/CrossChainNameServiceLookup.sol";

contract CCIPLS is Test {
    address public immutable ALICE = makeAddr("ALICE");
    CCIPLocalSimulator public ccipLocalSimulator;
    CrossChainNameServiceRegister public crossChainNameServiceRegister;
    CrossChainNameServiceReceiver public crossChainNameServiceReceiver;
    CrossChainNameServiceLookup public crossChainNameServiceLookup;
    int gasLeft;
    function setUp() public {
        vm.startBroadcast();
        ccipLocalSimulator = new CCIPLocalSimulator();
        (
            uint64 chainSelector,
            IRouterClient sourceRouter,
            IRouterClient destinationRouter,
            WETH9 wrappedNative,
            LinkToken linkToken,
            BurnMintERC677Helper ccipBnM,
            BurnMintERC677Helper ccipLnM
        ) = ccipLocalSimulator.configuration();
        crossChainNameServiceLookup = new CrossChainNameServiceLookup();
        crossChainNameServiceRegister = new CrossChainNameServiceRegister(address(sourceRouter), address(crossChainNameServiceLookup));
        crossChainNameServiceRegister.enableChain(chainSelector, address(sourceRouter), 200000);
        crossChainNameServiceReceiver = new CrossChainNameServiceReceiver(address(destinationRouter),address(crossChainNameServiceLookup),chainSelector); 
        crossChainNameServiceLookup.setCrossChainNameServiceAddress(address(crossChainNameServiceRegister));
        crossChainNameServiceLookup.setCrossChainNameServiceAddress(address(crossChainNameServiceReceiver));
        vm.stopBroadcast();
    }
    function test_register() public {   
        vm.prank(address(crossChainNameServiceReceiver));
        crossChainNameServiceLookup.register("alice.ccns" ,ALICE);
        if (ALICE == crossChainNameServiceLookup.lookup("alice.ccns")){
            console2.log("Truee");
        }
    }
}