// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IRebaseToken} from "./interfaces/IRebaseToken.sol";

contract Vault {
    error Vault__RedeemFailed();
    // We need to pass the token address to the constructor
    // create deposit function that mint token to the user equal to the amount of ETH sent by the user
    // create redeem function that burn token from the user and sends the user ETH
    // create a way to add rewards to the vault
    IRebaseToken private immutable i_rebaseToken;

    event Deposit(address indexed user, uint256 amount);
    event Redeem(address indexed user, uint256 amount);

    constructor(IRebaseToken _rebaseToken) {
        i_rebaseToken = _rebaseToken;
    }

    receive() external payable {}

    /**
     * @notice allows users to deposit ETH into the vault and mint rebase tokens in return
     */
    function deposit() external payable {
        // we need to use amount of ETH user has sent to mint tokens to the user
        uint256 interestRate = i_rebaseToken.getInterestRate();
        i_rebaseToken.mint(msg.sender, msg.value, interestRate);
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @notice allows users to redeem their rebase tokens for ETH
     * @param _amount The amount of rebase tokens the user wants to redeem for ETH
     */
    function redeem(uint256 _amount) external {
        if (_amount == type(uint256).max) {
            _amount = i_rebaseToken.balanceOf(msg.sender);
        }
        // we need to burn the tokens from the user and send the user ETH equal to the amount of tokens burned
        i_rebaseToken.burn(msg.sender, _amount);
        (bool success,) = payable(msg.sender).call{value: _amount}("");
        if (!success) {
            revert Vault__RedeemFailed();
        }
        emit Redeem(msg.sender, _amount);
    }

    /**
     * @notice allows users to get the address of the rebase token contract
     * @return The address of the rebase token contract
     */
    function getRebaseToken() external view returns (address) {
        return address(i_rebaseToken);
    }
}
