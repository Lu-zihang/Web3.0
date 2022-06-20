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
    
        // About `SSTORE` opcode operator
    // The value is by described as reentry status 
    // compare [1, 2] gas cost. swap [0, 1] with gas is more higher 
    // see {Openzepplin} ReentrancyGuard realized


    // bad
    // uint256 private constant _NOT_ENTERED = 1;
    // uint256 private constant _ENTERED = 0;

    // good
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    


    // Avoid use the `memory` word as input params
    // In order to use less gas, use `calldata`. it can avoid memory extend
    
    // bad
    // function operatorH(bytes calldata _data) public {}

    // good
    function operatorH(bytes memory _data) public {

    }


    // Avoid use the `public` word 
    // if an interface need to be access. it can be implemented with `external` and `internal`
    
    // bad
    // function operatorI() public{}

    // good
    function operatorI() external {}
    function _operatorI() internal {}


    // Use ++i operaotr. isn't i++ operator
    // Beautiful saving and return old value operator can be reduce 
    function operatorJ() public {
        uint i = 0;
        // band
        i++;

        // good
        ++i;
    }


}
