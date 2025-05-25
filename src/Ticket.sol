//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
*@dev this contract has no minimum amount limit.
*/
contract Ticket {
    address[] public buyers;
    address private immutable owner;

    error ownerRequired();

    mapping(address => bool) public hasAlreadyBought;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert ownerRequired();
        }
        _;
    }

    function buyTicket() public payable {
        require(buyers.length < 100, "OUT OF TIKETS");
        require(!hasAlreadyBought[msg.sender], "ONE TIME BUYE ONLY");
        buyers.push(msg.sender);
        hasAlreadyBought[msg.sender] = true;
    }

    function withdraw() public onlyOwner {
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "WITHDRAW FAILED");
    }

    function reset() public onlyOwner {
        uint256 buyersLength = buyers.length;
        for (uint256 i = 0; i < buyersLength; i++) {
            hasAlreadyBought[buyers[i]] = false;
        }
        //delete buyers;
        buyers = new address[](0);
    }

    function ticketsLeft() external view returns (uint256) {
        uint256 soldTickets = 100 - buyers.length;
        return soldTickets;
    }

    fallback() external payable {
        buyTicket();
    }

    receive() external payable {
        buyTicket();
    }

    //getter
    function getOwner() external view returns (address) {
        return owner;
    }

    //getter
    function getBuyers() external view returns (address[] memory) {
        return buyers;
    }

    //getter
    // function getABuyer( uint256 index) external view returns(address) {
    // 	return buyers[index];
    // }
}
