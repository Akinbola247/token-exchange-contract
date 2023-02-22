// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SwapToken is ERC20 {
    address ownerAddress;
    constructor(string memory name, string memory symbol, address owner, uint256 amount) ERC20(name, symbol){
        ownerAddress = owner;
        _mint(address(this), amount * (100**decimals()));
    }

    function TransferSwapToken(uint _amount) public payable { 
         _transfer(address(this), msg.sender, _amount);
    }
fallback() external payable{}
receive()external payable{}

}