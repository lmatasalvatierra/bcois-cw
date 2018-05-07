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

contract('COIManager', function(accounts) {
  var doug, manager, coi, coiDb, user, ownerdb, policy, policydb, carriedb;
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
    await manager.createOwner(web3.fromAscii("CertificateTest@cosa.com"), "admin", web3.fromAscii("cosa"), web3.fromAscii("Alcala 21"));
    await manager.createPolicy(web3.fromAscii("CertificateTest@cosa.com"), web3.fromAscii("Workers Comp"), timeNow, oneYearFromNow, 1);
    await manager.createPolicy(web3.fromAscii("CertificateTest@cosa.com"), web3.fromAscii("Business Owners Policy"), timeNow, oneYearFromNow, 1);
  });

  describe("Certificate", function() {
    it("should create COI with given details", async function() {
      const certificate = await manager.createCoi("CertificateTest@cosa.com", timeNow, 3, [1, 2]);
      expect(certificate.logs[0].args.certificateNumber.toNumber()).to.equal(1);
      expect(web3.toAscii(certificate.logs[0].args.ownerEmail)).to.include("CertificateTest@cosa.com");
      expect(web3.toAscii(certificate.logs[0].args.ownerName)).to.include("cosa");
      expect(certificate.logs[0].args.effectiveDate.toNumber()).to.equal(timeNow);
    });

    it("get values of certificate", async function() {
      await manager.createCoi("CertificateTest@cosa.com", timeNow, 3, [1, 2]);
      let values = await manager.getCoi(1);
      expect(values[0].toNumber()).to.equal(1);
      expect(web3.toAscii(values[1])).to.include("CertificateTest@cosa.com")
      expect(web3.toAscii(values[2])).to.include("cosa");
      expect(values[3].toNumber()).to.equal(timeNow)
      expect(JSON.parse(values[4]).length).to.equal(2);
    });

    it("should reject creation of certificate with cancelled policy", async function() {
      await manager.createPolicy(web3.fromAscii("CertificateTest@cosa.com"), web3.fromAscii("General Liability"), timeNow, oneYearFromNow, 1);
      await manager.cancelPolicy(3);
      try {
        await manager.createCoi("CertificateTest@cosa.com", timeNow, 3, [3]);
      } catch (err) {
        expect(err.message).to.include("VM Exception while processing transaction: revert");
      }
    });
  });
});
