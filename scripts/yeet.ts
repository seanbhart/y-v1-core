import { ethers as hhethers } from "hardhat";

import YoArtifact from "../artifacts/contracts/stored/Yo.sol/Yo.json";
import YeetArtifact from "../artifacts/contracts/utils/Yeet.sol/Yeet.json";
import { Yo } from "../types/contracts/stored";
import { Yeet } from "../types/contracts/utils";
import { Yo__factory } from "../types/factories/contracts/stored";
import { Yeet__factory } from "../types/factories/contracts/utils";

const YEET_ADDRESS = process.env.YEET_ADDRESS_POLYGON;
const YO_ADDRESS = process.env.YO_ADDRESS_POLYGON;
// const YEET_ADDRESS = process.env.YEET_ADDRESS_OPTIMISM;
// const YO_ADDRESS = process.env.YO_ADDRESS_OPTIMISM;
const millisecDelay = 10000;
const logsOnly = false;

let yeetContract: Yeet;
let yoContract: Yo;

async function main() {
  if (!YEET_ADDRESS || !YO_ADDRESS) {
    console.log("Missing env vars");
    return;
  }

  console.log("YEET_ADDRESS", YEET_ADDRESS);
  const YeetFactory = new hhethers.ContractFactory(YeetArtifact.abi, YeetArtifact.bytecode) as Yeet__factory;
  yeetContract = YeetFactory.attach(YEET_ADDRESS) as Yeet;

  console.log("YO_ADDRESS", YO_ADDRESS);
  const YoFactory = new hhethers.ContractFactory(YoArtifact.abi, YoArtifact.bytecode) as Yo__factory;
  yoContract = YoFactory.attach(YO_ADDRESS) as Yo;

  // RUN FUNCTIONS
  await logs();
  if (!logsOnly) {
    await uint();
    await string();
    await bytes();
    await yoYeet();
    await yoYeetExpensive();
  }
}

async function logs() {
  const logFilters = [
    yeetContract.filters.LogUint(),
    yeetContract.filters.LogString(),
    yeetContract.filters.LogBytes(),
    yeetContract.filters.LogYoYeet(),
  ];

  for (const filter of logFilters) {
    const logs = await yeetContract.queryFilter(filter);
    console.log("logs length", logs.length);
    for (const log of logs) {
      const logValue = log.args?.value;
      console.log("logValue", logValue);
    }
  }
}

async function uint() {
  const value = 111;
  const tx = await yeetContract.logUint(value);
  const receipt = await tx.wait();
  if (!receipt) {
    throw new Error("No receipt");
  }

  // Add a delay for logs to sync
  await new Promise((resolve) => setTimeout(resolve, millisecDelay));

  const filter = yeetContract.filters.LogUint();
  const logs = await yeetContract.queryFilter(filter);

  // deserialize the event data
  const logValue = logs[logs.length - 1].args?.value;
  console.log("uint| logValue", logValue);

  // find the hash
  if (!receipt.blockNumber) {
    throw new Error("No block number");
  }
  const hash = hhethers.solidityPackedKeccak256(["uint", "uint256"], [receipt.blockNumber, value]);
  if ((await yeetContract.findYeet(hash)) == true) {
    console.log("uint| SUCCESS");
  } else {
    console.log("uint| FAILURE");
  }
}

async function string() {
  const value = "hello there";
  const tx = await yeetContract.logString(value);
  const receipt = await tx.wait();
  if (!receipt) {
    throw new Error("No receipt");
  }

  // Add a delay for logs to sync
  await new Promise((resolve) => setTimeout(resolve, millisecDelay));

  const filter = yeetContract.filters.LogString();
  const logs = await yeetContract.queryFilter(filter);

  // deserialize the event data
  const logValue = logs[logs.length - 1].args?.value;
  console.log("string| logValue", logValue);

  // find the hash
  if (!receipt.blockNumber) {
    throw new Error("No block number");
  }
  const hash = hhethers.solidityPackedKeccak256(["uint", "string"], [receipt.blockNumber, value]);
  if ((await yeetContract.findYeet(hash)) == true) {
    console.log("string| SUCCESS");
  } else {
    console.log("string| FAILURE");
  }
}

