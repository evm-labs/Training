// SPDX-License-Identifier: <license-identifier-here>
// ex. SPDX-License-Identifier: MIT
// ex. SPDX-License-Identifier: GPL-3.0-or-later
// ex. SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract FreeToken {

    using SafeMath for uint256;

    mapping (address => uint256) balances;

    uint256 public totalSupply = 0;

    function balanceOf (address _wallet) external view returns (uint256) {
        return balances[_wallet];
    }

    function mint () external {
        balances[msg.sender] += 1;
        totalSupply += 1;
    }

    function gift (address payable _address, uint256 _amount) public payable {
        require(_address != msg.sender, "Can't gift yourself.");
        require(_amount, "Amount has to be larger than zero.");
        require(_amount <= msg.value, "Value sent is less than the amount requested to gift.");
        require(!locked, "method is currently locked.");
        locked = true;
        (bool success, ) = _address.call{value: _amount}("");
        require(success, "Transaction failed");
        mint();
        locked = false;
    } 

    function transfer (address _to, uint256 _amount) external {

        require(_amount > 0, "Amount must be nonzero");
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender].sub(_amount);
        balances[_to].add(_amount);
    }
}