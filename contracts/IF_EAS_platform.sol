pragma solidity >= 0.5.0;

contract IF_EAS_platform {
  
  mapping(address=>bool) public accessAllowed;
  address[] public platformAddressList;
  function allowAccess(address _address) public;
  function denyAccess(address _address) public;
  function GetAllAddressesAllowed() public view returns (address[] memory);

}
