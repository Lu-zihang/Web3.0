pragma solidity ^0.8.0;


library Address {

    // @dev use yul opcode `extcodesize` verifly size 
    // if size > 0  the address is contractAddr
    // else user address
    function isContract(address _addr) public returns (bool) {
        uint code; 
        assembly {
            code := extcodesize(_addr)
        }
        require(code == 0, "The address is Contract!");
    }
}
