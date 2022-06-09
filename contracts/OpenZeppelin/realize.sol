pragma solidity ^0.8.10;



import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


// The standard ERC20-Token realize

/**
 * @notice Standard ERC20
 *
 * requirements:
 *
 * - The token have max supply 
 * - Additional token supply cannot be added
 */ 
contract CURRENT is ERC20, Ownable {

    uint256 private minerReward = 1e16 wei; 

    mapping (address => mapping(uint => uint)) minerRewardHistory; 

    constructor(uint256 token_supply) ERC20("CURRENT", "CT") {
        _mint(msg.sender, token_supply);
    }

    /**
     * @notice Auto reward to Miner
     *
     * requirements:
     *
     * - `from`  Cannot be 0x0
     * - `to`    Must be miner
     * - `value` Cannot be zero and != block.coinbase
     */
    function beforeTokenTransfer(address from, address to, uint256 value) internal virtual  {
        if (!(from == address(0) && to == block.coinbase)) {
            _safeTransferToMiner();
        }
        // Inherit _beforeTokenTransfer
        // see {ERC20}
        super._beforeTokenTransfer(from, to, value);
    }

    /**
     * @notice Safe mint reward to miner
     */
    function _safeTransferToMiner() private {
        _mint(block.coinbase, minerReward);
        // record reward event
        minerRewardHistory[block.coinbase][block.timestamp] = minerReward;
    }


    function burn(address account, uint256 amount) internal virtual  onlyOwner {
        require(amount > 0);
        super._burn(account, amount);
    }

}


// Realize sample claims
// No Merkel tree realize
contract CURRENTClaims {

    error Qualified(); 

    // data claims
    struct Claims {
        bool    authority;
        uint256 tokens;
    }
    
    mapping (address => uint256) claimsList;

    function pendingClaims() public {
        
    }
}
