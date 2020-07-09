pragma solidity ^0.6.0;

contract CentralAuth {
    
    struct Product {
        string Name;
        string Description;
        uint Price;
        bool Approval;
        uint Maxfees;
        uint BidCount;
        bool AcceptBid;
        mapping (uint => Bid) Bids;
    }
    
    struct Company{
        string Name;
        string Description;
        uint ProductCount;
        address Owner;
        mapping (uint => Product) Products;
    }
    
    struct Bid{
        uint demandfees;
        uint security;
        address logisticAddress;
    }
    
    struct Logistic{
        string Name;
        uint Rating;
        address Owner;
    }
    
    address public Admin;
    address[] public CompanyAddress;
    address[] public LogisticAddress;
    mapping (address => Company) public Companies;
    mapping (address => Logistic) public Logistics;
    
    constructor() public{
        Admin = msg.sender;
    }    
    
    modifier onlyAdmin() {
        require(msg.sender == Admin, "Only Admin has the access");
        _;
    }
    
    function CreateCompany(string memory _name, string memory  _description) public {
        require(Companies[msg.sender].Owner == msg.sender, "Company already registered from this address");
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
        Product memory newProduct = Product({
            Name: _name,
            Description: _Description,
            Price: _price,
            BidCount: 0,
            Approval: false,
            Maxfees: 0,
            AcceptBid: false
        });
        
        CreatedCompany.Products[CreatedCompany.ProductCount] = newProduct;
        CreatedCompany.ProductCount++;
    }
    
    function ApproveProduct(uint _index, address _companyowner) public onlyAdmin{
        Companies[_companyowner].Products[_index].Approval = true;
    }
    
    function RegisterLogistics(string memory _name) public {
        require(Logistics[msg.sender].Owner == msg.sender, "Logistic already registered from this address");
        Logistic memory newLogistics = Logistic({
            Name: _name,
            Rating: 0,
            Owner: msg.sender
        });
        LogisticAddress.push(msg.sender);
        Logistics[msg.sender] = newLogistics;
    }
    
    function AcceptBid(uint _maxfees, uint _index) public {
        require(msg.sender == Companies[msg.sender].Owner, "Only Company Owner has the access");
        Companies[msg.sender].Products[_index].AcceptBid = true;
        Companies[msg.sender].Products[_index].Maxfees = _maxfees;
    }
    
    function MakeBid(uint _demand) public payable {
        
    }
    
}