async function bytes() {
  const value = "hello there";
  const yoYeetBytes = await yoContract.serialize(value);
  const tx = await yeetContract.logBytes(yoYeetBytes);
  const receipt = await tx.wait();
  if (!receipt) {
    throw new Error("No receipt");
  }

  // Add a delay for logs to sync
  await new Promise((resolve) => setTimeout(resolve, millisecDelay));

  const filter = yeetContract.filters.LogBytes();
  const logs = await yeetContract.queryFilter(filter);

  // deserialize the event data
  const logValue = logs[logs.length - 1].args?.value;
  console.log("bytes| logValue", logValue);

  // find the hash
  if (!receipt.blockNumber) {
    throw new Error("No block number");
  }
  const hash = hhethers.solidityPackedKeccak256(["uint", "bytes"], [receipt.blockNumber, yoYeetBytes]);
  if ((await yeetContract.findYeet(hash)) == true) {
    console.log("bytes| SUCCESS");
  } else {
    console.log("bytes| FAILURE");
  }
}

async function yoYeet() {
  const value = "hello there";
  const tx = await yeetContract.logYoYeet(value);
  const receipt = await tx.wait();
  if (!receipt) {
    throw new Error("No receipt");
  }

  // Add a delay for logs to sync
  await new Promise((resolve) => setTimeout(resolve, millisecDelay));

  const filter = yeetContract.filters.LogYoYeet();
  const logs = await yeetContract.queryFilter(filter);

  // deserialize the event data
  const logValue = logs[logs.length - 1].args?.value;
  console.log("YoYeet| logValue", logValue);

  // find the hash
  if (!receipt.blockNumber) {
    throw new Error("No block number");
  }
  const block = await hhethers.provider.getBlock(receipt.blockNumber);
  if (!block) {
    throw new Error("Unable to retrieve block");
  }
  const yeetExpected = await yeetContract.yeetize(value);
  console.log("YoYeet| yeetExpected", yeetExpected);

  // use the block number from the tx, not the yeetize function
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
  if ((await yeetContract.findYeet(hash)) == true) {
    console.log("YoYeet| SUCCESS");
  } else {
    console.log("YoYeet| FAILURE");
  }
}

async function yoYeetExpensive() {
  const value = "hello there";
  const tx = await yeetContract.logYoYeetExpensive(value);
  const receipt = await tx.wait();
  if (!receipt) {
    throw new Error("No receipt");
  }

  // Add a delay for logs to sync
  await new Promise((resolve) => setTimeout(resolve, millisecDelay));

  const filter = yeetContract.filters.LogYoYeet();
  const logs = await yeetContract.queryFilter(filter);

  // deserialize the event data
  const logValue = logs[logs.length - 1].args?.value;
  console.log("yoYeetExpensive| logValue", logValue);

  // find the hash
  if (!receipt.blockNumber) {
    throw new Error("No block number");
  }
  const block = await hhethers.provider.getBlock(receipt.blockNumber);
  if (!block) {
    throw new Error("Unable to retrieve block");
  }
  const yeetExpected = await yeetContract.yeetize(value);
  console.log("yoYeetExpensive| yeetExpected", yeetExpected);

  // use the block number from the tx, not the yeetize function
  const yoHash = hhethers.solidityPackedKeccak256(
    ["address", "string", "string", "uint256", "string"],
    [yeetExpected.y, yeetExpected.username, yeetExpected.avatar, block.timestamp, yeetExpected.text],
  );
  const hash = hhethers.solidityPackedKeccak256(["uint", "bytes"], [receipt.blockNumber, yoHash]);
  if ((await yeetContract.findYeet(hash)) == true) {
    console.log("yoYeetExpensive| SUCCESS");
  } else {
    console.log("yoYeetExpensive| FAILURE");
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
