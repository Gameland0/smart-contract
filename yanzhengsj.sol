//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;
import 'ERC20.sol';

contract GameLand_verify {
    
    fallback() external payable {}
    
    receive() external payable {}
    
    address owner;
    ERC20 u;
    address governance;
    address immutable usdt;
    address rev;
    uint baseprice;
    constructor(address _u, address _rev) {
        owner = msg.sender;
        governance = msg.sender;
        usdt = _u;
        rev = _rev;
        baseprice = 2000000000000000000;
        u = ERC20(_u);
    }
    mapping(uint256 => address_amount_info) address_info;
    address[] address_list;
    struct address_amount_info
    {
        address add;
        verify_info[] vi;
        uint sl;
        uint256 price;
    }

    struct verify_info
    {
        address gm_address;
        uint256 dt;
        uint256 price;
    }

    function set_address_amount(uint256 amount) public{
        address add = msg.sender;
        uint256 zt = find_address(add);
        if(zt == 999999999)
        {
            uint256 asl = address_list.length;
            address_list.push(add);
            
            address_info[asl].add = add;
            address_info[asl].price = amount;
            verify_info memory vvi;
            vvi.gm_address = add;
            vvi.dt = uint256(block.timestamp);
            vvi.price = amount;

            address_info[asl].vi.push(vvi);
            address_info[asl].sl += 1;
        }
        else{
            address_info[zt].price = amount;
            
        }
    }

    function find_address(address add) public view returns(uint256){
        for(uint256 i=0;i<address_list.length;i++){
            if(address_list[i] == add)
            {
                return i;
            }
        }
        return 999999999;
    }

    function batch_set_address_amount(uint256[] calldata amounts, address[] calldata adds) public onlyGove{
        require(amounts.length == adds.length, "The lengths of the two arrays must be equal");
        for(uint256 i =0; i<adds.length;i++)
        {
            address add = adds[i];
            uint amount = amounts[i];
            uint256 zt = find_address(add);
            if(zt == 999999999)
            {
                uint256 asl = address_list.length;
                address_list.push(add);
            
                address_info[asl].add = add;
                address_info[asl].price = amount;
                verify_info memory vvi;
                vvi.gm_address = add;
                vvi.dt = uint256(block.timestamp);
                vvi.price = amount;

                address_info[asl].vi.push(vvi);
                address_info[asl].sl += 1;
            }
            else{
                address_info[zt].price = amount;
            
            }
            
        }
        
    }

    function set_baseprice(uint newbaseprice) public onlyGove{
        baseprice = newbaseprice;
    }

    bool locked = false;
    modifier reentrancyGuard {
        require(!locked, "Reentrancy guard failed");
        locked = true;
        _;
        locked = false;
    }

    function verify_address_amount(address mdd_address) public reentrancyGuard{
        uint256 re = erc20allowance(msg.sender,address(this));
        uint256 zt = find_address(mdd_address);
        if(zt != 999999999)
        {
            require(
            re >= address_info[zt].price,
            "Not enough amount"
            );
            re = address_info[zt].price;
            bool success = erc20transferFrom(msg.sender,address(this),re);
            require(success, "transfer error!");
            uint256 fee = re * 5  / 100;
            re = re - fee;
            bool success2 =  erc20transfer(mdd_address, re);
            require(success2, "transfer2 error!");
            bool success3 =  erc20transfer(rev, fee);
            require(success3, "transfer3 error!");

            address add = msg.sender;
            verify_info memory vvi;
            vvi.gm_address = add;
            vvi.dt = uint256(block.timestamp);
            vvi.price = re;

            address_info[zt].vi.push(vvi);
            address_info[zt].sl += 1;
        }
        else{
            require(
            re >= baseprice,
            "Not enough amount"
            );
            re = baseprice;
            bool success = erc20transferFrom(msg.sender,address(this),re);
            require(success, "transfer error!");
            uint256 fee = re * 5  / 100;
            re = re - fee;
            bool success2 =  erc20transfer(mdd_address, re);
            require(success2, "transfer2 error!");
            bool success3 =  erc20transfer(rev, fee);
            require(success3, "transfer3 error!");

            uint256 asl = address_list.length;
            address_list.push(mdd_address);
            address add = msg.sender;
            address_info[asl].add = mdd_address;
            address_info[asl].price = baseprice;
            verify_info memory vvi;
            vvi.gm_address = add;
            vvi.dt = uint256(block.timestamp);
            vvi.price = re;

            address_info[asl].vi.push(vvi);
            address_info[asl].sl += 1;
        }
        

    }

    function get_address_info(uint key) view public returns(address_amount_info memory){
        return address_info[key];
    }

    function get_whethertobuy(address mdadd) view public returns(uint){
        address add = msg.sender;
        uint256 zt = find_address(mdadd);
        if(zt != 999999999)
        {
            for(uint i=0;i<address_info[zt].vi.length;i++)
            {
                if(address_info[zt].vi[i].gm_address == add)
                {
                    return i;
                }
            } 
        }
        return 999999999;
    }

    function get_address_list() public view returns(address[] memory){
        return address_list;
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

    function erc20allowance(address from, address to) public view returns (uint256 result) {
        result = u.allowance(from,to);
        return result;
    }


    
    
    // 获取合约账户余额 
    function erc20getBalance(address dz) public view returns (uint256) {
        return u.balanceOf(dz);
    }
}

