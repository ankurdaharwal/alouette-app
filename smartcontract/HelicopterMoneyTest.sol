pragma solidity ^0.6.3;

contract HelicopterMoney{
  struct Wallet{
    bool isCitizen; // false: company 
    bool isValid; // true: valid, false: invalid
    bytes32 numIDCard;
    bytes32 numCompany;
    uint256 balance; // balance in € * 100
    uint256 sentToTax;
    bool exists; // so easy to check if a wallet exists
  }
  
  mapping(bytes32 => Wallet) citizensWallets;
  mapping(bytes32 => Wallet) companiesWallets;
  
  bytes32[] listCitizensWallets;
  bytes32[] listCompaniesWallets;

  uint256 initialBalance = 100000; // 1000€

  constructor() public{

  }
  
  function creationOfCitizenWallet(bytes32 numIDCard, uint256 verificationKey) public {
      
    // check already exists
    // check numIDCard and verificationKey
    
    listCitizensWallets.push(numIDCard);
    
    citizensWallets[numIDCard] = Wallet(
      {
        isCitizen: true,
        isValid: true,
        numIDCard: numIDCard,
        numCompany: '',
        balance: initialBalance,
        sentToTax: 0,
        exists: true
      }
    );
  }
  
  function creationOfCompanyWallet(bytes32 numCompany, uint256 verificationKey) public {
      
    // check already exists
    // check numCompany and verificationKey
    
    listCompaniesWallets.push(numCompany);
    
    companiesWallets[numCompany] = Wallet(
      {
        isCitizen: false,
        isValid: true,
        numIDCard: '',
        numCompany: numCompany,
        balance: 0,
        sentToTax: 0,
        exists: true
      }
    );
  }
  
  function transferFromCitizenToCompany(bytes32 numIDCard, uint256 verificationKey, uint256 transferAmount, bytes32 destinationNumCompany) public {
      
    // check transferAmount overflow and is positive
    // check numIDCard and verificationKey
     
    // check citizen wallet exists
    require(citizensWallets[numIDCard].exists, "citizen id wallet does not exist");
    require(companiesWallets[destinationNumCompany].exists, "destination company does not exist");
    require(citizensWallets[numIDCard].balance >= transferAmount, "insufficient balance");
    
    citizensWallets[numIDCard].balance -= transferAmount;
    companiesWallets[destinationNumCompany].balance += transferAmount;

  }

  
  // below functions are limited to admin and authorities
  
  function getAllCitizensWallets() public view returns (bytes32[] memory) {
      
    return listCitizensWallets;
  }
  
  function getCitizenWallet(bytes32 numIDCard) public view returns (bool, bool, bool, bytes32, uint256) {
      
    return (citizensWallets[numIDCard].exists, citizensWallets[numIDCard].isCitizen, citizensWallets[numIDCard].isValid, citizensWallets[numIDCard].numIDCard, citizensWallets[numIDCard].balance);
  }
  
  function getAllCompaniesWallets() public view returns (bytes32[] memory) {
      
    return listCompaniesWallets;
  }
  
  function getCompanyWallet(bytes32 numCompany) public view returns (bool, bool, bool, bytes32, uint256, uint256) {
      
    return (companiesWallets[numCompany].exists, companiesWallets[numCompany].isCitizen, companiesWallets[numCompany].isValid, companiesWallets[numCompany].numCompany, companiesWallets[numCompany].balance, companiesWallets[numCompany].sentToTax);
  }
  
  function validationOfCitizensWallets(bytes32[] memory listCitizensWalletsToValidate) public {
    
    for (uint i=0; i<listCitizensWalletsToValidate.length; i++) {
      citizensWallets[listCitizensWalletsToValidate[i]].isValid = true;
    }
  }
  
  function invalidationOfCitizensWallets(bytes32[] memory listCitizensWalletsToInvalidate) public {
    
    for (uint i=0; i<listCitizensWalletsToInvalidate.length; i++) {
      citizensWallets[listCitizensWalletsToInvalidate[i]].isValid = false;
    }
  }
  
  function validationOfCompanyWallets(bytes32[] memory listCompaniesWalletsToValidate) public {
    
    for (uint i=0; i<listCompaniesWalletsToValidate.length; i++) {
      companiesWallets[listCompaniesWalletsToValidate[i]].isValid = true;
    }
  }
  
  function invalidationOfCompanyWallets(bytes32[] memory listCompaniesWalletsToInvalidate) public {
    
    for (uint i=0; i<listCompaniesWalletsToInvalidate.length; i++) {
      companiesWallets[listCompaniesWalletsToInvalidate[i]].isValid = false;
    }
  }
  
  
}
  
  
  
  
  
  
  
  
/*
  function creationOfIndividualWallet(string memory ID, uint balance) public {
    balancesUsers[ID] = wallet("citizen", true, ID, balance,0);
  }

  function creationOfMerchantWallet(string memory ID, uint balance) public {
    balancesBusiness[ID] = wallet("business", true, ID, balance,0);
  }

  function transfertToBusiness(string memory personalID, string memory businessID, uint amount) public {
    if(balancesUsers[personalID].balance >= amount){
      balancesUsers[personalID].balance -= amount;
      balancesBusiness[businessID].balance += amount;
    }
  }

  function transfertToTax(string memory personalID, uint amount) public {
    if(balancesBusiness[personalID].isInitiated == true && balancesBusiness[personalID].balance >= amount){
      balancesBusiness[personalID].balance -= amount;
      balancesBusiness[personalID].sentToTax += amount;
    }
  }


  function returntestValue (uint testValue) public view returns(uint) {
    		return testValue;
  }
  */

