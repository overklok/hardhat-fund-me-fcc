// SPDX-License-Identifier: MIT
// Pragma
pragma solidity ^0.8.8;

// Imports
import "hardhat/console.sol";
import "./PriceConverter.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// Error Codes
error FundMe__NotOwner();

// Interfaces, Libraries, Contracts

/** @title A contract for crowdfunding
 *  @author Aleksandr Molodykh
 *  @notice This contract is to demo a sample funding contract
 *  @dev This implements price feeds as our library
 */
contract FundMe {
  // Type Declarations
  using PriceConverter for uint256;

  // State Variables
  address[] public funders;
  mapping(address => uint256) public addressToAmountFunded;
  uint256 public MINIMUM_USD = 50 * 1e18;
  address public immutable owner;

  AggregatorV3Interface public priceFeed;

  modifier onlyOwner() {
    if (msg.sender != owner) revert FundMe__NotOwner();
    _;
  }

  // Functions Order:
  //// constructor
  //// receive
  //// fallback
  //// external
  //// public
  //// internal
  //// private
  //// view / pure

  constructor(address priceFeedAddress) {
    owner = msg.sender;
    priceFeed = AggregatorV3Interface(priceFeedAddress);
  }

  /**
   *  @notice This function funds this contract
   *  @dev This implements price feeds as our library
   */
  function fund() public payable {
    console.log("Funding %s ETH from %s", msg.value, msg.sender);
    console.log("Sender balance is %s ETH", msg.sender.balance);

    // Want to be able to set a minumum fund amount in USD
    require(
      msg.value.getConversionRate(priceFeed) >= MINIMUM_USD,
      "You need to spend more ETH!"
    );

    funders.push(msg.sender);
    addressToAmountFunded[msg.sender] = msg.value;
  }

  function withdraw() public onlyOwner {
    console.log("Withdrawing %s ETH", address(this).balance);

    for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
      // code
      address funder = funders[funderIndex];
      addressToAmountFunded[funder] = 0;
    }

    // reset the array
    funders = new address[](0);

    // call
    (bool callSuccess, ) = payable(msg.sender).call{
      value: address(this).balance
    }("");
    require(callSuccess, "Call falied");
  }
}
