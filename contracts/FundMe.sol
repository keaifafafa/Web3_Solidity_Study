// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    // 1、实现一个项目众筹的功能
    // 2、创建一个收款函数
    // 3、在锁定期内，达到目标值，生产商可以提款
    // 4、在锁定期内，没有达到目标值，投资人可以退款

    mapping(address => uint256) public funderToAmount;

    AggregatorV3Interface internal dataFeed;

    uint256 MINNUM_VALUE = 100 * 10 ** 18; //USD

    uint256 constant TARGET = 1000 * 10 ** 18; //目标值，使用constant修饰代表不可改变

    address public owner; //生产商


    uint256 deploymentTimestamp; // 部署时间

    uint256 lockTime; // 锁时间

    address erc20Addr; // ERC20地址

    bool public getFundSuccess = false;

    constructor(uint256 _lockTime) {
        // 地址初始化，使用的是Sepolia
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        owner = msg.sender; // 部署者
        deploymentTimestamp = block.timestamp;
        lockTime = _lockTime;

    }

    /**
    * 捐款
    */
    function fund() external payable {
        require(convertEthToUsd(msg.value) >= MINNUM_VALUE, "Please send more ETH");
        // 活动关闭了
        require(block.timestamp < deploymentTimestamp + lockTime, "window is closed");
        // 记录不同sender 发送的 value
        funderToAmount[msg.sender] = msg.value;
    }

    /**
     * Returns the latest answer.
     */ 
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    /**
    * Eth 转 Usd
    */
    function convertEthToUsd(uint256 ehtAmount) internal view returns(uint256) {
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        // 因为 Chainlink预言机返回的 ethPrice 是带有 8 位小数的，所以我们需要 / (10 ** 8)
        return ehtAmount * ethPrice / (10 ** 8);
    }

    /**
    * 金额达到，生产商可以提款
    **/
    function getFund() external windowClosed onlyOwner {
        // 金额必须>=target
        require(convertEthToUsd(address(this).balance) >= TARGET, "Target is not reached");
        // 有三种转账方式
        // 1、transfer
        // payable(msg.sender).transfer(address(this).balance);
        // 2、send
        // bool success = payable(msg.sender).send(banlance);
        // require(success, "tx faild");
        // 3、call，也是官方推荐方式
        bool success;
        (success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "trasfer tx failed");
        funderToAmount[msg.sender] = 0; // 数据清零
        getFundSuccess = true; // 提取完成
    }

    /**
    * 金额没达到，可以退款给投资人
    */
    function refund() external windowClosed {
        uint256 balance = address(this).balance;
        uint256 selfFund    = funderToAmount[msg.sender]; // 个人金额
        require(convertEthToUsd(balance) < TARGET, "Target is reached");
        require(selfFund > 0, "you fund is not enough");
        bool success;
        (success, ) = payable(msg.sender).call{value: selfFund}("");
        require(success, "transfer tx failed");
        funderToAmount[msg.sender] = 0;
    }

    /**
    * 设置新的owner
    */
    function transferOwnership(address newOwner) public onlyOwner{
        owner = newOwner;
    }

    /**
    * 更新
    */
    function setFunderToAmount(address funder, uint256 ammountToUpdate) external {
        // 必须是由ERC20合约去修改的
        require(msg.sender == erc20Addr, "you do not have permission to call this function");
        funderToAmount[funder] = ammountToUpdate;
    }

    /**
    * 设置ERC20的地址
    */
    function setErc20Addr(address _erc20Addr) public onlyOwner {
        erc20Addr = _erc20Addr;
    }

    /**
    * 锁定期内
    */
    modifier windowClosed() {
        require(block.timestamp >= deploymentTimestamp + lockTime, "window is not closed");
        _;
    }

    /**
    * 修饰器
    */
    modifier onlyOwner() {
        require(msg.sender == owner, "this function can only be called by owner");
        // 代表执行修饰函数的内容
        _;
    }

}