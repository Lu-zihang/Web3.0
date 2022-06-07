pragma solidity ^0.8.0;



library Address {

    // @dev verifly the address code size
    // return true 
    function isContract(address addr) public returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return true ? size !=0: false;
    }

    // @dev verifly the address code size
    // if addr is contract addr, revert().
    function isContractRevert(address addr) public {
        assembly {
            let size := extcodesize(addr)
            if iszero(size) {
                revert(0,0)
            }
        }
    } 
}
