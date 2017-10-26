/**
*
* Inspired by FirstBlood Token - firstblood.io
*
*/

pragma solidity ^0.4.13;

/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/
library SafeMath {
	function mul(uint256 a, uint256 b) internal returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
  	}

  	function div(uint256 a, uint256 b) internal returns (uint256) {
		assert(b > 0); // Solidity automatically throws when dividing by 0
		uint256 c = a / b;
		assert(a == b * c + a % b); // There is no case in which this doesn't hold
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
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/
contract Ownable {
	address public owner;


	/**
	* @dev The Ownable constructor sets the original `owner` of the contract to the sender
	* account.
	*/
	function Ownable() {
		owner = msg.sender;
	}


	/**
	* @dev Throws if called by any account other than the owner.
	*/
	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}


	/**
	* @dev Allows the current owner to transfer control of the contract to a newOwner.
	* @param newOwner The address to transfer ownership to.
	*/
	function transferOwnership(address newOwner) onlyOwner {
		if (newOwner != address(0)) {
			owner = newOwner;
		}
	}

}

/**
* @title Pausable
* @dev Base contract which allows children to implement an emergency stop mechanism.
*/
contract Pausable is Ownable {
	event Pause();
	event Unpause();

	bool public paused = true;

	/**
	* @dev modifier to allow actions only when the contract IS NOT paused
	*/
	modifier whenNotPaused() {
		require(!paused);
		_;
	}

	/**
	* @dev modifier to allow actions only when the contract IS paused
	*/
	modifier whenPaused {
		require(paused);
		_;
	}

	/**
	* @dev called by the owner to pause, triggers stopped state
	*/
	function pause() onlyOwner whenNotPaused returns (bool) {
		paused = true;
		Pause();
		return true;
	}

	/**
	* @dev called by the owner to unpause, returns to normal state
	*/
	function unpause() onlyOwner whenPaused returns (bool) {
		paused = false;
		Unpause();
		return true;
	}
}

