//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import 'ERC20.sol';

contract GameLand_airdrop {
    
    fallback() external payable {}
    
    receive() external payable {}
    
    address owner;
    address governance;
    address rev;
    constructor(address _rev) {
        owner = msg.sender;
        governance = msg.sender;
        rev = _rev;
    }

    function airdrop(address u, address[] memory adds, uint256[] memory amounts, uint256 totalamount, uint256 fee) public{
        require(adds.length == amounts.length, "length is error!");
        uint256 re = erc20allowance(u, msg.sender,address(this));
        require(
            re == totalamount + fee,
            "Not enough amount"
            );
        uint256 key = 0;
        for(uint i = 0; i < amounts.length;i++){
            key += amounts[i];
        }
        require(key == totalamount, "totalamount is error!");
        require(fee == totalamount * 3  / 100, "fee is error!");
        bool success = erc20transferFrom(u, msg.sender,address(this),re);
        require(success, "transfer error!");
        
        bool success2 =  erc20transfer(u, rev, fee);
        require(success2, "transfer2 error!");

        for(uint i = 0; i<adds.length;i++){
            bool success3 =  erc20transfer(u, adds[i], amounts[i]);
            require(success3, "transfer3 error!");
        }
    }



    bool locked = false;
    modifier reentrancyGuard {
        require(!locked, "Reentrancy guard failed");
        locked = true;
        _;
        locked = false;
    }



    modifier onlyGove() {
        require(msg.sender == governance, "Not governance");
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function updateOwner(address _Owner) public onlyOwner{
        if(_Owner != address(0))
        {
            owner = _Owner;
        }
    }
    
    function updategove(address _gove) public onlyOwner{
        governance = _gove;
    }

    function collatoralbalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    function get_gove() public view returns (address) {
        return governance;
    }
    
    
  

    
    
    function erc20approve(address usdt, address to, uint256 value) internal returns (bool success)  {
        bytes memory callload;
        callload = abi.encodeWithSignature(
                "approve(address,uint256)",
                to,
                value
            );    
        (success, ) = usdt.call(callload);
        return success;
    }
    
    function erc20transfer(address usdt, address to, uint256 value) internal returns (bool success)  {
        bytes memory callload;
        callload = abi.encodeWithSignature(
                "transfer(address,uint256)",
                to,
                value
            );    
        (success, ) = usdt.call(callload);
        return success;
    }
    
    function erc20transferFrom(address usdt, address from,address to, uint256 value) internal returns (bool success)  {
        bytes memory callload;
        callload = abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                from,
                to,
                value
            );    
        (success, ) = usdt.call(callload);
        return success;
    }

    function erc20allowance(address usdt, address from, address to) public view returns (uint256 result) {
        ERC20 u = ERC20(usdt);
        result = u.allowance(from,to);
        return result;
    }


    
    
    // 获取合约账户余额 
    function erc20getBalance(address usdt, address dz) public view returns (uint256) {
        ERC20 u = ERC20(usdt);
        return u.balanceOf(dz);
    }
}

