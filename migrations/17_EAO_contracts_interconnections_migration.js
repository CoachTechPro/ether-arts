var EAS = artifacts.require("./EAS.sol");
var EAS_types = artifacts.require("./EAS_types.sol");
var EAS_artworks = artifacts.require("./EAS_artworks.sol");
var EAS_roll = artifacts.require("./EAS_roll.sol");
var EAS_mission = artifacts.require("./EAS_mission.sol");
var EAS_mixedQuery = artifacts.require("./EAS_mixedQuery.sol");

var EAO = artifacts.require("./EAO.sol");
var EAO_mission = artifacts.require("./EAO_mission.sol");
var EAO_roll = artifacts.require("./EAO_roll.sol");
var EAO_buy = artifacts.require("./EAO_buy.sol");
var EAO_userMarket = artifacts.require("./EAO_userMarket.sol");

module.exports = function(deployer) {
  deployer.then(async () =>{

    var IF_EAS = await EAS.deployed();
    var IF_EAS_types = await EAS_types.deployed();
    var IF_EAS_artworks = await EAS_artworks.deployed();
    var IF_EAS_roll = await EAS_roll.deployed();
    var IF_EAS_mission = await EAS_mission.deployed();
    var IF_EAS_mixedQuery = await EAS_mixedQuery.deployed();

    var IF_EAO = await EAO.deployed();
    var IF_EAO_mission = await EAO_mission.deployed();
    var IF_EAO_roll = await EAO_roll.deployed();
    var IF_EAO_buy = await EAO_buy.deployed();
    var IF_EAO_userMarket = await EAO_userMarket.deployed();

    IF_EAO.UpdateIFEAO_mission(EAO_mission.address);
    IF_EAO.UpdateIFEAO_roll(EAO_roll.address);
    IF_EAO.UpdateIFEAO_buy(EAO_buy.address);
    
  })
};

