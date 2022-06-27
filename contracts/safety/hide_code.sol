pragma solidity ^0.8.10;


contract Simples {

    Fund immutable fund;

    constructor(address payable _fund) {
        fund = Fund(_fund);
    }


    function deposit() public payable {
        address(fund).call{value: msg.value};
    }

    function withdraw(uint amount) public  {
        fund.withdraw(amount);
    }

    function getBalance() public view returns(uint) {
        return fund.getBalance();
    }

    function getBalances() public view returns(uint) {
        return address(this).balance;
    }

}


contract Fund {

    event LogReceive(address indexed from);

    receive() external payable{
        emit LogReceive(msg.sender);
    }

    fallback() external payable {   
    }

    function withdraw(uint amount) public {
        require(amount > 0);
        // Safe Transfer
        (bool success, bytes memory data) = payable(tx.origin).call{value: amount}("");
        require(success && abi.decode(data, (bool)), "FAKE: WithDraw request is Fail !");
    }


    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

}


contract FAKE {
    event LogReceive(address indexed from);

    receive() external payable{
        emit LogReceive(msg.sender);
    }

    fallback() external payable {
    }

    function withdraw(uint amount) public {
        require(amount > 0);
        // Safe Transfer
        (bool success, bytes memory data) = payable(tx.origin).call{value: amount}("");
        require(success && abi.decode(data, (bool)), "FAKE: WithDraw request is Fail !");
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
}
