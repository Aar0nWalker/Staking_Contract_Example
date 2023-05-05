// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Staking is Ownable, ReentrancyGuard {

    IERC20 rewardToken;
    IERC20 stakingToken;

    struct StakeInfo {
        uint256 start;
        uint256 end;
        uint256 staked;
    }

    uint256 stakingTime = 1 weeks;
    uint256 rewardingRate = 0.00001 ether;

    mapping(address => StakeInfo) public stakes;

    event Staked(address indexed holder, uint256 amount);
    event Unstaked(address indexed holder, uint256 amount);

    constructor(address _rewardToken, address _stakingToken) {
        rewardToken = IERC20(_rewardToken);
        stakingToken = IERC20(_stakingToken);
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Incorrect stake amount");
        require(stakingToken.balanceOf(msg.sender) > 0, "Incorrect balance");
        stakingToken.transferFrom(msg.sender, address(this), amount);
        stakes[msg.sender].start = block.timestamp;
        stakes[msg.sender].end = block.timestamp + stakingTime;
        stakes[msg.sender].staked = amount;
        emit Staked(msg.sender, amount);
    }

    function unstake() external  {
        require(stakes[msg.sender].staked > 0, "0 tokens staked");
        require(block.timestamp >= stakes[msg.sender].end, "Staking time have not expired yet");
        stakingToken.transferFrom(msg.sender, address(this), stakes[msg.sender].staked + checkReward());
        stakes[msg.sender].staked = 0;
        emit Unstaked(msg.sender, stakes[msg.sender].staked);
    }

    function checkReward() public view returns(uint256) {
        return (block.timestamp - stakes[msg.sender].start) * rewardingRate * stakes[msg.sender].staked/1 ether;
    }

}