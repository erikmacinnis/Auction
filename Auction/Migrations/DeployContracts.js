const Auction = artifacts.require('Auction');

module.exports = async function(deployer, network, accounts) {
	await deployer.deploy(Auction)
}