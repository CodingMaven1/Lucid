pragma solidity ^0.6.0;

contract CentralAuth {
    
    struct Product {
        string Name;
        string Description;
        uint Price;
        bool Approval;
        uint BidCount;
        mapping (uint => uint) Bids;
    }
    
    struct Company{
        string Name;
        string Description;
        uint ProductCount;
        address Owner;
        mapping (uint => Product) Products;
    }
    
    struct Logistic{
        string Name;
        uint Rating;
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
        Company memory newCompany = Company({
            Name: _name,
            Description: _description,
            Owner: msg.sender,
            ProductCount: 0
        });
        CompanyAddress.push(msg.sender);
        Companies[msg.sender] = newCompany;
    }
    
    function CreateProduct(string memory _name, string memory _Description, uint _price) public {
        require(msg.sender == Companies[msg.sender].Owner, "Only Company Owner has the access");
        Company storage CreatedCompany = Companies[msg.sender];
        Product memory newProduct = Product({
            Name: _name,
            Description: _Description,
            Price: _price,
            BidCount: 0,
            Approval: false
        });
        
        CreatedCompany.Products[CreatedCompany.ProductCount] = newProduct;
        CreatedCompany.ProductCount++;
    }
    
    function ApproveProduct(uint _index, address _companyowner) public onlyAdmin{
        require(msg.sender == Companies[_companyowner].Owner, "You are not the Owner");
        Companies[_companyowner].Products[_index].Approval = true;
    }
    
    function RegisterLogistics(string memory _name) public {
        Logistic memory newLogistics = Logistic({
            Name: _name,
            Rating: 0
        });
        LogisticAddress.push(msg.sender);
        Logistics[msg.sender] = newLogistics;
        
    }
    
}