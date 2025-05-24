//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "../lib/forge-std/src/Script.sol";
import {Ticket} from "../src/Ticket.sol";

contract DeployTicket is Script {
    function run() external returns (Ticket) {
        vm.startBroadcast();
        Ticket ticket = new Ticket();
        vm.stopBroadcast();
        return ticket;
    }
}
