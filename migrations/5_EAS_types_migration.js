var EAS_types = artifacts.require("./EAS_types.sol");
var Ownable = artifacts.require("./Ownable.sol");
var EAS_platform = artifacts.require("./EAS_platform.sol");

module.exports = function(deployer) {
  deployer.then(async () =>{
    var IF_Ownable = await Ownable.deployed();
    var IF_EAS_platform = await EAS_platform.deployed();

    await deployer.link(Ownable, EAS_types);
    await deployer.deploy(EAS_types, EAS_platform.address);
    IF_EAS_platform.allowAccess(EAS_types.address);
  })
};
