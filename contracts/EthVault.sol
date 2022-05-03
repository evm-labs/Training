pragma solidity 0.8.13;

/*
import

*/

contract EthereumVault {

    uint256 intenal constant RECIPIENTAMOUNT = 1 ether;
    address public payable immutable Owner;
    mapping (address payable => uint256) addressBalance;
    address payable[] addresses;
    bool internal locked = false;

    constructor() public {
        Owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == Owner, "Only the owner can execute this operation.");
        _;
    }

    modifier onlyValidAddresses(address _address){
        require(addressBalance[_address] > 0, "This address does not have the right permissions to enter.");
    }

    function addRecipient(address payable _address) external onlyOwner{
        require(msg.value >= RECIPIENTAMOUNT, "To add a recipient you need to add the required amount.")
        addressBalance[_address] = RECIPIENTAMOUNT;
    }

    function withdrawMoney(uint256 amountInWei) external onlyValidAddresses(msg.sender){
        require(amountInWei <= addressBalance[msg.sender], "This address does not have the requested amount.");
        require(!locked, "This method is currently locked.")
        locked = true;
        (bool success, ) = payable(msg.sender).call{value:amountInWei}(""); 
        require(success, "Transaction failed.");
        locked = false;
    }


}

/*
Only owner can deposit
Certain address can withdraw up to a portion of the running balance
*/

