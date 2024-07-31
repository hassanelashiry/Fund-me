// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

// interface AggregatorV3Interface {
//     function decimals() external view returns (uint8);
//     function description () external view returns (string memory);
//     function version () external view returns (uint256);

//     function getRoundData(uint80 _roundId)
//         external
//         view
//         returns (
//             uint80 roundId,
//             int256 answer,
//             uint256 startedAt,
//             uint256 updatedAt,
//             uint80 answeredInRound
//         );
// }
contract fundMe {

    // using aSafeMath
    using SafeMathChainlink for uint256; 

    mapping ( address => uint256 ) public addressToAmountFunded;

    //dynamic array for addresses for all funders
    address[] public funders;

    address public owner;
    constructor() public {
        owner = msg.sender;
    }

    function fund() public payable {
        // min value = 50$
        uint256 minimumUSD = 50* (10**18);
        require (getConversionRate(msg.value) >= minimumUSD, "you need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        // push every one who fund the contract
        funders.push(msg.sender);
    }

    function getVersion () public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x4ce657f2D015037d833a86F16436bE56d59E2d7D);
        return priceFeed.version();
    }
    // priceFeed = my wallet balance
    // Sepolia testnet address which connected to MetaMusk
    // "0x4ce657f2D015037d833a86F16436bE56d59E2d7D"

    function getPrice () public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x4ce657f2D015037d833a86F16436bE56d59E2d7D);
        (,int256 answer,,,)=priceFeed.latestRoundData();
        return uint256(answer*(10**10));
    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount);
        return ethAmountInUsd;
    }
    //solidity unit in Wei ( 1ETH = 10^9 Gwei = 10^18 Wei )
    
    modifier onlyOwner {      
        require (msg.sender == owner);
        _;
    }
    // A modifier is used to change the behavior of a function in a declarative way
    // onlyOwner who can withdraw tokens from the contract
    // using constractor to set msg.sender is the owner before deploy the contract  
    // then using the modifier to verify the satement
    // "_;" this commamnd to return back to function after verifing the require statement 


    function withdraw() public payable onlyOwner {
        payable (msg.sender).transfer(address(this).balance);
    // this means the contract you in
    // balance means in ETH
    // transfer token form this contract to my wallet
    // after widraw we need to reset the balance to zero
        for (uint256 funderIndex =0; funderIndex < funders.length; funderIndex++ ){
            address funder = funders[funderIndex];
            addressToAmountFunded [funder]=0;
        }
        funders = new address [](0); //blank address array
    }

}