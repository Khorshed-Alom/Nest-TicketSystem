//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DeployTicket} from "../../script/DeployTicket.s.sol";
import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {Ticket} from "../../src/Ticket.sol";

contract TestTicket is Test {
    Ticket ticket;
    address USER = makeAddr("user");
    uint256 constant startingBalance = 10 ether;
    uint256 constant sendBalance = 0.1 ether;

    function setUp() external {
        DeployTicket deployTicket = new DeployTicket();
        ticket = deployTicket.run();
        vm.deal(USER, startingBalance);
    }

    function testAlradyBoughtTicket() public {
        vm.prank(USER);
        ticket.buyTicket{value: sendBalance}();

        vm.prank(USER);
        vm.expectRevert();
        ticket.buyTicket{value: sendBalance}();
    }

    function testOwnerCanWithdraw() public {
        vm.prank(USER);
        ticket.buyTicket{value: sendBalance}();

        //vm.prank(address(1));
        vm.prank(USER); // msg.sender is the owner
        vm.expectRevert();
        ticket.withdraw();
    }

    function testOwner() public view {
        assertEq(ticket.getOwner(), msg.sender);
    }

    function testResetCanDeleteArray() public {
        vm.prank(USER);
        ticket.buyTicket{value: sendBalance}();
        hoax(address(1), sendBalance);
        ticket.buyTicket{value: sendBalance}();

        vm.prank(msg.sender);
        ticket.reset();
        assertEq(0, ticket.getBuyers().length);
    }

    function testTicketLeft() public {
        vm.prank(USER);
        ticket.buyTicket{value: sendBalance}();
        hoax(address(1), sendBalance);
        ticket.buyTicket{value: sendBalance}();
        hoax(address(2), sendBalance);
        ticket.buyTicket{value: sendBalance}();

        uint256 ticketRemain = ticket.ticketsLeft();

        // ticket should left 97
        assertEq(97, ticketRemain);
    }

    function testMappingUserIsTrue() public {
        vm.prank(USER);
        ticket.buyTicket{value: sendBalance}();
        hoax(address(1), sendBalance);
        ticket.buyTicket{value: sendBalance}();

        bool firstTrueId = ticket.hasAlreadyBought(USER);
        bool secondTrueId = ticket.hasAlreadyBought(address(1));

        assert(firstTrueId && secondTrueId);
    }

    function testOwnerBalance() public {
        vm.prank(USER);
        ticket.buyTicket{value: sendBalance}();
        uint256 startingOwnerBalance = ticket.getOwner().balance;
        uint256 startingTicketbalance = address(ticket).balance;

        vm.prank(ticket.getOwner());
        ticket.withdraw();

        uint256 endingOwnerbalance = ticket.getOwner().balance;
        uint256 endingTicketBalance = address(ticket).balance;

        assertEq(endingTicketBalance, 0);
        assertEq(startingOwnerBalance + startingTicketbalance, endingOwnerbalance);
    }

    function testOldUserCanBuyTicketAgain() public {
        vm.prank(USER);
        ticket.buyTicket{value: sendBalance}();

        vm.prank(ticket.getOwner());
        ticket.reset();

        bool userStatus = ticket.hasAlreadyBought(USER);
        assertEq(userStatus, false);
    }

    function testOutOfTicket() public {
        vm.prank(USER);
        ticket.buyTicket{value: sendBalance}();

        for (uint160 i = 1; i < 100; i++) {
            hoax(address(i), sendBalance);
            ticket.buyTicket{value: sendBalance}();
        }

        hoax(address(101), sendBalance);
        vm.expectRevert();
        ticket.buyTicket{value: sendBalance}();
    }
}
