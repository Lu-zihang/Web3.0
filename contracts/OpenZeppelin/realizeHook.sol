pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


// realize hook function
// _beforeTokenTransfer and _afterTokenTransfer
contract DOGETOKEN is ERC20, Ownable {

    uint fee = 100;

    constructor(uint _totalSupply) ERC20("dogetoken", "DT"){
        _mint(msg.sender, _totalSupply);
    }


    function transferDogeToken(address to, uint256 amount) external {
        // Adjected hook function. Implement highly customized operations
        _beforeTokenTransfer(msg.sender, to, amount);
        (bool success) = transfer(to, amount);
        require(success);
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20){
        address owner = owner();
        uint _fee = fee;
        if (feeOn(from)) {
            transfer(owner, _fee);
        }
    }


    function getTotalSupply() external view returns(uint) {
        return totalSupply();
    }

    function feeOn(address feefrom) internal view returns(bool) {
        require(feefrom != address(0));
        // gas saving
        uint _fee = fee; 
        if (balanceOf(feefrom) > 100) {
            return true;
        } else {
            return false;
        }
    }

}
