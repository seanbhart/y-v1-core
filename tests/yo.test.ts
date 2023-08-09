import { expect } from "chai";
import ethers from "ethers";
import { ethers as hhethers } from "hardhat";

import { Y, Y__factory, Yo, Yo__factory } from "../types";

const devKey = process.env.ACCOUNT_KEY_PRIV_ACCT3;

describe("Yo Contract", function () {
  const provider = hhethers.provider;
  let yContract: Y;
  let yoContract: Yo;
  let ownerAddr: string;
  let ownerSigner: ethers.Signer;

  before(async function () {
    // Create the owner wallet
    if (!devKey) {
      return;
    }
    const wallet = new hhethers.Wallet(devKey, provider);
    expect(wallet, "No wallet").to.exist;
    ownerAddr = wallet.address;
    ownerSigner = await provider.getSigner(ownerAddr);
    console.log("ownerAddr", ownerAddr);

    yContract = await new Y__factory(ownerSigner).deploy(ownerAddr);
    console.log("Y contract target:", yContract.target);
    yoContract = await new Yo__factory(ownerSigner).deploy();
    console.log("Yo contract target:", yoContract.target);
  });

  describe("Yeet", function () {
    it("Should delegatecall yeet", async function () {
      const text = "hello there";
      // first format the data using the module
      const data = await yoContract.serialize(text);
      const tx = await yContract.yeet(yoContract.target, data);
      await tx.wait();
      // expect(0).to.equal(0);

      // The contract will emit an event when the yo is yeeted
      // We can get the event logs with the `getFilter` method
      const filter = yContract.filters.Yeeted(ownerAddr);
      const logs = await yContract.queryFilter(filter);
      console.log("logs", logs);
      expect(logs.length).to.equal(1);

      // deserialize the event data
      const eventData = logs[0].args?.data;
      const eventText = await yoContract.deserialize(eventData);
      console.log("eventText", eventText);
      const eventTimestamp = logs[0].args?.timestamp;
      console.log("eventTimestamp", eventTimestamp);
      expect(eventText).to.equal(text);

      // check that the event data matches the stored data
      // const refAddress = yoContract.target.toString().toLowerCase();
      const refAddress = logs[0].args?.ref;
      console.log("refAddress", refAddress);
      expect(refAddress).to.equal(yoContract.target);
      const ySavedData = await yContract.me(refAddress, "yeet", eventTimestamp);
      console.log("yContract savedData", ySavedData);
      const yoSavedData = await yoContract.me(refAddress, "yeet", eventTimestamp);
      console.log("yoContract savedData", yoSavedData);
      expect(yoSavedData).to.equal(eventData);

      // expect(logs[0].args?.timestamp).to.equal(timestamp);
      // const logText = logs[0].args?.text;
      // const logTimestamp = logs[0].args?.timestamp;
      // console.log("logText", logText);
      // console.log("logTimestamp", logTimestamp);
      // expect(logText).to.equal(text);
    });
  });

  // describe("YeetOld", function () {
  //   it("Should allow a user to write a Yo", async function () {
  //     const text = "hello there";
  //     await yoContract.yeet(yContract.target, text);
  //     // const result = await yoContract.read(yContract.target, ethers.toBigInt(Date.now()));
  //     // expect(result).to.equal(text);
  //     expect(0).to.equal(0);
  //   });
  // });
});
