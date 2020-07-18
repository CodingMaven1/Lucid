pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract CentralAuth {
    
    using SafeMath for uint;
    
    struct Product {
        string Name;
        string Description;
        uint Price;
        bool Approval;
        uint Maxfees;
        uint BidCount;
        bool AcceptBid;
        uint PrevBidIndex;
        uint[] FinalizedBids;
        mapping (uint => Bid) Bids;
        address CurrentRetailer;
        uint CurrentDealMoney;
    }
    
    struct Company{
        string Name;
        string Description;
        uint ProductCount;
        address Owner;
        mapping (uint => Product) Products;
    }
    
    struct Bid{
        uint Demandfees;
        uint Security;
        uint DealMoney;
        address payable LogisticAddress;
        bool SecurityReturned;
        bool Feespaidtologistic;
        bool Feespaidtocompany;
        address RetailerAddress;
        address CompanyAddress;
        uint ProductIndex;
    }
    
    struct Retailer{
        string Name;
        string Description;
        address Owner; 
        uint ProductCount;
        mapping (uint => Bid)  ProductsRecieved;
    }
    
    struct Logistic{
        string Name;
        uint Rating;
        address Owner;
    }
    
    address public Admin;
    address[] public CompanyAddress;
    address[] public LogisticAddress;
    address[] public RetailerAddress;
    mapping (address => Company) public Companies;
    mapping (address => Logistic) public Logistics;
    mapping (address => Retailer) public Retailers;
    
    constructor() public{
        Admin = msg.sender;
    }    
    
    modifier onlyAdmin() {
        require(msg.sender == Admin, "Only Admin has the access");
        _;
    }
    
    function CreateCompany(string memory _name, string memory  _description) public {
        require(Companies[msg.sender].Owner != msg.sender, "Company already registered from this address");
        Company memory newCompany = Company({
            Name: _name,
            Description: _description,
            Owner: msg.sender,
            ProductCount: 0
        });
        CompanyAddress.push(msg.sender);
        Companies[msg.sender] = newCompany;
    }
    
    function CreateProduct(string memory _name, string memory _Description, uint _price ) public {
        require(msg.sender == Companies[msg.sender].Owner, "Only Company Owner has the access");
        Company storage CreatedCompany = Companies[msg.sender];
        uint[] memory arr;
        Product memory newProduct = Product({
            Name: _name,
            Description: _Description,
            Price: _price,
            BidCount: 0,
            Approval: false,
            Maxfees: 0,
            AcceptBid: false,
            FinalizedBids: arr,
            PrevBidIndex: 0,
            CurrentRetailer: msg.sender,
            CurrentDealMoney: 0
        });
        
        CreatedCompany.Products[CreatedCompany.ProductCount] = newProduct;
        CreatedCompany.ProductCount.add(1);
    }
    
    function ApproveProduct(uint _index, address _companyowner) public onlyAdmin{
        Product storage CreatedProduct = Companies[_companyowner].Products[_index];
        CreatedProduct.Approval = true;
    }
    
    function RegisterLogistics(string memory _name) public {
        require(Logistics[msg.sender].Owner != msg.sender, "Logistic already registered from this address");
        Logistic memory newLogistics = Logistic({
            Name: _name,
            Rating: 0,
            Owner: msg.sender
        });
        LogisticAddress.push(msg.sender);
        Logistics[msg.sender] = newLogistics;
    }
    
    function RegisterRetailer(string memory _name, string memory _description) public {
        require(msg.sender != Retailers[msg.sender].Owner, "Retailer already registered from this address");
        Retailer memory newRetailer = Retailer({
            Name: _name,
            Description: _description,
            Owner: msg.sender,
            ProductCount: 0
        });
        RetailerAddress.push(msg.sender);
        Retailers[msg.sender] = newRetailer;
    }
    
    function AcceptBid(uint _maxfees, uint _index, address _retaileraddress, uint _dealmoney) public {
        require(msg.sender == Companies[msg.sender].Owner, "Only Company Owner has the access");
        Product storage CreatedProduct = Companies[msg.sender].Products[_index];
        require(CreatedProduct.Approval, "Your Product has not been approved yet");
        CreatedProduct.AcceptBid = true;
        CreatedProduct.Maxfees = _maxfees;
        CreatedProduct.CurrentRetailer = _retaileraddress;
        CreatedProduct.CurrentDealMoney = _dealmoney;
    }
    
    function MakeBid(uint _demand, address _companyowner, uint _index) public payable {
        Product storage CreatedProduct = Companies[_companyowner].Products[_index];
        require(CreatedProduct.AcceptBid, "Company hasn't approved the bidding of the product");
        require(msg.value > 0, "Pay appropriate security money");
        require(_demand < CreatedProduct.Maxfees, "Your demanded fees is more than the max fee the company is wiiling to pay");
        Bid memory newBid = Bid({
            Demandfees: _demand,
            Security: msg.value,
            LogisticAddress: msg.sender,
            Feespaidtologistic: false,
            SecurityReturned: false,
            Feespaidtocompany: false,
            RetailerAddress: CreatedProduct.CurrentRetailer,
            CompanyAddress: _companyowner,
            ProductIndex: _index,
            DealMoney: CreatedProduct.CurrentDealMoney
        });
        CreatedProduct.Bids[CreatedProduct.BidCount] = newBid;
        CreatedProduct.BidCount.add(1);
    }
    
    function FinalizeBid(uint _index, uint _bidIndex) public {
        require(msg.sender == Companies[msg.sender].Owner, "Only Company Owner has the access");
        Product storage CreatedProduct = Companies[msg.sender].Products[_index];
        for(uint i= CreatedProduct.PrevBidIndex; i<=CreatedProduct.BidCount; i++){
            Bid storage CreatedBid = CreatedProduct.Bids[i];
            CreatedBid.LogisticAddress.transfer(CreatedBid.Security);
            CreatedBid.SecurityReturned = true;
        }
        CreatedProduct.PrevBidIndex = CreatedProduct.BidCount.add(1);
        CreatedProduct.FinalizedBids.push(_bidIndex);
        CreatedProduct.AcceptBid = false;
        CreatedProduct.Maxfees =0;
    }
    
    function RecieveProduct(address _companyowner, uint _index, uint _bidIndex) public{
        require(msg.sender == Retailers[msg.sender].Owner);
        Logistic storage CreatedRetailer = Retailers[msg.sender]; 
        Bid storage CreatedBid = Companies[_companyowner].Products[_index].Bids[_bidIndex];
        
    }
    
}