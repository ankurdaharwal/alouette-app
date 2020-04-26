/**
 * Copyright (C) SettleMint NV - All Rights Reserved
 *
 * Use of this file is strictly prohibited without an active license agreement.
 * Distribution of this file, via any medium, is strictly prohibited.
 *
 * For license inquiries, contact hello@settlemint.com
 */

pragma solidity ^0.6.3;

import '@settlemint/enteth-contracts/contracts/tokens/ERC20/ERC20Token.sol';

/**
 * @title Fungible coin without restrictions
 */
contract HelicopterToken is ERC20Token {

  struct Wallet{
    bytes32 numIDCard;
    bytes32 numCompany;
    uint256 balance; // balance in € * 100
    uint256 sentToTax;
    bool exists; // so easy to check if a wallet exists
    address walletAddress;
  }

  mapping(address => Wallet) citizensWallets;
  mapping(address => Wallet) companiesWallets;

  address[] listCitizensWallets;
  address[] listCompaniesWallets;

  constructor(string memory name, address gateKeeper, string memory uiFieldDefinitionsHash)
    public
    ERC20Token(name, 2, gateKeeper, uiFieldDefinitionsHash)
  {}

  bytes32 public constant EDIT_ROLE = 'EDIT_ROLE';
  bytes32 public constant ROLE_ADMIN = 'ROLE_ADMIN';
  bytes32 public constant ROLE_USER = 'ROLE_USER';
  bytes32 public constant ROLE_MERCHANT = 'ROLE_MERCHANT';
  bytes32 public constant ROLE_TAX = 'ROLE_TAX';


  /**
   * @notice Update the currency's name and number of decimals
   * @dev Set new values for the currency's name and number of decimals. Restricted to users with "EDIT_ROLE" permissions
   * @param name bytes32 Updated name
   * @param decimals uint8 Updated decimals
   */
  function edit(string memory name, uint8 decimals) public auth(EDIT_ROLE) {
    _name = name;
    _decimals = decimals;
  }

  /**
   * @notice Returns the amount of tokenholders recorded in this contract
   * @dev Gets the amount of token holders, used by the middleware to build a cache you can query. You should not need this function in general since iteration this way clientside is very slow.
   * @return length An uint256 representing the amount of tokenholders recorded in this contract.
   */
  function getIndexLength() public view override returns (uint256 length) {
    length = tokenHolders.length;
  }

  /**
   * @notice Returns the address and balance of the tokenholder by index
   * @param index used to access the tokenHolders array
   * @return holder holder's address and balance
   */
  function getByIndex(uint256 index) public view returns (address holder, uint256 balance) {
    holder = tokenHolders[index];
    balance = balances[tokenHolders[index]].balance;
  }

  /**
   * @notice Returns the address and balance of the tokenholder by address
   * @param key used to access the token's balances
   * @return holder holder's address and balance
   */
  function getByKey(address key) public view returns (address holder, uint256 balance) {
    holder = key;
    balance = balances[key].balance;
  }

  /**
  * @notice Transfer Money to Business
  * @param businessAddress the address of the merchant
  * @param amount the amount that is transferred
   */
  function transferToMerchant(address businessAddress, uint256 amount) public{
    if(balances[msg.sender].balance >= amount){
      citizensWallets[msg.sender].balance -= amount;
      companiesWallets[businessAddress].balance += amount;
      super.transfer(businessAddress, amount);
    }
  }

  /**
  * @notice Transfer Money to Tax
  * @param taxAddress the address of the merchant
  * @param amount the amount that is transferred
   */
  function transferToTax(address taxAddress, uint amount) public {
    companiesWallets[msg.sender].balance -= amount;
    companiesWallets[msg.sender].sentToTax += amount;
    super.transfer(taxAddress, amount);
  }

  /**
  * @notice Create Waller for a company
   */
  function creationOfCompanyWallet(address companyAddress, bytes32 numCompany, uint256 balance) public auth(MINT_ROLE){
    // check already exists
    // check numCompany and verificationKey
    //require(canPerform(companyAddress, ROLE_MERCHANT));
    listCompaniesWallets.push(companyAddress);
    super.mint(companyAddress, balance);
    companiesWallets[companyAddress] = Wallet(
    {
      numIDCard: '',
      numCompany: numCompany,
      balance: balances[companyAddress].balance,
      sentToTax: 0,
      exists: true,
      walletAddress: companyAddress
    });
  }

  /**
  * @notice Create Waller for a citizen
   */
  function creationOfCitizenWallet(address citizenAddress, bytes32 numIDCard, uint256 balance) public auth(MINT_ROLE) {
    // check already exists
    // check numIDCard and verificationKey
    //require(canPerform(citizenAddress, ROLE_USER));
    listCitizensWallets.push(citizenAddress);
    super.mint(citizenAddress, balance);
    citizensWallets[citizenAddress] = Wallet(
    {
      numIDCard: numIDCard,
      numCompany: '',
      balance: balances[citizenAddress].balance,
      sentToTax: 0,
      exists: true,
      walletAddress: citizenAddress
    });
  }

  function mintToRoleRegistry(address roleRegistryAddress, uint256 amount)
      public
      override
      virtual
      authWithCustomReason(MINT_ROLE, 'Sender needs the MINT__ROLE')
      returns (bool success)
  {
    RoleRegistry roleRegistry = RoleRegistry(roleRegistryAddress);
    uint256 numberOfUsers = roleRegistry.getIndexLength();
    for (uint256 counter = 0; counter < numberOfUsers; counter++) {
      address holder;
      bool hasRole;
      (holder, hasRole) = roleRegistry.getByIndex(counter);
      if (hasRole) {
        citizensWallets[holder].balance += amount;
        super.mint(holder, amount);
      }
    }
    return true;
  }
}
