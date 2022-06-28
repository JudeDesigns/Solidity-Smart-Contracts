//Get funds from users
//Withdraw funds
//Set a minimum value in USD

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./PriceConverter.sol";

contract FundMe {

    using PriceConverter for uint256;
    uint256 public minimumUSD = 50 * 1e18;
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    address public contractOwner;

    constructor(){
        contractOwner = msg.sender;
    }

    function fund() public payable{
        require (msg.value.getConversionRate() >= minimumUSD, "Didn't send enough!");
        funders.push(msg.sender);
    }

    function withdraw() public onlyOwner{

        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        //in order to send blockchain currency from contract, msg.sender has to be of type payable address
        /* payable(msg.sender).transfer(address(this).balance);
        bool sentSuccessfully = payable(msg.sender).send(address(this).balance);
        require(sentSuccessfully, "Didn't go through"); */

        (bool callSuccess,) = payable(msg.sender).call{value:address(this).balance}("");
        require (callSuccess, "Call failed");
    }

    modifier onlyOwner {
        require (msg.sender == contractOwner, "You are not the owner of the contract");
        _;
    }
 
}