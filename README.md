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

📡 Events
Event	Parameters	Description
NewBid	address bidder, uint amount	Emitted whenever a valid new bid is placed.
AuctionEnded	address winner, uint amount
