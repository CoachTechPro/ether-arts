var EAM = artifacts.require("./EAM.sol");

var EAS = artifacts.require("./EAS.sol");
var EAS_types = artifacts.require("./EAS_types.sol");
var EAS_artworks = artifacts.require("./EAS_artworks.sol");
var EAS_platform = artifacts.require("./EAS_platform.sol");

var EAO_mission = artifacts.require("./EAO_mission.sol");
var EAO_roll = artifacts.require("./EAO_roll.sol");

var SafeMath = artifacts.require("./SafeMath.sol");
var Ownable = artifacts.require("./Ownable.sol");

module.exports = function(deployer) {
  deployer.then(async () => {
    var IF_EAS = await EAS.deployed();
    var IF_EAS_types = await EAS_types.deployed();
    var IF_EAS_artworks = await EAS_artworks.deployed();
    var IF_EAS_platform = await EAS_platform.deployed();

    var IF_EAO_mission = await EAO_mission.deployed();
    var IF_EAO_roll = await EAO_roll.deployed();

    var IF_SafeMath = await SafeMath.deployed();
    var IF_Ownable = await Ownable.deployed();

    await deployer.link(Ownable, EAM);
    await deployer.link(SafeMath, EAM);

    var IF_EAM = await deployer.deploy(EAM, EAS.address, EAS_types.address, EAS_artworks.address, EAS_platform.address);
    await IF_EAS_platform.allowAccess(EAM.address);
    await IF_EAO_mission.UpdateIFEAM(EAM.address);
    await IF_EAO_roll.UpdateIFEAM(EAM.address);

  });
}

