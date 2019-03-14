pragma solidity ^0.5.0;

/**
 * Interfaces for calling external contracts
 */
interface ERC20 {
    function balanceOf(address _owner) external returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
}

/**
 * Uniswap factory is necessary to get an exchange contract address for any given token
 */
interface UniswapFactory {
    function getExchange(address token) external view returns (address exchange);
}

interface UniswapExchange {
    function ethToTokenSwapInput(uint256 minTokens, uint256 maxTime) external payable;
}

contract tokenPay {
    address owner;
    ERC20 private daiContract;
    UniswapFactory private uniswapFactory;
    UniswapExchange private daiExchange;

    constructor(address _daiAddress, UniswapFactory _uniswapFactory) public {
        uniswapFactory = _uniswapFactory;

        daiContract = ERC20(_daiAddress);
        daiExchange = UniswapExchange(uniswapFactory.getExchange(_daiAddress));
    }

    // Anyone can send funds; immediately convert them to DAI in order to protect value
    function() external payable {
        ethToDai(msg.value);
    }

    // Convert ETH into DAI using Uniswap
    function ethToDai(uint256 _amount) private {
        daiExchange.ethToTokenSwapInput.value(_amount)(1, 255);
    }

    function withdrawl(address withdrawlAddress, uint256 amount) public _onlyOwner {
        require(daiContract.balanceOf(address(this)) >= amount, "Insufficient Funds");
        bool success = daiContract.transfer(withdrawlAddress, amount);
        require(success, "DAI Transfer Failed");
    }

    // Helper to control access to privileged methods
    modifier _onlyOwner() {
        require(msg.sender == owner, "You must be the contract owner");
        _;
    }
}
