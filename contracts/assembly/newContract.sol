pragma solidity ^0.8.0;


contract Factory {

    // @dev use yul opcode `create2` to deploy contract
    // opcode (create、create2) == new
    function deploy() public returns(address deployer) {
        // get contract operator code
        bytes memory bytecode = type(Sample).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(msg.sender));
        // create2(wei, n, position, size)
        // - `wei`      create fee
        // - `n`        bytecode
        // - `position` mem[pos, pos+32]
        // ` `salt`     random salt
        assembly {
            deployer := create2(
                0,
                add(bytecode, 32),
                mload(bytecode),
                salt
            )
        }
    }
}


contract Sample {
    function getIValue() public view returns(bool){
        return true;
    }
}
