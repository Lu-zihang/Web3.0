pragma solidity ^0.8.10;



import "@openzeppelin/contracts/ownership/Ownable.sol";

contract OwnableContract is Ownable {

    /**
     * @notice Test openzeppelin library 
     * see {Ownable}
     * requirement:
     * - `msg.sender` The address must be owner or admin.
     */
    function restricted() public onlyOwner returns(bool) {
        return true;
    }

}
