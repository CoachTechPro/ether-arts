var EAS_mission = artifacts.require("./EAS_mission.sol");

var EAS = artifacts.require("./EAS.sol");
var EAS_artworks = artifacts.require("./EAS_artworks.sol");
var EAS_platform = artifacts.require("./EAS_platform.sol");
var Ownable = artifacts.require("./Ownable.sol");

module.exports = function(deployer) {
  deployer.then(async () =>{
    var IF_EAS_artworks = await EAS_artworks.deployed();
    var IF_EAS = await EAS.deployed();
    var IF_Ownable = await Ownable.deployed();
    var IF_EAS_platform = await EAS_platform.deployed();

    await deployer.link(Ownable, EAS_mission);
    await deployer.deploy(EAS_mission, EAS.address, EAS_artworks.address, EAS_platform.address);
    IF_EAS_platform.allowAccess(EAS_mission.address);
  })
};
