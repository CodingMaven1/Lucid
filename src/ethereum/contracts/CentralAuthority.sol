pragma solidity ^0.6.0;

contract CentralAuth {
    
    struct Product {
        string Name;
        string Description;
        uint Price;
        bool Approval;
    }
    
    struct Company{
        string Name;
        string Description;
        uint ProductCount;
        address Owner;
        mapping (uint => Product) Products;
    }
    
    address public Admin;
    mapping (address => Company) public Companies;
    
    constructor() public{
        Admin = msg.sender;
    }    
    
    modifier onlyAdmin() {
        require(msg.sender == Admin, "Only Admin has the access");
        _;
    }
    
    function CreateCompany(string memory _name, string memory  _description, address _companyowner) public onlyAdmin {
        Company memory newCompany = Company({
            Name: _name,
            Description: _description,
            Owner: _companyowner,
            ProductCount: 0
        });
        
        Companies[_companyowner] = newCompany;
    }
    
    function CreateProduct(string memory _name, string memory _Description, uint _price) public {
        require(msg.sender == Companies[msg.sender].Owner, "Only Company Owner has the access");
        Company storage CreatedCompany = Companies[msg.sender];
        Product memory newProduct = Product({
            Name: _name,
            Description: _Description,
            Price: _price,
            Approval: false
        });
        
        CreatedCompany.Products[CreatedCompany.ProductCount] = newProduct;
        CreatedCompany.ProductCount++;
    }
    
    function ApproveProduct(uint _index, address _companyowner) public onlyAdmin{
        require(msg.sender == Companies[_companyowner].Owner, "You are not the Owner");
        Companies[_companyowner].Products[_index].Approval = true;
    }
    
}