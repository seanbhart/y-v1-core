import { expect } from "chai";
import ethers from "ethers";
import { ethers as hhethers } from "hardhat";

import { Y } from "../../types/contracts/logged";
import { Yo } from "../../types/contracts/logged";
import { Y__factory } from "../../types/factories/contracts/logged";
import { Yo__factory } from "../../types/factories/contracts/logged";

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

  describe("Yo", function () {
    it("Should delegatecall yeet", async function () {
      const text = "hello there";
      // first format the data using the module
      // const data = await yeetContract.yeetize(text);
      const data = await yoContract.serialize(text);
      const tx = await yContract.yeet(yoContract.target, data);
      const receipt = await tx.wait();
      if (!receipt) {
        throw new Error("No receipt");
      }

      // The contract will emit an event when the yo is yeeted
      // We can get the event logs with the `getFilter` method
      const filter = yContract.filters.Yeeted(yContract.target);
      const logs = await yContract.queryFilter(filter);
      expect(logs.length).to.equal(1);

      // deserialize the event data
      const eventData = logs[0].args?.data;
      const eventYeetArray = await yoContract.deserialize(eventData);
      const eventYeet = {
        y: eventYeetArray[0],
        username: eventYeetArray[1],
        avatar: eventYeetArray[2],
        timestamp: eventYeetArray[3],
        text: eventYeetArray[4],
      };
      console.log("eventYeet", eventYeet);
      const eventTimestamp = eventYeet.timestamp;
      console.log("eventTimestamp", eventTimestamp);
      expect(eventYeet.text).to.equal(text);

      // check that the event data hash matches the stored hash
      const block = await hhethers.provider.getBlock(receipt.blockNumber);
      if (!block) {
        throw new Error("Unable to retrieve block");
      }
      // hash the event data
      const hash = hhethers.solidityPackedKeccak256(
        ["uint", "address", "string", "string", "uint256", "string"],
        [receipt.blockNumber, eventYeet.y, eventYeet.username, eventYeet.avatar, block.timestamp, eventYeet.text],
      );
      expect(await yContract.find(hash)).to.equal(true);
    });
  });
});
