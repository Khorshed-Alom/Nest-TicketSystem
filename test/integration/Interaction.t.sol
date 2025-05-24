//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DeployTicket} from "../../script/DeployTicket.s.sol";
import {BuyTicketTicket, WithdrawTicket} from "../../script/Interactions.s.sol";
import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {Ticket} from "../../src/Ticket.sol";

contract Interationstest is Test {
    Ticket ticket;

    function setUp() public {
        DeployTicket deployTicket = new DeployTicket();
        ticket = deployTicket.run();
    }

    function testBuyTicketTicket() public {
        BuyTicketTicket buyTicketTicket = new BuyTicketTicket();

        hoax(address(buyTicketTicket), 1 ether);
        buyTicketTicket.buyTicketTicket(address(ticket));

        address buyer = address(buyTicketTicket);
        assert(buyer == ticket.buyers(0));
    }

    function testWithdrawTicket() public {}
}
