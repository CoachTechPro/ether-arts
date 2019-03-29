var EAS_platform = artifacts.require("./EAS_platform.sol");

module.exports = function(deployer) {
  deployer.then(async () =>{
    await deployer.deploy(EAS_platform);
  })
};
