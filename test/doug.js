var Doug = artifacts.require("./Doug.sol");
var DougEnabled = artifacts.require("./DougEnabled.sol");
var expect = require("chai").expect;


contract('Doug', function(accounts) {
  let doug_enabled;
  let doug;

  beforeEach('setup test doug and doug_enabled object', async function () {
    doug = await Doug.deployed();
    doug_enabled = await DougEnabled.deployed();
  });

  describe("addContract", function() {
    it("should add dougEnabled contract", async function() {
      await doug.addContract("test", doug_enabled.address);
      let received_address = await doug.getContract("test");
      expect(received_address).to.equal(doug_enabled.address);
    });

    it("should not changed dougEnabled contract", async function () {
      await doug.addContract("test", doug_enabled.address);
      let result = await doug.addContract("test", doug_enabled.address, {from: accounts[4]});
      expect(result.logs[0].args.statusCode.c[0]).to.equal(101);
    });
  });

  describe("removeContract", function() {
    it("should remove dougEnabled contract", async function() {
      await doug.addContract("test", doug_enabled.address);
      await doug.removeContract("test");
      expect(await doug.getContract.call("test")).to.equal("0x0000000000000000000000000000000000000000");
    });

    it("should not remove dougEnabled contract", async function () {
      await doug.addContract("test", doug_enabled.address);
      let result = await doug.removeContract("test", {from: accounts[4]});
      expect(result.logs[0].args.statusCode.c[0]).to.equal(101);
    });
  })
});
