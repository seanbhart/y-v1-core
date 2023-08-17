import { expect } from "chai";
import ethers from "ethers";
import { ethers as hhethers } from "hardhat";

import { Y } from "../../types/contracts/stored";
import { Yo } from "../../types/contracts/stored";
import { Y__factory } from "../../types/factories/contracts/stored";
import { Yo__factory } from "../../types/factories/contracts/stored";

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
      // count the number of yeetstamps before the yeet
      const yeetstamps = await yContract.getYeetstamps(yoContract.target.toString());
      console.log("yeetstamps", yeetstamps);
      const yeetstampCount = yeetstamps.length;
      console.log("yeetstampCount", yeetstampCount);

      const text = "hello there";
      // first format the data using the module
      // const yeet = await yoContract.yeetize(text);
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
      // console.log("logs", logs);
      expect(logs.length).to.equal(1);

      // deserialize the event data
      const eventData = logs[0].args?.data;
      const eventText = await yoContract.deserialize(eventData);
      console.log("eventText", eventText.text);
      const eventTimestamp = logs[0].args?.timestamp;
      console.log("eventTimestamp", eventTimestamp);
      expect(eventText.text).to.equal(text);

      // check that the event data matches the stored data
      const ref = logs[0].args?.ref;
      console.log("ref", ref);
      expect(ref).to.equal(yoContract.target);
      const ySavedData = await yContract.me(ref, eventTimestamp);
      const ySavedYeet = await yoContract.deserialize(ySavedData);
      console.log("yContract ySavedYeet y, timestamp, text", ySavedYeet.y, ySavedYeet.timestamp, ySavedYeet.text);
      expect(ySavedYeet.text).to.equal(eventText.text);

      // check that the yeetstamp count has increased
      const yeetstamps2 = await yContract.getYeetstamps(yoContract.target.toString());
      console.log("yeetstamps2", yeetstamps2);
      const yeetstampCount2 = yeetstamps2.length;
      console.log("yeetstampCount2", yeetstampCount2);
      expect(yeetstampCount2).to.equal(yeetstampCount + 1);

      // check that the yeet for this Y contract has been saved
      const yeet = await yoContract.getYeet(yContract.target, eventTimestamp);
      console.log("yeet", yeet);
      expect(yeet.text).to.not.be.undefined;

      // check that the timestamp is in the list of timestamps
      const timestamps = await yoContract.getTimestamps();
      console.log("timestamps", timestamps);
      expect(timestamps).to.include(eventTimestamp);

      // read the Y contract data from the Yo contract
      const result = await yoContract.read(yContract.target, eventTimestamp);
      expect(result.text).to.equal(eventText.text);
    });
  });

  describe("Yeet HTML", function () {
    beforeEach(async () => {
      const text = "hello there";
      const data = await yoContract.serialize(text);
      const tx = await yContract.yeet(yoContract.target, data);
      await tx.wait();
    });

    it("should convert a Yeet struct to HTML string correctly", async () => {
      const timestamps = await yoContract.getTimestamps();
      if (timestamps.length === 0) {
        return;
      }
      const yeetHtml = await yoContract.getHtml(yContract.target, timestamps[0]);
      console.log("yeetHtml", yeetHtml);
      expect(yeetHtml).to.not.be.undefined;
      // expect(yeetHtml).to.equal('<div class="yeet"><div class="yeet-text">hello there</div></div>');
    });

    it("should return recent feed in HTML format correctly", async () => {
      const earliestTimestamp = 0;
      const htmlFeed = await yoContract.home(earliestTimestamp);
      console.log("htmlFeed", htmlFeed);
      expect(htmlFeed).to.not.be.undefined;
      // Assuming there are three yeets with text "hello there" in the feed
      // expect(htmlFeed).to.equal(
      //   '<div class="yeet-feed"><div class="yeet"><div class="yeet-text">hello there</div></div><div class="yeet"><div class="yeet-text">hello there</div></div><div class="yeet"><div class="yeet-text">hello there</div></div></div>',
      // );
    });
  });
});
