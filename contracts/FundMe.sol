// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

// import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    // using SafeMathChainlink for uint256;

    address public owner;
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() public payable {
        uint256 minimunUsd = 50 * 10 ** 18;
        require(
            getConvertionRate(msg.value) >= minimunUsd,
            "You need to send more ETH!"
        ); //if(msg.value < minimunUsd){}
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
        // what the ETH -> USD conversion rate
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();

        return uint256(answer * 10000000000);
        // *10000000000 to have 18 digits
    }

    function getConvertionRate(
        uint256 ethAmount
    ) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethamountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethamountInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        // minumum USD
        uint256 minimumUSD = 50 * 10 ** 18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10 ** 18;
        return (minimumUSD * precision) / price;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only contract owner can call this");
        _;
    }

    function withdraw() public payable onlyOwner {
        // casting the msg.sender address to make it payable
        address payable _msg_sender = payable(address(msg.sender));
        _msg_sender.transfer(address(this).balance);

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);
    }
}
