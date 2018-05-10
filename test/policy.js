var Doug = artifacts.require("./Doug.sol");
var DataHelper = artifacts.require("./libraries/DataHelper.sol");
var DougEnabled = artifacts.require("./DougEnabled.sol");
var CoiDB = artifacts.require("./databases/CoiDB.sol");
var Coi = artifacts.require("./controllers/Coi.sol");
var COIManager = artifacts.require("./COIManager.sol");
var DateTime = artifacts.require("./libraries/DateTime.sol");
var User = artifacts.require("./controllers/User.sol");
var OwnerDB = artifacts.require("./databases/OwnerDB.sol");
var Policy = artifacts.require("./controllers/Policy.sol");
var PolicyDB = artifacts.require("./databases/PolicyDB.sol");
var CarrierDB = artifacts.require("./databases/CarrierDB.sol");
var BrokerDB = artifacts.require("./databases/BrokerDB.sol");
var stringsUtil = artifacts.require("./libraries/stringsUtil.sol");
var expect = require("chai").expect;
const uuidv4 = require('uuid/v4');
const uuidToHex = require('uuid-to-hex');
const hexToUuid = require('hex-to-uuid');

contract('COIManager', function(accounts) {
  var doug, manager, coi, coiDb, user, ownerdb, policy, policydb, carriedb;
  let timeNow = Math.floor(Date.now() / 1000);
  let oneYearFromNow = timeNow + 31556926;
  let agency = accounts[1];
  let owner = accounts[2];
  let guest = accounts[6];
  const uuid = uuidv4();
  const policyUUID = uuidToHex(uuid, true);

  beforeEach('setup manager', async function () {
    doug = await Doug.new();
    manager = await COIManager.new();
    coi = await Coi.new();
    coiDb = await CoiDB.new();
    user = await User.new();
    ownerdb = await OwnerDB.new();
    policy = await Policy.new();
    policydb = await PolicyDB.new();
    carrierdb = await CarrierDB.new();

    await doug.addContract("coiManager", manager.address);
    await doug.addContract("coi", coi.address);
    await doug.addContract("coiDB", coiDb.address);
    await doug.addContract("user", user.address);
    await doug.addContract("ownerDB", ownerdb.address);
    await doug.addContract("policy", policy.address);
    await doug.addContract("policyDB", policydb.address);
    await doug.addContract("carrierDB", carrierdb.address);

    await manager.createCarrier(web3.fromAscii("TestCreation@Carrier.com"), "admin", web3.fromAscii("CNA"));
    await manager.createCarrier(web3.fromAscii("TestSTARR@Carrier.com"), "admin", web3.fromAscii("STARR"));
    await manager.createOwner(web3.fromAscii("Hola@cosa.com"), "admin", web3.fromAscii("cosa"), web3.fromAscii("Alcala 21"));
    await manager.createPolicy(web3.fromAscii("Hola@cosa.com"), web3.fromAscii("Workers Comp"), timeNow, oneYearFromNow, 1, policyUUID);
  });

  describe("Policy", function() {
    it("should create a policy with given values", async function() {
      const result = await manager.createPolicy(web3.fromAscii("Hola@cosa.com"), web3.fromAscii("General Liability"), timeNow, oneYearFromNow, 1, policyUUID);
      expect(result.logs[0].args.status.toNumber()).to.equal(0);
      expect(web3.toAscii(result.logs[0].args.insuranceType)).to.include("General Liability");
      expect(result.logs[0].args.ownerId.toNumber()).to.equal(3);
      expect(result.logs[0].args.effectiveDate.toNumber()).to.equal(timeNow);
      expect(result.logs[0].args.expirationDate.toNumber()).to.equal(oneYearFromNow);
      expect(web3.toAscii(result.logs[0].args.ownerEmail)).to.include("Hola@cosa.com");
      expect(hexToUuid(result.logs[0].args.policyUUID)).to.include(uuid);
    });

    it("should get a Policy", async function() {
      let result = await manager.getPolicy.call(policyUUID);
      const policy = JSON.parse(result);
      expect("0x" + policy.policy_uuid).to.equal(policyUUID);
      expect(policy.insurance_type).to.include("Workers Comp");
      expect(parseInt(policy.status)).to.equal(0);
      expect(parseInt(policy.effective_date)).to.equal(timeNow);
      expect(parseInt(policy.expiration_date)).to.equal(oneYearFromNow);
      expect(policy.user_email).to.include("Hola@cosa.com");
      expect(policy.owner_name).to.include("cosa");
      expect(policy.address).to.include("Alcala 21");
    });

    it("should reject call of getting a policy because doesn't exist", async function() {
      try {
        let result = await manager.getPolicy(2);
      } catch (err) {
        expect(err.message).to.include("VM Exception while processing transaction: revert");
      }
    });

    it("should cancel a Policy", async function() {
      const response = await manager.cancelPolicy(policyUUID);
      expect(response.logs[0].args.policyUUID).to.include(policyUUID);
      expect(response.logs[0].args.status.toNumber()).to.equal(1);
    });

    it("should change a Policy state to expired", async function() {
      let oneYearBeforeNow = timeNow - 31556926;
      let oneDayBeforeNow = timeNow - 86400;
      const policy1UUID = uuidToHex(uuidv4(), true);
      await manager.createPolicy(web3.fromAscii("Hola@cosa.com"), web3.fromAscii("BOP"), oneYearBeforeNow, oneDayBeforeNow, 1, policy1UUID);
      await manager.changePolicyToExpired();

      let response = await manager.getPolicy.call(policy1UUID);
      const policy = JSON.parse(response);
      expect(+policy.status).to.equal(2);
    });

    it("should get policies of a carrier", async function() {
      const policy1UUID = uuidToHex(uuidv4(), true);
      const policy2UUID = uuidToHex(uuidv4(), true);
      await manager.createPolicy(web3.fromAscii("Hola@cosa.com"), web3.fromAscii("BOP"), timeNow, oneYearFromNow, 1, policy1UUID);
      await manager.createPolicy(web3.fromAscii("Hola@cosa.com"), web3.fromAscii("GEneral Liability"), timeNow, oneYearFromNow, 1, policy2UUID);
      const response = await manager.getPoliciesOfCarrier(1);
      const policies = JSON.parse(response);
      expect(policies.length).to.equal(3);
    });
  });
});
