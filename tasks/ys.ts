import { task } from "hardhat/config";

task("Ys", "Prints the list of Y contracts", async (_taskArgs, hre) => {
  const ys = await hre.ethers.getSigners();

  for (const y of ys) {
    console.log(y.address);
  }
});
