//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {DeployTicket} from "../script/DeployTicket.s.sol";
import {Ticket} from "../src/Ticket.sol";

contract BuyTicketTicket is Script {
    uint256 sendValue = 1 ether;

    function buyTicketTicket(address mostRecentDeployed) public {
        Ticket(payable(mostRecentDeployed)).buyTicket{value: sendValue}();

        console.log("Bought ticket with the amount of %s", sendValue);
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("Ticket", block.chainid);

        vm.startBroadcast();
        buyTicketTicket(mostRecentDeployed);
        vm.startBroadcast();
    }
}

contract WithdrawTicket is Script {
    Ticket ticket;

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("Ticket", block.chainid);

        vm.startBroadcast();
        withdrawTicket(mostRecentDeployed);
        vm.startBroadcast();
    }

    function withdrawTicket(address mostRecentDeployed) public {
        vm.prank(getOwner());
        Ticket(payable(mostRecentDeployed)).withdraw();
    }

    function getOwner() public returns (address) {
        DeployTicket deployTicket = new DeployTicket();
        ticket = deployTicket.run();
        address owner = ticket.getOwner();
        return owner;
    }
}
