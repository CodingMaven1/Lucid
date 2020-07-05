pragma solidity ^0.6.0;

contract CentralAuth {
    
    struct Product {
        string Name;
        string Description;
        uint Price;
        bool approval;
    }
    struct Company{
        string Name;
        string Description;
        uint ProductCount;
        mapping (uint => Product) Products;
    }

    address public Admin;
    mapping (address => Company) public Companies;

    constructor() public{
        Admin = msg.sender;
    }    

    modifier restricted() {
        require(msg.sender == Admin, "Only Admin has the access");
        _;
    }
    
    function CreateCompany(string memory _name, string memory  _description, address _companyowner) public restricted {
        Company memory newCompany = Company({
            Name: _name,
            Description: _description,
            ProductCount: 0
        });
        
        Companies[_companyowner] = newCompany;
    }
    
}