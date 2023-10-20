//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "IERC721.sol";
import "IERC1155.sol";
import "ERC721Holder.sol";
import "ERC1155Holder.sol";
import 'ERC20.sol';

// /Users/leo/Blockchain/near-hackathon/GameLand/artifacts/contracts/GameLand.sol/GameLand.json
contract GameLand_assets is ERC721Holder, ERC1155Holder {
    //all nft programes
    address[]  nftprogrames;
    
    fallback() external payable {}
    
    receive() external payable {}
    
    uint256[] nfts_list;
    function setnftslist(uint256 index,uint256 gameland_nft_id ) onlyGove public{
        nfts_list[index] = gameland_nft_id;
    }
    
    uint256[] borrowInfo_list;
    
    function setborrowInfolist(uint256 index,uint256 gameland_nft_id ) onlyGove public{
        borrowInfo_list[index] = gameland_nft_id;
    }
    
    address owner;
    
    address governance;

    constructor() {
        owner = msg.sender;
    }
    
    event Received(
        address from,
        address to,
        uint256 gameland_nft_id,
        uint256 nft_id,
        address nft_programe_address,
        uint256 daily_price,
        uint256 duration,
        uint256 collatoral,
        bool isERC721
    );

    event takedownnft(
        address from,
        address to,
        uint256 nftindex
    );

    event Rented(
        address from,
        address to,
        uint256 gameland_nft_id,
        uint256 borrowindex
    );


    event deleteborrow(
        address from,
        address to,
        uint256 borrowindex
    );
    
    struct nfts {
        //price in ether
        string nft_name;
        address form_contract;
        address payable nft_owner;
        string nft_type;
        uint256 nft_id;
        uint256 daily_price;
        uint256 duration;
        uint256 collatoral;
        bool borrow_status;
        uint256 time_now;
        uint256 penalty;
        uint256 gameland_nft_id;
        string pay_type;
        uint256 exist;
    }
    
    
    function compareStr(string memory _str, string memory str) public pure returns (bool) {
        return keccak256(abi.encodePacked(_str)) == keccak256(abi.encodePacked(str));
    }
    
    function add_nfts(nfts memory n,uint256 gameland_nft_id
    ) public onlyGove returns(uint256){
        uint256 nl = nfts_list.length;
        all_nfts[nl]=n;
        nfts_list.push(gameland_nft_id);
        emit Received(
            n.nft_owner,
            address(this),
            n.gameland_nft_id,
            n.nft_id,
            n.form_contract,
            n.daily_price,
            n.duration,
            n.collatoral,
            is721(n.form_contract)
        );
        return nl;
    }
    
    function add_nftsforpar(string memory nft_name, address form_contract, address payable nft_owner,string memory nft_type,
    uint256 nft_id, uint256 daily_price, uint256 duration, uint256 collatoral,
    uint256 penalty, uint256 gameland_nft_id, string memory pay_type
    ) public onlyGove returns(uint256){
        uint256 nl = nfts_list.length;
        all_nfts[nl].nft_name = nft_name;
        all_nfts[nl].form_contract = form_contract;
        all_nfts[nl].nft_owner = nft_owner;
        all_nfts[nl].nft_type = nft_type;
        all_nfts[nl].nft_id = nft_id;
        all_nfts[nl].daily_price = daily_price;
        all_nfts[nl].duration = duration;
        all_nfts[nl].collatoral = collatoral;
        all_nfts[nl].borrow_status = false;
        all_nfts[nl].time_now = uint256(block.timestamp);
        all_nfts[nl].penalty = penalty;
        all_nfts[nl].gameland_nft_id = gameland_nft_id;
        all_nfts[nl].pay_type = pay_type;
        all_nfts[nl].exist = 1;
        nfts_list.push(gameland_nft_id);
        return nl;
    }
    
    function set_nfts_borrowstatus(uint256 index,bool borrow_status) public onlyGove{
        all_nfts[index].borrow_status = borrow_status;
    }
    
    
    function delete_nfts(uint256 index
    ) public onlyGove{
        delete all_nfts[index];
        delete nfts_list[index];
        emit takedownnft(address(this), msg.sender, index);
    }
    

    struct borrowInfo {
        address payable borrower;
        uint256 due_date;
        string pay_type;
        uint256 total_amount;
        uint256 daily_price;
        address payable nft_owner;
        uint256 collatoral;
        uint256 time_now;
        uint256 expire_time;
        uint256 penalty;
        uint256 gameland_nft_id;
        uint256 exist;
    }
    
    function add_borrowInfo(borrowInfo memory b,uint256 gameland_nft_id
    ) public onlyGove returns(uint256){
        uint256 bl = borrowInfo_list.length;
        all_borrow[bl]=b;
        borrowInfo_list.push(gameland_nft_id);
        emit Rented(
            address(this),
            b.borrower,
            gameland_nft_id,
            bl
        );
        return bl;
    }
    
    function add_borrowInfoforpar(address payable borrower, uint256 due_date,uint256 total_amount,
    uint256 daily_price, address payable nft_owner, uint256 collatoral, uint256 expire_time,
    uint256 penalty, uint256 gameland_nft_id, string memory pay_type
    ) public onlyGove returns(uint256){
        uint256 bl = borrowInfo_list.length;
        all_borrow[bl].borrower = borrower;
        all_borrow[bl].total_amount = total_amount;
        all_borrow[bl].daily_price = daily_price;
        all_borrow[bl].nft_owner = nft_owner;
        all_borrow[bl].collatoral = collatoral;
        all_borrow[bl].time_now = uint256(block.timestamp);
        all_borrow[bl].penalty = penalty;
        all_borrow[bl].due_date = due_date;
        all_borrow[bl].expire_time = expire_time;
        all_borrow[bl].gameland_nft_id = gameland_nft_id;
        all_borrow[bl].pay_type = pay_type;
        all_borrow[bl].exist = 1;
        borrowInfo_list.push(gameland_nft_id);
        return bl;
    }
    
    
    function delete_borrowInfo(uint256 index
    ) public onlyGove{
        delete all_borrow[index];
        delete borrowInfo_list[index];
        emit deleteborrow(
            msg.sender,
            address(this),
            index
        );
    }
    

    //NFT => (borrower, due_date)
    mapping(uint256 => borrowInfo) all_borrow;

    //NFT => basci_info
    mapping(uint256 => nfts) all_nfts;


    //nft_programe address to their position
    mapping(uint256 => address) programe_number;
    

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
    
    function get_nfts(uint256 gameland_nft_id) public view returns (nfts memory) {
        nfts memory n;
        uint256 nl = nfts_list.length;
        for(uint i = 0; i < nl ; i++){
            if(all_nfts[i].exist == 1 && all_nfts[i].gameland_nft_id == gameland_nft_id){
                n = all_nfts[i];
                break;
            }
        }
        return n;
    }
    
    function get_nftsindex(uint256 gameland_nft_id) public view returns (uint256) {
        uint256 index;
        uint256 nl = nfts_list.length;
        for(uint i = 0; i < nl ; i++){
            if(all_nfts[i].exist == 1 && all_nfts[i].gameland_nft_id == gameland_nft_id){
                index = i;
                break;
            }
        }
        return index;
    }
    
    function get_nfts_forindex(uint256 index) public view returns (nfts memory) {
        return all_nfts[index];
    }
    
    function get_index() public view returns (uint256,uint256) {
        return (nfts_list.length,borrowInfo_list.length);
    }
    
    function get_nfts_list() public view returns (uint256[] memory) {
        return nfts_list;
    }
    
    function get_borrow_list() public view returns (uint256[] memory) {
        return borrowInfo_list;
    }

    function get_borrowInfo(uint256 gameland_nft_id) public view returns (borrowInfo memory) {
        borrowInfo memory b;
        uint256 bl = borrowInfo_list.length;
        for(uint i = 0; i < bl ; i++){
            if(all_borrow[i].exist == 1 && all_borrow[i].gameland_nft_id == gameland_nft_id){
                b = all_borrow[i];
                break;
            }
        }
        return b;
    }
    
    function get_borrowindex(uint256 gameland_nft_id) public view returns (uint256) {
        uint256 index;
        uint256 bl = borrowInfo_list.length;
        for(uint i = 0; i < bl ; i++){
            if(all_borrow[i].exist == 1 && all_borrow[i].gameland_nft_id == gameland_nft_id){
                index = i;
                break;
            }
        }
        return index;
    }
    
    function get_borrowInfo_forindex(uint256 index) public view returns (borrowInfo memory) {
        return all_borrow[index];
    }

    function is721(address _nft) public view returns (bool) {
        return IERC165(_nft).supportsInterface(type(IERC721).interfaceId);
    }

    function is1155(address _nft) public view returns (bool) {
        return IERC165(_nft).supportsInterface(type(IERC1155).interfaceId);
    }
    
    // addition the support of nft program
    function add_nft_program(address nft_programe_address) public onlyGove {
        uint256 how_many_nft_programes_has_in_gameland = nftprogrames.length;
        for(uint i = 0; i < how_many_nft_programes_has_in_gameland ; i++){
            if(programe_number[i] == nft_programe_address)
            {
                return;
            }
        }
        nftprogrames.push(nft_programe_address);
        programe_number[how_many_nft_programes_has_in_gameland] = nft_programe_address;
    }


    // transfer the nft
    function build_call(
        address nft_programe_address,
        address sender,
        address receiver,
        uint256 nft_id
    ) public onlyGove returns (bool success) {
        bytes memory callload;
        if (is721(nft_programe_address)) {
            callload = abi.encodeWithSignature(
                "safeTransferFrom(address,address,uint256)",
                sender,
                receiver,
                nft_id
            );
        }
        if (is1155(nft_programe_address)) {
            bytes memory empty = "";
            callload = abi.encodeWithSignature(
                "safeTransferFrom(address,address,uint256,uint256,bytes)",
                sender,
                receiver,
                nft_id,
                1,
                empty
            );
        }
        (success, ) = nft_programe_address.call(callload);
        return success;
    }
    
    function paytoaddress(
        address payable re, uint256 value
    ) public onlyGove {
        //bool pay_success;
        //(pay_success, ) = re.call{ gas: 2300, value: value}("");
        //require(pay_success,'pay transfer faild!');
        //return pay_success;
        
        re.transfer(value);
    }


    function get_nft_programes() public view returns (address[] memory) {
        return nftprogrames;
    }
    
    
    function erc20approve(address to, uint256 value, address usdt) public onlyGove returns (bool success)  {
        bytes memory callload;
        callload = abi.encodeWithSignature(
                "approve(address,uint256)",
                to,
                value
            );    
        (success, ) = usdt.call(callload);
        return success;
    }
    
    
    function erc20transfer(address to, uint256 value, address usdt) public onlyGove returns (bool success)  {
        bytes memory callload;
        callload = abi.encodeWithSignature(
                "transfer(address,uint256)",
                to,
                value
            );    
        (success, ) = usdt.call(callload);
        return success;
    }
    
    
    function erc20transferFrom(address from,address to, uint256 value, address usdt) public onlyGove returns (bool success)  {
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
    
    function erc20allowance(address from, address to,address u) public view returns (uint256 re) {
        ERC20 usdt = ERC20(u);
        re = usdt.allowance(from,to);
        return re;
    }
    
    // 获取合约账户余额 
    function erc20getBalance(address dz, address u) public view returns (uint256) {
        ERC20 usdt = ERC20(u);
        return usdt.balanceOf(dz);
    }
}

