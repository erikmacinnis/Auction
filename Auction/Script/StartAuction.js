// allows us to access the TokenFarm smart contract
const Auction = artifacts.require('Auction')

// this script allows us to issue tokens by running "truffle exec scripts/issue-tokens.js" on the command line
//exec just means execute
module.exports = async function(callback) {//async is necessary because we wanna do some step by step procesdures in this funciton

	let auction = await Auction.deployed()
	await auction.issueTokens()
  
	// Message will display to console when this is run
	console.log("Auction is Live")
	callback() // this will be a function that we will pass through the function
}
