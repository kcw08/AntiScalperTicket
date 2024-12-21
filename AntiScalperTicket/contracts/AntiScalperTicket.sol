// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AntiScalperTicket {
    uint256 public ticketPrice; // 票價
    uint256 public maxTickets; // 最大票數
    uint256 public ticketsSold; // 已售票數
    uint256 public startSaleTime; // 售票開始時間
    uint256 public endSaleTime; // 售票結束時間
    uint256 public startUseTime; // 使用票券的開始時間
    uint256 public endUseTime; // 使用票券的結束時間

    mapping(address => bool) public hasPurchased; // 用戶是否已購買票券
    mapping(address => uint256) public ticketOwner; // 用戶擁有的票券 ID
    mapping(uint256 => bool) public isTicketUsed; // 票券是否已被使用
    uint256 private nextTicketId;

    address public owner; // 合約管理者地址
    address constant DEFAULT_OWNER = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;


    // 建構函數：初始化票券 ID
    constructor() {
        nextTicketId = 1; // 初始票券 ID 為 1
        owner = msg.sender; // 設定合約部署者為管理者
    }

    // 僅限管理者執行
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // 僅在售票期間可執行
    modifier onlyDuringSale() {
        require(block.timestamp >= startSaleTime && block.timestamp <= endSaleTime, "Sale is not active");
        _;
    }


    // 僅在使用期間可執行
    modifier onlyUnusedTicket(uint256 ticketId) {
        require(ticketOwner[msg.sender] == ticketId, "You do not own this ticket");
        require(!isTicketUsed[ticketId], "Ticket already used");
        _;
    }

    // 設定票價
    function setTicketPrice(uint256 _price) external onlyOwner{
        ticketPrice = _price;
    }

    // 設定最大票數
    function setMaxTickets(uint256 _maxTickets) external onlyOwner {
        maxTickets = _maxTickets;
    }

    // 設定售票時間
    function setSaleTime(uint256 _start, uint256 _end) external onlyOwner {
        startSaleTime = _start;
        endSaleTime = _end;
    }

    // 設定票券使用時間
    function setUseTime(uint256 _start, uint256 _end) external onlyOwner {
        startUseTime = _start;
        endUseTime = _end;
    }

    // 購買票券功能
    function buyTicket() external payable onlyDuringSale {
        require(hasPurchased[msg.sender] == false, "You have already purchased a ticket");
        require(ticketsSold < maxTickets, "All tickets sold out");
        require(msg.value >= ticketPrice, "Insufficient funds to buy ticket");
        require(address(msg.sender).balance >= 5 ether, "Your wallet balance must be greater than 5 USDT");

        uint256 ticketId = nextTicketId; // 分配新的票券 ID
        nextTicketId++; // 票券 ID 自增
        ticketsSold++; // 已售票數增加
        hasPurchased[msg.sender] = true; // 設置用戶已購票
        ticketOwner[msg.sender] = ticketId; // 記錄用戶擁有的票券 ID
    }


    // 使用票券功能
    function useTicket(uint256 ticketId) external onlyUnusedTicket(ticketId) {
        require(block.timestamp >= startUseTime && block.timestamp <= endUseTime, "Ticket cannot be used at this time");
        isTicketUsed[ticketId] = true; // 設置票券為已使用
    }

    // 退票功能
    function refundTicket(uint256 ticketId) external onlyUnusedTicket(ticketId) onlyDuringSale {
        delete ticketOwner[msg.sender]; // 移除票券擁有者
        nextTicketId--; // 票券 ID 減少
        ticketsSold--; // 已售票數減少
        hasPurchased[msg.sender] = false; // 設置用戶未購票
        isTicketUsed[ticketId] = false; // 設置票券未使用
        payable(msg.sender).transfer(ticketPrice); // 退還票款
    }


    // 提領合約金額功能
    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available to withdraw");
        payable(owner).transfer(balance); // 將合約餘額轉給管理者
    }


    // 檢查票券是否已使用
    function checkTicket(uint256 ticketId) external view returns (bool) {
        return isTicketUsed[ticketId]; // 返回票券使用狀態
    }

    
}