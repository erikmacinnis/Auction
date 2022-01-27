pragma solidity ^0.8.11;

contract Auction{

    uint public endTime;
    uint public auctionLength;
    bool public auctionLive;
    uint public bidId = 0;
    bid public currentHighestBid;
    address payable beneficiary;

    mapping(uint => bid) public bids;

    struct bid {
        uint value;
        address user; 
        bool active;
        uint bidId;
    }

    event HighestBidIncreased(bid);
    event AuctionEnded(bid);

    error AuctionAlreadyEnded();

    error BidNotHighEnough();

    error AuctionNotYetEnded();

    error AuctionEndAlreadyCalled();

    error BidNoLongerActive();

    constructor(uint biddingTime, address payable _beneficiary){
        beneficiary = _beneficiary;
        auctionLength = biddingTime;
        endTime = block.timestamp + biddingTime;
        auctionLive = true;
        currentHighestBid = bid(0.5 ether, _beneficiary, true, bidId);
        bids[0] = currentHighestBid;
    }

    function makeBid() external payable{
        if (msg.value < currentHighestBid.value) revert BidNotHighEnough();

        if (block.timestamp > endTime) revert AuctionAlreadyEnded();

        currentHighestBid.value = msg.value;
        bidId++;
        bids[bidId] = bid(msg.value, msg.sender, true, bidId);
        emit HighestBidIncreased(bids[bidId]);
    }

    function withdraw(uint _bidId) external returns(bool){
        if (bids[_bidId].active == true && bids[_bidId].user == msg.sender){
            uint amount = bids[_bidId].value;
            if (amount > 0){
                
                if (!payable(msg.sender).send(amount)){
                    return false;
                }
                bids[_bidId].active = false;
                if (bidId == _bidId){
                    bidId--;
                    currentHighestBid = bids[bidId];
                }
                return true;
            }
        }
        return false;
    }

    function auctionEnd() external{

        if (block.timestamp < endTime) revert AuctionNotYetEnded();

        if (!auctionLive) revert AuctionAlreadyEnded();

        auctionLive = false;
        emit AuctionEnded(currentHighestBid);

        beneficiary.transfer(currentHighestBid.value);
    }

}   