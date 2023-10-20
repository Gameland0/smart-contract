

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "r1.sol";

// /Users/leo/Blockchain/near-hackathon/GameLand/artifacts/contracts/GameLand.sol/GameLand.json
contract GameLand_control is ERC721Holder, ERC1155Holder {
    //all nft programes
    address owner;
    address payable rev;
    address payable assets_contract;
    address governance;
    GameLand_assets ga;
    ERC20 usdt;
    address usdtaddress;
    constructor(address payable _rev, address _gove, address payable _ga, address u) {
        owner = msg.sender;
        rev = _rev;
        governance = _gove;
        ga = GameLand_assets(_ga);
        assets_contract = _ga;
        usdt = ERC20(u);
        usdtaddress = u;
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

    function updateERC20(address _u) public onlyOwner{
        usdt = ERC20(_u);
        usdtaddress = _u;
    }

    function updategove(address _gove) public onlyOwner{
        governance = _gove;
    }
    
    function updaterev(address payable _rev) public onlyOwner{
        rev = _rev;
    }
    
    function updateGameLand_assets(address payable _ga) public onlyOwner{
        ga = GameLand_assets(_ga);
        assets_contract = _ga;
    }

    function collatoralbalance() public view returns (uint256) {
        return address(this).balance;
    }

    function add_nft_program(address nft_programe_address) public onlyGove {
        ga.add_nft_program(nft_programe_address);
    }

    function add_nft_programforarray(address[] memory nft_programe_address) public onlyGove {
        for(uint i=0;i<nft_programe_address.length;i++){
            ga.add_nft_program(nft_programe_address[i]);
        }
        
    }

    function is721(address _nft) public view returns (bool) {
        return IERC165(_nft).supportsInterface(type(IERC721).interfaceId);
    }

    function is1155(address _nft) public view returns (bool) {
        return IERC165(_nft).supportsInterface(type(IERC1155).interfaceId);
    }

    
    
    function deposit(string memory nft_name, string memory nft_type,
    uint256 nft_id, uint256 daily_price, uint256 duration, uint256 collatoral, 
    uint256 penalty, uint256 gameland_nft_id, address nft_programe_address, string memory pay_type
    ) public returns(uint256 nftindex){
        //this function will check everything about nft
        bool success;
        success = ga.build_call(nft_programe_address,
            msg.sender,
            assets_contract,
            nft_id);
        require(success,'nft transfer faild!');
        GameLand_assets.nfts memory n = GameLand_assets.nfts(nft_name, nft_programe_address, payable(msg.sender), nft_type, nft_id, daily_price, duration,
            collatoral, false,uint256(block.timestamp), penalty, gameland_nft_id, pay_type,1);
        nftindex = ga.add_nfts(n,gameland_nft_id);
        return nftindex;
    }
    
    
    function rent(uint256 index,uint256 borrowdays
    ) public payable returns(uint256 borrowindex) {
        GameLand_assets.nfts memory n = ga.get_nfts_forindex(index);
        uint256 total_amount = n.daily_price * borrowdays + n.collatoral + n.penalty;
        require(
            msg.value >= total_amount,
            "Not enough amount"
        );
        
        require(
            ga.compareStr(n.pay_type, 'eth'), 'just only for eth'
        );
        
        require(
            borrowdays <= n.duration,
            "Not long for days"
        );
        
        require(n.exist == 1 && n.borrow_status == false, "Already been borrowed");
        bool success;
        success = ga.build_call(n.form_contract,
            assets_contract,
            msg.sender,
            n.nft_id);
        require(success,'nft transfer faild!');
        uint256 price = n.daily_price * borrowdays;
        uint256 fee = (price / 100) * 3;
        uint256 pay_to_owner = price - fee;
        rev.transfer(fee);
        n.nft_owner.transfer(pay_to_owner);
        assets_contract.transfer(n.collatoral + n.penalty);
        borrowindex = rent_implement(n, index, borrowdays, total_amount);
        return borrowindex;
    }
    
    
    function rent_implement(GameLand_assets.nfts memory n, 
    uint256 index, uint256 borrowdays, uint256 total_amount
    ) internal returns(uint256) {
        uint256 expire_time = borrowdays * 24 * 3600 + 8 * 3600 + uint256(block.timestamp);
        GameLand_assets.borrowInfo memory b = GameLand_assets.borrowInfo(payable(msg.sender), borrowdays,n.pay_type,
        total_amount, n.daily_price, n.nft_owner, n.collatoral, uint256(block.timestamp),expire_time, n.penalty,
            n.gameland_nft_id ,1 );
        uint256 sl = ga.add_borrowInfo(b,n.gameland_nft_id);
        ga.set_nfts_borrowstatus(index,true);
        
        return sl;
    }
    
    function rent_usdt(uint256 index,uint256 borrowdays
    ) public payable returns(uint256 borrowindex) {
        GameLand_assets.nfts memory n = ga.get_nfts_forindex(index);
        uint256 total_amount = n.daily_price * borrowdays + n.collatoral + n.penalty;
        
        uint256 re = usdt.allowance(msg.sender,address(this));
        
        require(
            re >= total_amount,
            "Not enough amount"
        );
        
        require(
            ga.compareStr(n.pay_type, 'usdt'), 'just only for usdt'
        );
        
        require(
            borrowdays <= n.duration,
            "Not long for days"
        );
        
        require(n.exist == 1 && n.borrow_status == false, "Already been borrowed");
        bool success;
        success = ga.build_call(n.form_contract,
            assets_contract,
            msg.sender,
            n.nft_id);
        require(success,'nft transfer faild!');
        
        uint256 price = n.daily_price * borrowdays;
        uint256 fee = (price / 100) * 3;
        uint256 pay_to_owner = price - fee;
        
        bool pay_fee_success = transferFrom(msg.sender,rev,fee);
        require(pay_fee_success,'fee transfer faild!');
        bool rent_success = transferFrom(msg.sender,n.nft_owner,pay_to_owner);
        require(rent_success,'pay_to_owner transfer faild!');
        bool ga_success = transferFrom(msg.sender,assets_contract,(n.collatoral + n.penalty));
        require(ga_success,'ga transfer faild!');
        borrowindex = rent_implement(n, index, borrowdays, total_amount);
        return borrowindex;
    }
    
    
    function transferFrom(address from,address to, uint256 value) internal returns (bool success)  {
        bytes memory callload;
        callload = abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                from,
                to,
                value
            );    
        (success, ) = usdtaddress.call(callload);
        return success;
    }
    
    


    
        // borrower return the nft
    //need approval
    // overdue_days equal 0 means not overdue
    // extra_amount is total amount for overdue
    function returnnft(
        uint256 borowlistindex,
        uint256 gameland_nft_id
    ) public {
        bool success;
        uint256 nftlistindex = ga.get_nftsindex(gameland_nft_id);
        GameLand_assets.nfts memory n = ga.get_nfts_forindex(nftlistindex);
        GameLand_assets.borrowInfo memory b = ga.get_borrowInfo_forindex(borowlistindex);
        
        require(
            n.borrow_status == true,
            "the nft has not been borrowed"
        );
        
        require(
            ga.compareStr(n.pay_type, 'eth'), 'just only for eth'
        );
        
        success = ga.build_call(
            n.form_contract,
            msg.sender,
            assets_contract,
            n.nft_id
        );
        require(success, "return failed");
        
        if(uint256(block.timestamp) < b.expire_time)
        {
            ga.paytoaddress(b.borrower,(b.collatoral+ b.penalty));
        }
        else{
            uint256 expirehour = (uint256(block.timestamp) - b.expire_time) / 3600;
            uint256 overdue_days = ((expirehour - 8) / 24) + 1;
            uint256 extra_amount = overdue_days * b.daily_price;
            
            uint256 penalty = b.penalty / 2;
            if (b.collatoral > extra_amount)
            {
                uint256 fee = (extra_amount / 100) * 3;
                uint256 collatoral = b.collatoral - extra_amount;
                ga.paytoaddress(b.borrower,collatoral);
                
                ga.paytoaddress(rev,(fee+ penalty));
            
                ga.paytoaddress(b.nft_owner,(extra_amount - fee + penalty));
            }
            else{
                uint256 fee = (b.collatoral / 100) * 3;
                ga.paytoaddress(rev,(fee+ penalty));
            
                ga.paytoaddress(b.nft_owner,(b.collatoral - fee + penalty));
            }
            
        }
        
        ga.delete_borrowInfo(borowlistindex);
        ga.set_nfts_borrowstatus(nftlistindex, false);
        
    }
    
    
            // borrower return the nft
    //need approval
    // overdue_days equal 0 means not overdue
    // extra_amount is total amount for overdue
    function returnnft_usdt(
        uint256 borowlistindex,
        uint256 gameland_nft_id
    ) public {
        bool success;
        uint256 nftlistindex = ga.get_nftsindex(gameland_nft_id);
        GameLand_assets.nfts memory n = ga.get_nfts_forindex(nftlistindex);
        GameLand_assets.borrowInfo memory b = ga.get_borrowInfo_forindex(borowlistindex);
        
        require(
            n.borrow_status == true,
            "the nft has not been borrowed"
        );
        
        require(
            ga.compareStr(n.pay_type, 'usdt'), 'just only for usdt'
        );
        
        success = ga.build_call(
            n.form_contract,
            msg.sender,
            assets_contract,
            n.nft_id
        );
        require(success, "return failed");
        
        if(uint256(block.timestamp) < b.expire_time)
        {
            ga.erc20transfer(b.borrower,(b.collatoral+ b.penalty),usdtaddress);
        }
        else{
            uint256 expirehour = (uint256(block.timestamp) - b.expire_time) / 3600;
            uint256 overdue_days = ((expirehour - 8) / 24) + 1;
            uint256 extra_amount = overdue_days * b.daily_price;
            
            uint256 penalty = b.penalty / 2;
            if (b.collatoral > extra_amount)
            {
                uint256 fee = (extra_amount / 100) * 3;
                uint256 collatoral = b.collatoral - extra_amount;
                ga.erc20transfer(b.borrower,collatoral,usdtaddress);
                
                ga.erc20transfer(rev,(fee+ penalty),usdtaddress);
            
                ga.erc20transfer(b.nft_owner,(extra_amount - fee + penalty),usdtaddress);
            }
            else{
                uint256 fee = (b.collatoral / 100) * 3;
                ga.erc20transfer(rev,(fee+ penalty),usdtaddress);
            
                ga.erc20transfer(b.nft_owner,(b.collatoral - fee + penalty),usdtaddress);
            }
            
        }
        
        ga.delete_borrowInfo(borowlistindex);
        ga.set_nfts_borrowstatus(nftlistindex, false);
        
    }
    
        //owner withdraw the nft when it is not borrowed
    function withdrawnft(
        uint256 index
    ) public {
        GameLand_assets.nfts memory n = ga.get_nfts_forindex(index);
        require(n.exist == 1 && n.borrow_status == false, "The nft is borrowed");
        require(
            msg.sender == n.nft_owner,
            "Only owner can withdraw NFT"
        );
        bool success;
        success = ga.build_call(n.form_contract,
            assets_contract,
            msg.sender,
            n.nft_id);
        require(success, "withdraw nft failed");
        ga.delete_nfts(index);
        
    }

    //owner take the collatoral when the borrower failed to return the nft
    function confiscation(uint256 nftlistindex, uint256 borowlistindex) public {
        GameLand_assets.nfts memory n = ga.get_nfts_forindex(nftlistindex);
        GameLand_assets.borrowInfo memory b = ga.get_borrowInfo_forindex(borowlistindex);
        require(
            n.borrow_status,
            "the nft has not been borrowed"
        );
        require(
            msg.sender == n.nft_owner,
            "Only owner can confiscate"
        );
        require(
            b.expire_time <= block.timestamp,
            "Not yet"
        );
        require(
            ga.compareStr(n.pay_type, 'eth'), 'just only for eth'
        );
        uint256 penalty = b.penalty / 2;
        ga.paytoaddress(n.nft_owner,(n.collatoral + penalty));
        
        ga.paytoaddress(rev,penalty);
        ga.delete_nfts(nftlistindex);
        ga.delete_borrowInfo(borowlistindex);
        
    }
    
        //owner take the collatoral when the borrower failed to return the nft
    function confiscation_usdt(uint256 nftlistindex, uint256 borowlistindex) public {
        GameLand_assets.nfts memory n = ga.get_nfts_forindex(nftlistindex);
        GameLand_assets.borrowInfo memory b = ga.get_borrowInfo_forindex(borowlistindex);
        require(
            n.borrow_status,
            "the nft has not been borrowed"
        );
        require(
            msg.sender == n.nft_owner,
            "Only owner can confiscate"
        );
        require(
            b.expire_time <= block.timestamp,
            "Not yet"
        );
        require(
            ga.compareStr(n.pay_type, 'usdt'), 'just only for usdt'
        );
        uint256 penalty = b.penalty / 2;
        ga.erc20transfer(n.nft_owner,(n.collatoral + penalty),usdtaddress);
        
        ga.erc20transfer(rev,penalty,usdtaddress);
        ga.delete_nfts(nftlistindex);
        ga.delete_borrowInfo(borowlistindex);
        
    }
    
    

    function get_nft_programes() public view returns (address[] memory) {
        return ga.get_nft_programes();
    }
}
