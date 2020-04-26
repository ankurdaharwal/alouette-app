
import {createPermission, grantPermission} from '@settlemint/enteth-migration-utils';
import {deployERC20TokenSystem} from '@settlemint/enteth-migration-utils';


import {
  HelicopterTokenFactoryContract,
  HelicopterTokenRegistryContract,
  HelicopterTokenContract,
  GateKeeperContract,
  AdminRoleRegistryContract,
  UserRoleRegistryContract,
} from '../types/truffle-contracts';

const HelicopterTokenFactory: HelicopterTokenFactoryContract = artifacts.require('HelicopterTokenFactory');
const HelicopterTokenRegistry: HelicopterTokenRegistryContract = artifacts.require('HelicopterTokenRegistry');
const HelicopterToken: HelicopterTokenContract = artifacts.require('HelicopterToken');
const GateKeeper: GateKeeperContract = artifacts.require('GateKeeper');

// tslint:disable-next-line:no-require-imports no-var-requires
const {enabledFeatures,storeIpfsHash} = require('../../truffle-config.js');

module.exports = async (deployer: Truffle.Deployer, network: string, accounts: string[]) => {
  if (enabledFeatures().includes('HELICO')) {
    console.log("BOUH");
    const gateKeeper = await GateKeeper.deployed();

    // Bonds
    await deployer.deploy(HelicopterTokenRegistry, gateKeeper.address);
    const AdminRoleRegistry: AdminRoleRegistryContract = artifacts.require('AdminRoleRegistry');
    const UserRoleRegistry: UserRoleRegistryContract = artifacts.require('UserRoleRegistry');
    const helicopterTokenRegistry = await HelicopterTokenRegistry.deployed();
    await createPermission(gateKeeper, helicopterTokenRegistry, 'LIST_TOKEN_ROLE', accounts[0], accounts[0]);
    await deployer.deploy(HelicopterTokenFactory, helicopterTokenRegistry.address, gateKeeper.address);
    const helicopterTokenFactory = await HelicopterTokenFactory.deployed();
    await createPermission(gateKeeper, helicopterTokenFactory, 'CREATE_TOKEN_ROLE', accounts[0], accounts[0]);
    await grantPermission(gateKeeper, helicopterTokenRegistry, 'LIST_TOKEN_ROLE', helicopterTokenFactory.address);
    await grantPermission(gateKeeper, gateKeeper, 'CREATE_PERMISSIONS_ROLE', helicopterTokenFactory.address);
    await createPermission(gateKeeper, helicopterTokenFactory, 'UPDATE_UIFIELDDEFINITIONS_ROLE', accounts[0], accounts[0]);

    // two dirs up, because it is compiled into ./dist/migrations
    // tslint:disable-next-line: no-require-imports
    const uiDefinitions = require('../../contracts/helicopter/UIDefinitions.json');
    const hash = await storeIpfsHash(uiDefinitions);
    await helicopterTokenFactory.setUIFieldDefinitionsHash(hash);

    await deployERC20TokenSystem(
      {
        gatekeeper: gateKeeper,
        registry: {contract: HelicopterTokenRegistry, extraParams: []},
        factory: {contract: HelicopterTokenFactory, extraParams: []},
        token: {
          contract: HelicopterToken,
          instances: [
            {
              name: 'BOUH',
              decimals: 2,
              extraParams: [],
              issuance: [
                {
                  recipientGroups: [AdminRoleRegistry, UserRoleRegistry],
                  amount: 10000,
                },
              ],
            },
          ],
        },
        roles: [AdminRoleRegistry],
      },
      accounts[0],
      uiDefinitions,
      deployer,
      storeIpfsHash
    );
  }
};
