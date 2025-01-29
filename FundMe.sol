// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;
    uint public constant MINIMUN_USD = 5e18;
    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmoutFunded;
    address public immutable i_owner;

    constructor() {
        i_owner=msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate()>=MINIMUN_USD, "Didn't send enough ETH");
        funders.push(msg.sender);
        addressToAmoutFunded[msg.sender]+=msg.value;
    }

    function withdraw() public onlyOwner {
        for(uint256 idx=0;idx<funders.length;idx++){
            address funder=funders[idx];
            addressToAmoutFunded[funder]=0;
        }
        funders=new address[](0);

        (bool callSucess, ) = payable(msg.sender).call{value:address(this).balance}("");
        require(callSucess, "Call Failed");
    }

    modifier onlyOwner() {
        require(msg.sender==i_owner, "Must be an OWNER!");
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}