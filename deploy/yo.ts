import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const yo = await deploy("Yo", {
    from: deployer,
    log: true,
  });

  console.log(`Yo contract: `, yo.address);
};

func.id = "deploy_yo";
func.tags = ["Yo"];

export default func;
