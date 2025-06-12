# auction-smart-contract

Auction Smart Contract
A secure and feature-rich Ethereum smart contract for conducting timed auctions with rules for bid validity, automatic extensions, commission-based refunds, and partial withdrawals during the auction.

📌 Features
✅ Timed auction with adjustable duration.

📈 Valid bids must exceed the highest by at least 5%.

⏱ Auction auto-extends by 10 minutes if a valid bid is placed in the last 10 minutes.

💸 Bids are stored as deposits on-chain and associated with user addresses.

🧾 Refunds for non-winning bidders (with a 2% commission).

🧩 Partial withdrawals during the auction for previously deposited excess funds.

🧠 Safe, transparent, and well-commented Solidity code.

📡 Emits events for external tracking.

🏗️ Contract Summary
Element	Description
placeBid()	Place a bid by sending ETH. Must exceed the highest by 5%.
withdrawExcessDuringAuction()	Withdraw any excess funds above your last valid bid during the auction.
endAuction()	Ends the auction (callable only by the owner).
withdraw()	Non-winners withdraw their funds minus 2% commission.
getWinner()	Returns the current winner and the winning amount.
getAllBids()	Returns all bidders and their total deposits.
isAuctionActive()	Returns a boolean indicating if the auction is still active.

⚙️ Installation and Testing in Remix
Go to Remix IDE.

Create a new file: Auction.sol.

Paste the entire contract code into it.

Compile with Solidity version ^0.8.20.

Navigate to Deploy & Run Transactions:

Select JavaScript VM as environment.

Enter the duration in seconds (e.g. 300 for 5 minutes).

Click Deploy.

🧪 Example Test Scenario
Step	Account	Action	Value (ETH)	Expected Result
1	Account #1	placeBid()	1	Bid accepted, becomes highest bidder.
2	Account #2	placeBid()	1.1	Valid (≥5% higher), becomes new highest bidder.
3	Account #1	placeBid()	1.5	Outbids again. Deposit now 2.5 ETH total.
4	Account #1	withdrawExcessDuringAuction()	—	Withdraws 1 ETH (excess from first bid).
5	Owner	endAuction() (after time expired)	—	Finalizes the auction.
6	Account #2	withdraw() (non-winner)	—	Gets refund minus 2% commission.

📡 Events
Event	Parameters	Description
NewBid	address bidder, uint amount	Emitted whenever a valid new bid is placed.
AuctionEnded	address winner, uint amount
