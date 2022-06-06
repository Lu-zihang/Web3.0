pragma solidity ^0.8.0;


// @dev Saving gas operator
// avoid gas war!
contract GasWar {

   
    // @dev change variable slot to memory slot for saving gas
    // operatorA
    uint reserve0;
    function operatorA() public view returns(uint reserve) {
        reserve = reserve0;
    }



    // operatorB
    // share a slot 
    uint112 tokenA;
    uint112 tokenB;
    // use 32 or 64 slot for timestamp is enough  
    uint32  timestamp; 
    

    // @dev use determine parameter length
    // operatorC
    function operatorC() public pure returns(uint) {
        // afford a parames length 
        uint[] memory path = new uint[](10);
        path[0] = 4;
        return path[0];
    }


    // @dev use `!=` verifly
    // operatorD
    function operatorD(uint value) public {
        // bad 
        // require(value > 0, "faild")

        //good
        require(value != 0 , "faild");
    }



    // @dev use displacement, dont'use (add, subtract , multiply and divide)
    // operatorE
    function operatorE(uint value) public {
        // bad 
        // uint256 resultA = value / 2
        // uint256 resultB = value * 8

        // good
        uint256 resultA = value >> 1;
        uint256 resultB = value >> 3;
    }


    // @dev afford use type `string`, suggest use type `bytes`
    // operatorF
    function operatorF(bytes memory value) public {
        bytes memory data = value;
    }


    // @dev Generally use the default 2^256 -1  
    // or use hexadecimal 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff 
    // if possible please use 0x8000000000000000000000000000000000000000000000000000000000000000
    // or 2^255
    // this can reduce about 1984gas, 4.1%.
    // operatorG
    function operatorG(uint value) public {
        // good A
        if (value > 0x8000000000000000000000000000000000000000000000000000000000000000) {
            revert();
        }
    }

}
