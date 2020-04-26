pragma solidity ^0.6.3;

contract HelicopterMoney{
  mapping(string => uint256) balancesUsers;
  mapping(string => uint256) balancesMerchants;


  constructor() public HelicopterMoney(name, decimals, gateKeeper){

  }

  function creationOfIndividualWallet(string ID, uint balance){
    balancesUsers[ID] = balance;
  }

  function creationOfMerchantWallet(string ID, uint balance){
    balancesMerchants[ID] = balance;
  }

  function transferTo



}
