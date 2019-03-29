var EAO = artifacts.require("./EAO.sol");

var EAS = artifacts.require("./EAS.sol");
var EAS_types = artifacts.require("./EAS_types.sol");
var EAS_artworks = artifacts.require("./EAS_artworks.sol");
var EAS_roll = artifacts.require("./EAS_roll.sol");
var EAS_mission = artifacts.require("./EAS_mission.sol");
var EAS_platform = artifacts.require("./EAS_platform.sol");

var Ownable = artifacts.require("./Ownable.sol");
//var strings = artifacts.require("./strings.sol");
var usingOraclize = artifacts.require("./usingOraclize.sol");
var SafeMath = artifacts.require("./SafeMath.sol");

module.exports = function(deployer) {
  deployer.then(async () =>{

    var IF_EAS = await EAS.deployed();
    var IF_EAS_types = await EAS_types.deployed();
    var IF_EAS_artworks = await EAS_artworks.deployed();
    var IF_EAS_roll = await EAS_roll.deployed();
    var IF_EAS_mission = await EAS_mission.deployed();
    var IF_EAS_platform = await EAS_platform.deployed();
  
    var IF_usingOraclize = await usingOraclize.deployed();
    //var IF_strings = await strings.deployed();
    var IF_Ownable = await Ownable.deployed();
    var IF_SafeMath = await SafeMath.deployed();
    
    await deployer.link(SafeMath, EAO);
    await deployer.link(Ownable, EAO);
    await deployer.link(usingOraclize, EAO);
    //await deployer.link(strings, EAO);

    var IF_EAO = await deployer.deploy(EAO, EAS.address, EAS_roll.address, EAS_types.address, EAS_artworks.address, EAS_mission.address, EAS_platform.address);
    IF_EAS_platform.allowAccess(EAO.address);

    IF_EAS.UpdateIFEAO(EAO.address);
  })
};

