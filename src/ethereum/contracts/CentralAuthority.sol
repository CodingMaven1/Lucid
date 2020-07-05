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
        Product[] Products;
    }
    
    address public Admin;
    mapping (address => Company) public Companies;
    
    constructor() public{
        Admin = msg.sender;
    }    
    
    // function CreateCompany(address)
}