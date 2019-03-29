var EAO_userMarket = artifacts.require("./EAO_userMarket.sol");

var EAS = artifacts.require("./EAS.sol");
var EAS_artworks = artifacts.require("./EAS_artworks.sol");
var EAS_platform = artifacts.require("./EAS_platform.sol");

var SafeMath = artifacts.require("./SafeMath.sol");
var Ownable = artifacts.require("./Ownable.sol");

module.exports = function(deployer) {
  deployer.then(async () =>{
    var IF_EAS = await EAS.deployed();
    var IF_EAS_artworks = await EAS_artworks.deployed();
    var IF_EAS_platform = await EAS_platform.deployed();

    var IF_SafeMath = await SafeMath.deployed();
    var IF_Ownable = await Ownable.deployed();
    
    await deployer.link(Ownable, EAO_userMarket);
    await deployer.link(SafeMath, EAO_userMarket);
    var IF_EAO_userMarket = await deployer.deploy(EAO_userMarket, EAS.address, EAS_artworks.address, EAS_platform.address);
    IF_EAS_platform.allowAccess(EAO_userMarket.address);
  });
};

