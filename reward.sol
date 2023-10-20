//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import 'ERC20.sol';

contract GameLand_reward {
    
    fallback() external payable {}
    
    receive() external payable {}
    
    address owner;
    
    address governance;

    address usdt;
    address payable rev;
    ERC20 u;
    constructor(address _u, address payable _rev) {
        owner = msg.sender;
        governance = msg.sender;
        usdt = _u;
        rev = _rev;
        u = ERC20(usdt);
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
        owner = _Owner;
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
    
    function updateERC20(address _u) public onlyOwner{
        u = ERC20(_u);
        usdt = _u;
    }
  
    function updaterev(address payable _rev) public onlyOwner{
        rev = _rev;
    }
    
    function paytoaddress(
        address payable to
    ) public payable {
        //bool pay_success;
        //(pay_success, ) = re.call{ gas: 2300, value: value}("");
        //require(pay_success,'pay transfer faild!');
        //return pay_success;
        uint256 value = msg.value;
        require(value != 0, "value is error!");
        uint256 fee = value / 100 * 5;
        value = value - fee;
        to.transfer(value);
        rev.transfer(fee);
    }


    
    
    function erc20approve(address to, uint256 value) internal returns (bool success)  {
        bytes memory callload;
        callload = abi.encodeWithSignature(
                "approve(address,uint256)",
                to,
                value
            );    
        (success, ) = usdt.call(callload);
        return success;
    }
    
    function erc20transfer(address to, uint256 value) internal returns (bool success)  {
        bytes memory callload;
        callload = abi.encodeWithSignature(
                "transfer(address,uint256)",
                to,
                value
            );    
        (success, ) = usdt.call(callload);
        return success;
    }
    
    function erc20transferFrom(address from,address to, uint256 value) internal returns (bool success)  {
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

    function erc20allowance(address from, address to) public view returns (uint256 re) {
        re = u.allowance(from,to);
        return re;
    }

    function paytoaddress_usdt(
        address to, uint256 value
    ) public {
        uint256 re = erc20allowance(msg.sender,address(this));
        
        require(
            re >= value,
            "Not enough amount"
        );
        bool success = erc20transferFrom(msg.sender,address(this),value);
        require(success, "transfer error!");
        uint256 fee = value / 100 * 5;
        value = value - fee;
        bool success2 =  erc20transfer(to, value);
        require(success2, "transfer2 error!");
    }
    
    
    // 获取合约账户余额 
    function erc20getBalance(address dz) public view returns (uint256) {
        return u.balanceOf(dz);
    }
}

