import { ethers as hhethers } from "hardhat";

import { Y, Y__factory, Yo, Yo__factory } from "../types";

const Y_ADDRESS = process.env.Y_ADDRESS_OPTIMISM;
const YO_ADDRESS = process.env.YO_ADDRESS_OPTIMISM;
const devKey = process.env.ACCOUNT_KEY_PRIV_DEV04;

async function main() {
  if (!Y_ADDRESS || !YO_ADDRESS || !devKey) {
    return;
  }
  console.log("Y_ADDRESS", Y_ADDRESS);
  console.log("YO_ADDRESS", YO_ADDRESS);

  const YFactory = (await hhethers.getContractFactory("Y")) as Y__factory;
  const YoFactory = (await hhethers.getContractFactory("Yo")) as Yo__factory;
  const yContract = YFactory.attach(Y_ADDRESS) as Y;
  const yoContract = YoFactory.attach(YO_ADDRESS) as Yo;

  // Check the contract using a read function
  const wallet = new hhethers.Wallet(devKey, hhethers.provider);
  const isOwner = await yContract.isOwner(wallet.address);
  console.log("isOwner", isOwner);
  const timestamps = await yoContract.getTimestamps();
  console.log("timestamps", timestamps);

  // Check modules
  let modules = await yContract.getModules();
  console.log("modules", modules);

  // Add a Module
  const tx = await yContract.removeModule("0xCC4411174928e021dD6306032FAd7B58b260ECf4");
  await tx.wait();

  // // // Use the text "hello there" in the serialize function to create bytes
  // // // const text = "hello there";
  // // const text =
  // //   'Satoshi Nakamoto\'s development of Bitcoin in 2009 has often been hailed as a radical development in money and currency, being the first example of a digital asset which simultaneously has no backing or "intrinsic value" and no centralized issuer or controller. However, another, a';
  // // const data = await yoContract.serialize(text);

  // // // Pass the bytes to the Y contract yeet function
  // // const yeetTx = await yContract.yeet(yoContract.target, data);
  // // await yeetTx.wait();

  // // // wait a few more seconds to ensure the events are indexed
  // // await new Promise((resolve) => setTimeout(resolve, 5000));

  // // The contract will emit an event when the yo is yeeted
  // // We can get the event logs with the `getFilter` method
  // const filter = yContract.filters.Yeeted(yContract.target);
  // const logs = await yContract.queryFilter(filter);
  // console.log("logs", logs);

  // // deserialize the event data
  // const eventData = logs[0].args?.data;
  // const eventText = await yoContract.deserialize(eventData);
  // console.log("eventText", eventText.text);
  // const eventTimestamp = logs[0].args?.timestamp;
  // console.log("eventTimestamp", eventTimestamp);

  // // check that the event data matches the stored data
  // const ref = logs[0].args?.ref;
  // console.log("ref", ref);
  // const ySavedData = await yContract.me(ref, eventTimestamp);
  // const ySavedYeet = await yoContract.deserialize(ySavedData);
  // console.log(
  //   "yContract ySavedYeet y, timestamp, text",
  //   ySavedYeet.y,
  //   ySavedYeet.timestamp,
  //   ySavedYeet.text,
  // );

  // // check that the yeetstamp count has increased
  // const yeetstamps2 = await yContract.getYeetstamps(yoContract.target.toString());
  // console.log("yeetstamps2", yeetstamps2);
  // const yeetstampCount2 = yeetstamps2.length;
  // console.log("yeetstampCount2", yeetstampCount2);

  // // check that the yeet for this Y contract has been saved
  // const yeet = await yoContract.getYeet(yContract.target, eventTimestamp);
  // console.log("yeet", yeet);

  // // check that the timestamp is in the list of timestamps
  // const _timestamps = await yoContract.getTimestamps();
  // console.log("timestamps", _timestamps);

  // // read the Y contract data from the Yo contract
  // const result = await yoContract.read(yContract.target, eventTimestamp);
  // console.log("result", result);

  // // HTML
  // const timestamps2 = await yoContract.getTimestamps();
  // if (timestamps2.length === 0) {
  //   return;
  // }
  // const yeetHtml = await yoContract.getHtml(yContract.target, timestamps2[0]);
  // console.log("yeetHtml", yeetHtml);

  // const earliestTimestamp = 0;
  // const htmlFeed = await yoContract.home(earliestTimestamp);
  // console.log("htmlFeed", htmlFeed);

  // Check modules
  modules = await yContract.getModules();
  console.log("modules", modules);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
