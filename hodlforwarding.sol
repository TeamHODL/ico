pragma solidity ^0.4.16;

/**
* Safe math library for division
**/
library SafeMath {
	function mul(uint256 a, uint256 b) internal returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
  	}

  	function div(uint256 a, uint256 b) internal returns (uint256) {
		uint256 c = a / b;
		return c;
  	}

	function sub(uint256 a, uint256 b) internal returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal returns (uint256) {
		 uint256 c = a + b;
		 assert(c >= a);
		 return c;
	}
}
/**
* Contract that will split any incoming Ether to its creator
**/
contract Forwarder  {
	using SafeMath for uint256;
	// Addresses to which any funds sent to this contract will be forwarded
	address public destinationAddress80;
	address public destinationAddress20;

	/**
	* Create the contract, and set the destination addresses
	**/
	function Forwarder() {
		// This is the escrow/ICO address
		destinationAddress20 = 0x9552848C8647E7eFB9c51df8fCf2DFafE900bA64;
		// All other funds to be used per whitepaper guidelines
		destinationAddress80 = 0xAE61027E8383A34061365C3E792aBbcB17E0176E;
	}

	/**
	* Default function; Gets called when Ether is deposited, and forwards it to destination addresses
	**/
	function () payable {
		if (msg.value > 0) {
			uint256 totalAmount = msg.value;
			uint256 founderAmount = totalAmount.div(5);
			uint256 restAmount = totalAmount.sub(founderAmount);
			if (!destinationAddress20.send(founderAmount)) revert();
			if (!destinationAddress80.send(restAmount)) revert();
		}
	}
}