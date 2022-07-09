pragma solidity ^0.8.11;

contract Auction{

    //Parameters of the auction.
    //Times are in seconds
    uint public endTime;
    uint public auctionLength;
    bool public auctionLive;

    //Keeps track of which bid in the bids mapping is the highest
    uint public bidId = 0;

    bid public currentHighestBid;
    address payable beneficiary;

    // a mapping of all the bids
    mapping(uint => bid) public bids;

    // This will represent a bid
    struct bid {
        uint value; // value of bid
        address user; // the user this bid belongs to
        bool active; // this is false if the bid has been withdrawn
    }

    //Events will be emited on changes
    event HighestBidIncreased(bid);
    event AuctionEnded(bid);

    // Auction has ended
    error AuctionAlreadyEnded();

    // Bid isn't greater than the current highest bid
    error BidNotHighEnough();

    // The auction hasn't ended
    error AuctionNotYetEnded();

    // Auction End has already been called
    error AuctionEndAlreadyCalled();

    // A bid is no longer active
    error BidNoLongerActive();

    // Creates the simple auction with the biddingTime in seconds
    // and the address of the beneficiary
    constructor(uint biddingTime, address payable _beneficiary){
        beneficiary = _beneficiary;
        auctionLength = biddingTime;
        endTime = block.timestamp + biddingTime;
        auctionLive = true;

        // Sets the minimum starting bid 
        // This could also easily be changed if it where a parameter
        currentHighestBid = bid(0.5 ether, _beneficiary, true);
        bids[0] = currentHighestBid;
    }

    // Allows user to bid on auction with the value sent in ether
    // Value must be refunded by the users with the widthraw function 
    // if they do not win the auction. 
    function makeBid() external payable{

        // Checks if the bid is high enough
        if (msg.value < currentHighestBid.value) revert BidNotHighEnough();
        
        // Checks if the auction has already ended
        if (block.timestamp > endTime) revert AuctionAlreadyEnded();

        // updates the highest bid value
        currentHighestBid.value = msg.value;

        //updates the bidId
        bidId++;

        // Bid is created and mapped to the bid ID
        bids[bidId] = bid(msg.value, msg.sender, true);
        emit HighestBidIncreased(bids[bidId]);
    }

    // Allows user to withdraw any bid that they have made
    // This is actually the only way for the user to get their money back
    function withdraw(uint _bidId) external returns(bool){

        // Checks if users bid is active and that it is the user's bid
        if (bids[_bidId].active == true && bids[_bidId].user == msg.sender){
            uint amount = bids[_bidId].value;
            if (amount > 0){

                // Ensures the user doesn't call this function twice
                if (!payable(msg.sender).send(amount))
                    return false;

                // Checks if the bid is the current hgighest bid
                if (bidId == _bidId){

                    // Will find the next highest bid and update it
                    while(!bids[bidId--].active){}
                    currentHighestBid = bids[bidId];
                }
                // Deactivate the user's bid
                bids[_bidId].active = false;
                return true;
            }
        }
        return false;
    }

    // Anyone can end the auction if the auction endTime has been passed
    function auctionEnd() external{

        // Checks if the auction endTime has been passed
        if (block.timestamp < endTime) revert AuctionNotYetEnded();

        // Makes sure this function isn't called twice
        if (!auctionLive) revert AuctionAlreadyEnded();

        auctionLive = false;
        emit AuctionEnded(currentHighestBid);

        // Transfers highest bid to beneficiary
        beneficiary.transfer(currentHighestBid.value);
    }

}   
