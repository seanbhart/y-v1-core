import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const yeet = await deploy("Yeet", {
    from: deployer,
    log: true,
  });

  console.log(`Yeet contract: `, yeet.address);
};

func.id = "deploy_yeet";
func.tags = ["Yeet"];

export default func;
