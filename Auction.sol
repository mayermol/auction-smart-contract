// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Auction
 * @dev Smart contract for a timed auction with bid validation, auto-extension, partial withdrawals, and a 2% commission on refunds.
 */
contract Auction {
    address public owner;
    uint public auctionEndTime;
    uint private constant MIN_BID_INCREMENT_PERCENT = 5;
    uint private constant EXTENSION_TIME = 10 minutes;
    uint private constant COMMISSION_PERCENT = 2;

    address private highestBidder;
    uint private highestBid;

    bool private auctionEnded;

    mapping(address => uint) private pendingReturns;
    mapping(address => uint) private lastValidBid;
    address[] private bidders;

    event NewBid(address indexed bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    // Restricts access to the contract owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this.");
        _;
    }

    // Ensures the auction is still active
    modifier auctionActive() {
        require(block.timestamp < auctionEndTime, "Auction has ended.");
        require(!auctionEnded, "Auction already finalized.");
        _;
    }

    // Ensures the auction has finished
    modifier auctionEndedOnly() {
        require(block.timestamp >= auctionEndTime || auctionEnded, "Auction is still ongoing.");
        _;
    }

    /**
     * @dev Constructor initializes the auction with a duration (in seconds).
     * @param _durationInSeconds Duration of the auction in seconds.
     */
    constructor(uint _durationInSeconds) {
        owner = msg.sender;
        auctionEndTime = block.timestamp + _durationInSeconds;
    }

    /**
     * @dev Allows users to place a bid.
     * Requirements:
     * - Must send ETH.
     * - Must be at least 5% higher than the current highest bid.
     * - Extends auction if bid is placed within last 10 minutes.
     */
    function placeBid() external payable auctionActive {
        require(msg.value > 0, "You must send ETH to bid.");

        uint minRequired = highestBid + (highestBid * MIN_BID_INCREMENT_PERCENT) / 100;
        require(msg.value >= minRequired || highestBid == 0, "Bid must exceed previous by at least 5%.");

        // Register new bidder if first time
        if (pendingReturns[msg.sender] == 0) {
            bidders.push(msg.sender);
        }

        // Update deposit and last valid bid
        pendingReturns[msg.sender] += msg.value;
        lastValidBid[msg.sender] = msg.value;

        // Update highest bid info
        highestBid = msg.value;
        highestBidder = msg.sender;

        // Extend auction if within the last 10 minutes
        if (auctionEndTime - block.timestamp <= EXTENSION_TIME) {
            auctionEndTime += EXTENSION_TIME;
        }

        emit NewBid(msg.sender, msg.value);
    }

    /**
     * @dev Allows a bidder to withdraw the excess funds over their last valid bid during the auction.
     * Example: Deposited 3 ETH, last valid bid = 2 ETH → can withdraw 1 ETH
     */
    function withdrawExcessDuringAuction() external auctionActive {
        uint totalDeposited = pendingReturns[msg.sender];
        uint lastBid = lastValidBid[msg.sender];

        require(totalDeposited > lastBid, "No excess to withdraw.");

        uint excess = totalDeposited - lastBid;
        pendingReturns[msg.sender] = lastBid;

        payable(msg.sender).transfer(excess);
    }

    /**
     * @dev Ends the auction. Can only be called once by the owner.
     * Emits the AuctionEnded event.
     */
    function endAuction() external onlyOwner auctionEndedOnly {
        require(!auctionEnded, "Auction already finalized.");
        auctionEnded = true;

        emit AuctionEnded(highestBidder, highestBid);
    }

    /**
     * @dev Allows non-winning bidders to withdraw their funds, minus a 2% commission.
     */
    function withdraw() external auctionEndedOnly {
        require(msg.sender != highestBidder, "Winner cannot withdraw.");

        uint amount = pendingReturns[msg.sender];
        require(amount > 0, "No funds to withdraw.");

        uint commission = (amount * COMMISSION_PERCENT) / 100;
        uint refund = amount - commission;

        pendingReturns[msg.sender] = 0;

        payable(msg.sender).transfer(refund);
    }

    /**
     * @dev Returns the address and bid amount of the auction winner.
     * @return Address of the winner and the winning bid amount.
     */
    function getWinner() external view auctionEndedOnly returns (address, uint) {
        return (highestBidder, highestBid);
    }

    /**
     * @dev Returns the list of all bidders and their current deposited amounts.
     * @return Arrays of addresses and their respective deposits.
     */
    function getAllBids() external view returns (address[] memory, uint[] memory) {
        uint[] memory values = new uint[](bidders.length);
        for (uint i = 0; i < bidders.length; i++) {
            values[i] = pendingReturns[bidders[i]];
        }
        return (bidders, values);
    }

    /**
     * @dev Returns whether the auction is currently active.
     * @return True if auction is active, false otherwise.
     */
    function isAuctionActive() external view returns (bool) {
        return block.timestamp < auctionEndTime && !auctionEnded;
    }
}