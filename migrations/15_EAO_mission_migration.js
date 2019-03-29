var EAO_mission = artifacts.require("./EAO_mission.sol");

var EAS = artifacts.require("./EAS.sol");
var EAS_types = artifacts.require("./EAS_types.sol");
var EAS_artworks = artifacts.require("./EAS_artworks.sol");
var EAS_mission = artifacts.require("./EAS_mission.sol");
var EAS_platform = artifacts.require("./EAS_platform.sol");

var EAO = artifacts.require("./EAO.sol");

var strings = artifacts.require("./strings.sol");
var Ownable = artifacts.require("./Ownable.sol");
var SafeMath = artifacts.require("./SafeMath.sol");

module.exports = function(deployer) {
  deployer.then(async () =>{

    var IF_EAS = await EAS.deployed();
    var IF_EAS_types = await EAS_types.deployed();
    var IF_EAS_artworks = await EAS_artworks.deployed();
    var IF_EAS_mission = await EAS_mission.deployed();
    var IF_EAS_platform = await EAS_platform.deployed();

    var IF_EAO = await EAO.deployed();

    var IF_strings = await strings.deployed();
    var IF_SafeMath = await SafeMath.deployed();
    var IF_Ownable = await Ownable.deployed();
    
    await deployer.link(Ownable, EAO_mission);
    await deployer.link(SafeMath, EAO_mission);
    await deployer.link(strings, EAO_mission);

    var IF_EAO_mission = await deployer.deploy(EAO_mission, EAS.address, EAS_types.address, EAS_artworks.address, EAS_mission.address, EAS_platform.address, EAO.address);
    IF_EAS_platform.allowAccess(EAO_mission.address);
    IF_EAS.UpdateIFEAO_mission(EAO_mission.address);
  })
};

