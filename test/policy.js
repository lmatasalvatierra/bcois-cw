var Permission = artifacts.require("./Permission.sol");
var PermissionDB = artifacts.require("./PermissionDB.sol");
var COIManager = artifacts.require("./COIManager.sol");
var Coi = artifacts.require("./Coi.sol");
var Doug = artifacts.require("./Doug.sol");
var CoiDB = artifacts.require("./CoiDB.sol");
var User = artifacts.require("./User.sol");
var Policy = artifacts.require("./Policy.sol");
var OwnerDB = artifacts.require("./OwnerDB.sol");
var PolicyDB = artifacts.require("./PolicyDB.sol");
var CarrierDB = artifacts.require("./CarrierDB.sol");
var expect = require("chai").expect;

contract('COIManager', function(accounts) {
  var doug, manager, coi, coiDb, perm, permdb, user, ownerdb, policy, policydb, carriedb;
  let timeNow = Math.floor(Date.now() / 1000);
  let oneYearFromNow = timeNow + 31556926;
  let agency = accounts[1];
  let owner = accounts[2];
  let guest = accounts[6];

  beforeEach('setup manager', async function () {
    doug = await Doug.new();
    manager = await COIManager.new();
    coi = await Coi.new();
    coiDb = await CoiDB.new();
    perm = await Permission.new();
    permdb = await PermissionDB.new();
    user = await User.new();
    ownerdb = await OwnerDB.new();
    policy = await Policy.new();
    policydb = await PolicyDB.new();
    carrierdb = await CarrierDB.new();

    await doug.addContract("coiManager", manager.address);
    await doug.addContract("coi", coi.address);
    await doug.addContract("coiDB", coiDb.address);
    await doug.addContract("perm", perm.address);
    await doug.addContract("permDB", permdb.address);
    await doug.addContract("user", user.address);
    await doug.addContract("ownerDB", ownerdb.address);
    await doug.addContract("policy", policy.address);
    await doug.addContract("policyDB", policydb.address);
    await doug.addContract("carrierDB", carrierdb.address);

    await manager.createCarrier(web3.fromAscii("TestCreation@Carrier.com"), "admin", web3.fromAscii("CNA"));
    await manager.createOwner(web3.fromAscii("Hola@cosa.com"), "admin", web3.fromAscii("cosa"), web3.fromAscii("Alcala 21"));
    await manager.createPolicy(web3.fromAscii("Hola@cosa.com"), web3.fromAscii("Workers Comp"), timeNow, oneYearFromNow, 1);
  });

  describe("Policy", function() {
    it("should get a Policy", async function() {
      let result = await manager.getPolicy(1);
      policy = JSON.parse(result);
      expect(parseInt(policy.policy_number)).to.equal(1);
      expect(policy.insurance_type).to.include("Workers Comp");
      expect(parseInt(policy.status)).to.equal(0);
      expect(parseInt(policy.effective_date)).to.equal(timeNow);
      expect(parseInt(policy.expiration_date)).to.equal(oneYearFromNow);
      expect(policy.user_email).to.include("Hola@cosa.com");
      expect(policy.owner_name).to.include("cosa");
      expect(policy.address).to.include("Alcala 21");
    });

    it("should reject call of getting a policy", async function() {
      try {
        let result = await manager.getPolicy(2);
      } catch (err) {
        expect(err.message).to.include("VM Exception while processing transaction: revert");
      }
    });

    it("should cancel a Policy", async function() {
      await manager.cancelPolicy(1);
      let isCanceled = await manager.getPolicyStatus(1);
      // Cancelled status = 1
      expect(isCanceled.toNumber()).to.equal(1);
    });

    it("should change a Policy state to expired", async function() {
      let oneYearBeforeNow = timeNow - 31556926;
      let oneDayBeforeNow = timeNow - 86400;
      await manager.createPolicy(web3.fromAscii("Hola@cosa.com"), web3.fromAscii("BOP"), oneYearBeforeNow, oneDayBeforeNow, 1);
      await manager.changePolicyToExpired();

      let status = await manager.getPolicyStatus(2);
      expect(status.toNumber()).to.equal(2);
    });
  });
});
