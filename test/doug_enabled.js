var DougEnabled = artifacts.require("./DougEnabled.sol");
var expect = require("chai").expect;


contract('DougEnabled', function(accounts) {
  let doug_enabled;

  beforeEach('setup test doug and doug_enabled object', async function () {
    doug_enabled = await DougEnabled.deployed();
  });

  describe("setDougAddress", function() {
    it("should set given address", async function() {
      await doug_enabled.setDougAddress(accounts[1]);
      expect(await doug_enabled.DOUG()).to.equal(accounts[1]);
    });

    it("should not set and already set address", async function () {
      await doug_enabled.setDougAddress(accounts[1]);
      let result = await doug_enabled.setDougAddress(accounts[1]);
      expect(result.logs[0].args.statusCode.c[0], 404);
    });
  });
});
