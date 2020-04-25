pragma solidity ^0.6.3;

contract HelicopterMoney{
  struct wallet{
    string typeOfuser; 
    bool isInitiated;
    string ID;
    uint balance;
    uint sentToTax;
  }
  
  mapping(string => wallet) balancesUsers; //int256
  mapping(string => wallet) balancesBusiness;


  constructor() public{

  }

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

}
