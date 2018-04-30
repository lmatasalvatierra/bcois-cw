var Doug = artifacts.require("./Doug.sol");
var DataHelper = artifacts.require("./libraries/DataHelper.sol");
var DougEnabled = artifacts.require("./DougEnabled.sol");
var CoiDB = artifacts.require("./databases/CoiDB.sol");
var Coi = artifacts.require("./controllers/Coi.sol");
var COIManager = artifacts.require("./COIManager.sol");
var Permission = artifacts.require("./controllers/Permission.sol");
var PermissionDB = artifacts.require("./databases/PermissionDB.sol");
var DateTime = artifacts.require("./libraries/DateTime.sol");
var User = artifacts.require("./controllers/User.sol");
var OwnerDB = artifacts.require("./databases/OwnerDB.sol");
var Policy = artifacts.require("./controllers/Policy.sol");
var PolicyDB = artifacts.require("./databases/PolicyDB.sol");
var CarrierDB = artifacts.require("./databases/CarrierDB.sol");
var BrokerDB = artifacts.require("./databases/BrokerDB.sol");
var stringsUtil = artifacts.require("./libraries/stringsUtil.sol");
var UserManager = artifacts.require("./managers/UserManager.sol");



module.exports = function(deployer) {
  deployer.deploy(Doug);
  deployer.deploy(DataHelper);
  deployer.deploy(DougEnabled);
  deployer.deploy(DateTime);
  deployer.link(DateTime, CoiDB);
  deployer.link(DateTime, PolicyDB);
  deployer.deploy(CoiDB);
  deployer.deploy(Coi);
  deployer.deploy(stringsUtil);
  deployer.link(stringsUtil, COIManager);
  deployer.deploy(COIManager);
  deployer.deploy(Permission);
  deployer.deploy(PermissionDB);
  deployer.deploy(User);
  deployer.deploy(OwnerDB);
  deployer.deploy(Policy);
  deployer.deploy(PolicyDB);
  deployer.deploy(CarrierDB);
  deployer.deploy(BrokerDB);
  deployer.deploy(UserManager);
};
