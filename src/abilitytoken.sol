// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;
// Import the OpenZeppelin library
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AbilityToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Ability", "ABT") {
        _mint(msg.sender, initialSupply);
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        return super.transfer(recipient, amount);
    }
}
