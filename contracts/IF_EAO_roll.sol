pragma solidity >= 0.5.0;

contract IF_EAO_roll{

  event EventRollQueried(bytes32 queryId, address indexed player,uint32 indexed cardType, uint betSizeInWei);
  event EventRollReceived(bytes32 queryId, address indexed player, uint32 indexed cardNo, uint betSizeInWei, uint8 myRandomNumber, bool indexed won, uint cardId);
  
  function UpdateIFEAM(address _newIFEAM_addr) public;

  function PlayRoll(uint32 _type, address _msgSender, uint _msgValue, uint _msgSenderBalance) public;
  function __callback_PlayRoll(bytes32 queryId, string memory result) public;
  
  function EmitEventRollReceived(bytes32 queryId, uint8 rn, bool won) internal;


}
