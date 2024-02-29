// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

 /**
  * @title KK interface
  */
interface IKK is IERC20 {
    function mint(address _account, uint256 _amount) external;
}