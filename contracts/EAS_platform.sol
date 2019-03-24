pragma solidity >= 0.5.0;

contract EAS_platform {

  mapping(address=>bool) public accessAllowed;
  address[] internal platformAddressList;

  modifier platform() {     /* Only EtherArts Platform (EtherArtsOperations, EtherArtsStorage, EtherArtsOracle, Contract owner) can access this contract */
      require(accessAllowed[msg.sender] == true, "(platform, EAS_platform)");
      _;
  }

  function allowAccess(address _address) platform public {
      accessAllowed[_address] = true;
      platformAddressList.push(_address);
  }
  function denyAccess(address _address) platform public {
      accessAllowed[_address] = false;
  }
  function GetAllAddressesAllowed() public view returns (address[] memory){
    address[] memory allAddressesAllowed = new address[](platformAddressList.length);
    uint j = 0;
    for(uint i = 0; i < platformAddressList.length; i++){
      if(accessAllowed[platformAddressList[i]] == true){
        allAddressesAllowed[j++] = platformAddressList[i];
      }
    }
    return allAddressesAllowed;
  }

  constructor() public{
    accessAllowed[msg.sender] = true;
    platformAddressList.push(msg.sender);
  }
}
