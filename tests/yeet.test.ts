import { expect } from "chai";
import ethers from "ethers";
import { ethers as hhethers } from "hardhat";

import { Yeet, Yeet__factory, Yo, Yo__factory } from "../types";

const devKey = process.env.ACCOUNT_KEY_PRIV_DEV04;

describe("Yeet Contract", function () {
  const provider = hhethers.provider;
  let yeetContract: Yeet;
  let yoContract: Yo;
  let ownerAddr: string;
  let ownerSigner: ethers.Signer;

  before(async function () {
    if (!devKey) {
      return;
    }
    const wallet = new hhethers.Wallet(devKey, provider);
    expect(wallet, "No wallet").to.exist;
    ownerAddr = wallet.address;
    ownerSigner = await provider.getSigner(ownerAddr);
    console.log("ownerAddr", ownerAddr);

    yeetContract = await new Yeet__factory(ownerSigner).deploy();
    console.log("Yeet contract target:", yeetContract.target);

    yoContract = await new Yo__factory(ownerSigner).deploy();
    console.log("Yo contract target:", yoContract.target);
  });

  describe("Events", function () {
    it("Should emit uint", async function () {
      const value = 111;
      const tx = await yeetContract.logUint(value);
      const receipt = await tx.wait();
      if (!receipt) {
        throw new Error("No receipt");
      }

      const filter = yeetContract.filters.LogUint();
      const logs = await yeetContract.queryFilter(filter);
      expect(logs.length).to.equal(1);

      // deserialize the event data
      const logValue = logs[logs.length - 1].args?.value;
      console.log("uint| logValue", logValue);
      expect(logValue).to.equal(value);

      // find the hash
      if (!receipt.blockNumber) {
        throw new Error("No block number");
      }
      const hash = hhethers.solidityPackedKeccak256(["uint", "uint256"], [receipt.blockNumber, value]);
      console.log("uint| hash", hash);
      expect(await yeetContract.findYeet(hash)).to.equal(true);
    });

    it("Should emit string", async function () {
      const value = "hello there";
      const tx = await yeetContract.logString(value);
      const receipt = await tx.wait();
      if (!receipt) {
        throw new Error("No receipt");
      }

      const filter = yeetContract.filters.LogString();
      const logs = await yeetContract.queryFilter(filter);
      expect(logs.length).to.equal(1);

      // deserialize the event data
      const logValue = logs[logs.length - 1].args?.value;
      console.log("string| logValue", logValue);
      expect(logValue).to.equal(value);

      // find the hash
      if (!receipt.blockNumber) {
        throw new Error("No block number");
      }
      const hash = hhethers.solidityPackedKeccak256(["uint", "string"], [receipt.blockNumber, value]);
      console.log("string| hash", hash);
      expect(await yeetContract.findYeet(hash)).to.equal(true);
    });

    it("Should emit bytes", async function () {
      const value = "hello there";
      const yoYeetBytes = await yoContract.serialize(value);
      const tx = await yeetContract.logBytes(yoYeetBytes);
      const receipt = await tx.wait();
      if (!receipt) {
        throw new Error("No receipt");
      }

      const filter = yeetContract.filters.LogBytes();
      const logs = await yeetContract.queryFilter(filter);
      expect(logs.length).to.equal(1);

      // deserialize the event data
      const logValue = logs[logs.length - 1].args?.value;
      console.log("bytes| logValue", logValue);
      expect(logValue).to.equal(yoYeetBytes);

      // find the hash
      if (!receipt.blockNumber) {
        throw new Error("No block number");
      }
      const hash = hhethers.solidityPackedKeccak256(["uint", "bytes"], [receipt.blockNumber, yoYeetBytes]);
      console.log("bytes| hash", hash);
      expect(await yeetContract.findYeet(hash)).to.equal(true);
    });

    it("Should emit YoYeet", async function () {
      const value = "hello there";
      const tx = await yeetContract.logYoYeet(value);
      const receipt = await tx.wait();
      if (!receipt) {
        throw new Error("No receipt");
      }

      const filter = yeetContract.filters.LogYoYeet();
      const logs = await yeetContract.queryFilter(filter);
      expect(logs.length).to.equal(1);

      // deserialize the event data
      const logValue = logs[logs.length - 1].args?.value;
      console.log("YoYeet| logValue", logValue);
      const yeetExpected = await yeetContract.yeetize(value);
      expect(logValue).to.deep.equal(yeetExpected);

      // find the hash
      if (!receipt.blockNumber) {
        throw new Error("No block number");
      }
      const block = await hhethers.provider.getBlock(receipt.blockNumber);
      if (!block) {
        throw new Error("Unable to retrieve block");
      }
      const hash = hhethers.solidityPackedKeccak256(
        ["uint", "address", "string", "string", "uint256", "string"],
        [
          receipt.blockNumber,
          yeetExpected.y,
          yeetExpected.username,
          yeetExpected.avatar,
          block.timestamp,
          yeetExpected.text,
        ],
      );
      console.log("YoYeet| hash", hash);
      expect(await yeetContract.findYeet(hash)).to.equal(true);
    });

    it("Should emit expensive YoYeet", async function () {
      const value = "hello there";
      const tx = await yeetContract.logYoYeetExpensive(value);
      const receipt = await tx.wait();
      if (!receipt) {
        throw new Error("No receipt");
      }

      const filter = yeetContract.filters.LogYoYeet();
      const logs = await yeetContract.queryFilter(filter);
      expect(logs.length).to.gt(1);

      // deserialize the event data
      const logValue = logs[logs.length - 1].args?.value;
      console.log("YoYeetExpensive| logValue", logValue);
      const yeetExpected = await yeetContract.yeetize(value);
      expect(logValue).to.deep.equal(yeetExpected);

      // find the hash
      if (!receipt.blockNumber) {
        throw new Error("No block number");
      }
      const block = await hhethers.provider.getBlock(receipt.blockNumber);
      if (!block) {
        throw new Error("Unable to retrieve block");
      }
      const yoHash = hhethers.solidityPackedKeccak256(
        ["address", "string", "string", "uint256", "string"],
        [yeetExpected.y, yeetExpected.username, yeetExpected.avatar, block.timestamp, yeetExpected.text],
      );
      const hash = hhethers.solidityPackedKeccak256(["uint", "bytes"], [receipt.blockNumber, yoHash]);
      console.log("YoYeetExpensive| hash", hash);
      expect(await yeetContract.findYeet(hash)).to.equal(true);
    });
  });
});
