import { expect } from "chai";
import { Signer } from "ethers";
import { ethers } from "hardhat";

import { Y, Y__factory, Yo, Yo__factory } from "../types";

const devKey = process.env.ACCOUNT_KEY_PRIV_ACCT3;

describe("Yo Contract", function () {
  let yContract: Y;
  let yoContract: Yo;
  let ownerAddr: string;
  let otherAddr: string;
  let signer: Signer;

  before(async function () {
    const provider = new ethers.JsonRpcProvider();
    expect(devKey, "No dev key").to.exist;

    if (!devKey) {
      return;
    }
    // Create the owner wallet
    const wallet = new ethers.Wallet(devKey, provider);
    expect(wallet, "No wallet").to.exist;
    signer = await ethers.provider.getSigner(wallet.address);
    ownerAddr = wallet.address;
    console.log("ownerAddr", ownerAddr);

    // Create another wallet
    const wallet2 = ethers.Wallet.createRandom();
    expect(wallet2, "No wallet2").to.exist;
    otherAddr = wallet2.address;
    console.log("otherAddr", otherAddr);

    yContract = await new Y__factory(signer).deploy(ownerAddr);
    yoContract = await new Yo__factory(signer).deploy();
    console.log("Yo contract target:", yoContract.target);
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await yContract.isOwner(ownerAddr)).to.equal(true);
    });

    it("Should not set non-owners as owner", async function () {
      expect(await yContract.isOwner(otherAddr)).to.equal(false);
    });
  });

  describe("Modules", function () {
    it("Should allow owner to add a module", async function () {
      await yContract.addModule(yoContract.target);
      expect(await yContract.modules(0)).to.equal(yoContract.target);
    });

    it("Should emit event when module is added", async function () {
      await expect(yContract.addModule(yoContract.target))
        .to.emit(yContract, "ModuleAdded")
        .withArgs(yoContract.target);
    });

    // TODO: test that non-owners cannot add modules
  });
});
