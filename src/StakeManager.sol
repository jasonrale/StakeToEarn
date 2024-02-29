//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import {IKK} from "./IKK.sol";

/**
 * Stake $ETH to earn $KK
 */
contract StakeManager is Ownable {
    IKK public kk;

    // reward amount per block
    uint256 public rewardRate;

    // reward end Block
    uint256 public endBlockNumber;

    // accumRewardPerETH update Block
    uint256 public updateBlockNumber;

    uint256 public totalStaked;

    uint256 accumRewardPerETH;

    // accumRewardPerETH when user updateReward
    mapping(address account => uint256) public userRewardPerETH;

    // reward amount to be claimed every user
    mapping(address account => uint256) public pendingRewards;

    mapping(address account => uint256) public stakedbBalance;

    constructor(address _owner, address _kk, uint256 _rewardRate, uint256 _endBlockNumber) Ownable(_owner) {
        kk = IKK(_kk);
        rewardRate = _rewardRate;
        endBlockNumber = _endBlockNumber;
    }

    modifier updateReward() {
        accumRewardPerETH = rewardPerToken();
        updateBlockNumber = _lastRewardBlockNumber();

        address msgSender = msg.sender;
        if (msgSender != address(0)) {
            pendingRewards[msgSender] += stakedbBalance[msgSender] * (accumRewardPerETH - userRewardPerETH[msgSender]);
            userRewardPerETH[msgSender] = accumRewardPerETH;
        }
        
        _;
    }

    function stake() external payable updateReward {
        uint256 vaule = msg.value;
        require(vaule > 0, "Stake zero");
        stakedbBalance[msg.sender] += vaule;
        totalStaked += vaule;
    }

    function unStake(uint256 amount) external updateReward {
        address msgSender = msg.sender;
        require(amount > 0, "Unstake zero");
        stakedbBalance[msgSender] -= amount;
        totalStaked -= amount;
        Address.sendValue(payable(msgSender), amount);
    }

    function claimReward() external updateReward {
        address msgSender = msg.sender;
        uint256 rewardAmount = pendingRewards[msgSender];
        if (rewardAmount > 0) {
            pendingRewards[msgSender] = 0;
            kk.mint(msgSender, rewardAmount);
        }
    }

    function setRewardRate(uint256 _rewardRate) external onlyOwner {
        require(block.number > endBlockNumber, "Reward not finished");
        rewardRate = _rewardRate;
    }

    function setEndBlockNumber(uint256 _endBlockNumber) external onlyOwner {
        require(block.number > endBlockNumber, "Reward not finished");
        endBlockNumber = _endBlockNumber;
    }

    function rewardPerToken() internal view returns(uint256) {
        if (totalStaked == 0) {
            return accumRewardPerETH;
        }

        return accumRewardPerETH + rewardRate * (_lastRewardBlockNumber() - updateBlockNumber) / totalStaked;
    }

    function _lastRewardBlockNumber() internal view returns(uint256) {
        return _min(endBlockNumber, block.number);
    }

    function _min(uint256 a, uint256 b) internal pure returns(uint256) {
        return a < b ? a : b;
    }
}
