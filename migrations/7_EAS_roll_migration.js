var EAS_artworks = artifacts.require("./EAS_artworks.sol");

var EAS_roll = artifacts.require("./EAS_roll.sol");
var EAS_platform = artifacts.require("./EAS_platform.sol");
var Ownable = artifacts.require("./Ownable.sol");


module.exports = function(deployer) {
  deployer.then(async () =>{
    var IF_EAS_artworks = await EAS_artworks.deployed();
    var IF_Ownable = await Ownable.deployed();
    var IF_EAS_platform = await EAS_platform.deployed();
    
    await deployer.link(Ownable, EAS_roll);
    await deployer.deploy(EAS_roll, EAS_platform.address);
    IF_EAS_platform.allowAccess(EAS_roll.address);
  });
};
