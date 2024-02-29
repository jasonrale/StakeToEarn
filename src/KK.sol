// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IKK.sol";

contract KK is ERC20, IKK {
    address public stakeManager;

    modifier onlyStakeManager() {
        require(
            msg.sender == stakeManager,
            "Access only by StakeManager"
        );
        _;
    }

    constructor(address _stakeManager) ERC20("KK token", "KK") {
        stakeManager = _stakeManager;
    }

    function mint(address _account, uint256 _amount) external override onlyStakeManager{
        _mint(_account, _amount);
    }
}