/**
* @title ERC20Basic
* @dev Simpler version of ERC20 interface
* @dev see https://github.com/ethereum/EIPs/issues/20
*/
contract ERC20Basic {
	uint256 public totalSupply;
	function balanceOf(address who) constant returns (uint256);
	function transfer(address to, uint256 value);
	event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
* @title ERC20 interface
* @dev see https://github.com/ethereum/EIPs/issues/20
*/
contract ERC20 is ERC20Basic {
	function allowance(address owner, address spender) constant returns (uint256);
	function transferFrom(address from, address to, uint256 value);
	function approve(address spender, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
* @title Basic token
* @dev Basic version of StandardToken, with no allowances.
*/
contract BasicToken is ERC20Basic {
	using SafeMath for uint256;

	mapping(address => uint256) balances;

	/**
	* @dev transfer token for a specified address
	* @param _to The address to transfer to.
	* @param _value The amount to be transferred.
	*/
	function transfer(address _to, uint256 _value) returns (bool success) {
		if (balances[msg.sender] >= _value && _value > 0) {
			balances[msg.sender] = balances[msg.sender].sub(_value);
			balances[_to] = balances[_to].add(_value);
			Transfer(msg.sender, _to, _value);
			return true;
		} else { return false; }
	}

	/**
	* @dev Gets the balance of the specified address.
	* @param _owner The address to query the the balance of.
	* @return An uint256 representing the amount owned by the passed address.
	*/
	function balanceOf(address _owner) constant returns (uint256 balance) {
		return balances[_owner];
	}

}

/**
* @title Standard ERC20 token
*
* @dev Implementation of the basic standard token.
* @dev https://github.com/ethereum/EIPs/issues/20
* @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
*/
contract StandardToken is ERC20, BasicToken {

	mapping (address => mapping (address => uint256)) allowed;


	/**
	* @dev Transfer tokens from one address to another
	* @param _from address The address which you want to send tokens from
	* @param _to address The address which you want to transfer to
	* @param _value uint256 the amout of tokens to be transfered
	*/
	function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
		var _allowance = allowed[_from][msg.sender];

		if (balances[_from] >= _value && _allowance >= _value && balances[_to] + _value > balances[_to]) {
			balances[_to] = balances[_to].add(_value);
			balances[_from] = balances[_from].sub(_value);
			allowed[_from][msg.sender] = _allowance.sub(_value);
			Transfer(_from, _to, _value);
			return true;
		} else { return false; }
	}

	/**
	* @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
	* @param _spender The address which will spend the funds.
	* @param _value The amount of tokens to be spent.
	*/
  	function approve(address _spender, uint256 _value) returns (bool success) {
  	
		/**
		* To change the approve amount you first have to reduce the address'
		* allowance to zero by calling `approve(_spender, 0)` if it is not
		* already 0 to mitigate the race condition described here:
		* https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
		*/ 
		require((_value == 0) && (allowed[msg.sender][_spender] == 0));

		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
  	}

	/**
	* @dev Function to check the amount of tokens that an owner allowed to a spender.
	* @param _owner address The address which owns the funds.
	* @param _spender address The address which will spend the funds.
	* @return A uint256 specifing the amount of tokens still avaible for the spender.
	*/
	function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}

}

/**
* @title Team HODL crowdsale ICO contract.
*
* Security criteria evaluated against http://ethereum.stackexchange.com/questions/8551/methodological-security-review-of-a-smart-contract
*/
contract hodlToken is Pausable, StandardToken {

	using SafeMath for uint256;

	/**
	* Initial founder address (set in constructor)
	* All deposited ETH will be instantly forwarded to this address.
	* Address is a multisig wallet.
	*/
	// CHANGE TODO
	address public treasurer = 0xfCEf4fD67d4a0fFF4D4D41B86C17D0D91e489Fdb;

	string public name = "HODL Token";
	string public symbol = "HOLD";
	uint256 public decimals = 18;
	// TODO TO SET START AND END BLOCKS FOR ICO
	uint public startBlock; //crowdsale start block (set in constructor)
	uint public endBlock; //crowdsale end block (set in constructor)

  	uint256 public INITIAL_SUPPLY = 1000000;

	// TODO TO SAVE 20% TOKENS FOR TEAM
	uint256 public purchasableTokens = INITIAL_SUPPLY.sub(INITIAL_SUPPLY.div(5));

	uint256 public RATE = 200;

	uint public etherCap = 140000; //max amount raised during crowdsale (assuming $300 per eth, this is $210,000 USD)
    uint public transferLockup = 86400; //transfers are locked for this many blocks after endBlock (assuming 30 second blocks, this is 1 month)
    uint public founderLockup = 20160; //founder allocation cannot be created until this many blocks after endBlock (assuming 30 second blocks, this is 1 week)
    uint public ecosystemAllocation = 5 * 1400; //5% of token supply allocated post-crowdsale for the ecosystem fund
    uint public founderAllocation = 20 * 1400; //10% of token supply allocated post-crowdsale for the founder allocation
    bool public ecosystemAllocated = false; //this will change to true when the ecosystem fund is allocated
    bool public founderAllocated = false; //this will change to true when the founder fund is allocated
    uint public presaleTokenSupply = 0; //this will keep track of the token supply created during the crowdsale
    uint public presaleEtherRaised = 0; //this will keep track of the Ether raised during the crowdsale
    

  /**
	* @dev Contructor that gives msg.sender all of existing tokens.
	*/
  function hodlToken() {
	 totalSupply = INITIAL_SUPPLY;
	 balances[msg.sender] = INITIAL_SUPPLY;
  }

  /**
	* @dev Allows the current owner to transfer control of the contract to a newOwner.
	* @param newOwner The address to transfer ownership to.
	*/
  function transferOwnership(address newOwner) onlyOwner {
	 address oldOwner = owner;
	 super.transferOwnership(newOwner);
	 balances[newOwner] = balances[oldOwner];
	 balances[oldOwner] = 0;
  }

  /**
	* @dev Allows the current owner to transfer treasurership of the contract to a newTreasurer.
	* @param newTreasurer The address to transfer treasurership to.
	*/
  function transferTreasurership(address newTreasurer) onlyOwner {
	 if (newTreasurer != address(0)) {
		treasurer = newTreasurer;
	 }
  }

  /**
	* @dev Allows owner to release tokens for purchase
	* @param amount The number of tokens to release
	*/
  function setPurchasable(uint256 amount) onlyOwner {
	 require(amount > 0);
	 require(balances[owner] >= amount);
	 purchasableTokens = amount.mul(10**18);
  }
  
  /**
	* @dev Allows owner to change the rate Tokens per 1 Ether
	* @param rate The number of tokens to release
	*/
  function setRate(uint256 rate) onlyOwner {
		RATE = rate;
  }

  /**
	* @dev fallback function
	* No direct deposits
	*/
  function () payable {
	 throw;
	 // buyTokens(msg.sender);
  }

  /**
	* @dev function that sells available tokens
	*/
  function buyTokens(address addr) payable whenNotPaused {
	 require(treasurer != 0x0); // Must have a treasurer

	 // Calculate tokens to sell and check that they are purchasable
	 uint256 weiAmount = msg.value;
	 uint256 tokens = weiAmount.mul(RATE);
	 require(purchasableTokens >= tokens);

	 // Send tokens to buyer
	 purchasableTokens = purchasableTokens.sub(tokens);
	 balances[owner] = balances[owner].sub(tokens);
	 balances[addr] = balances[addr].add(tokens);

	 Transfer(owner, addr, tokens);

	 // Send money to the treasurer
	 treasurer.transfer(msg.value);
  }
}