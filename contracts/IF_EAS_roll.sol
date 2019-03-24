pragma solidity >= 0.5.0;

contract IF_EAS_roll {

  uint public rollTried;
  uint public rollWonCount;

 /***********************************************/
  /*              MAPPING INTERFACE              */
  /***********************************************/
  function SetIdToPlayer(bytes32 _id, address _player) external;
  function GetIdToPlayer(bytes32 _id) public view returns(address);
  function SetIdToWon(bytes32 _id, bool _result) external;
  function GetIdToWon(bytes32 _id) public view returns(bool);

  function SetIdToRollTarget(bytes32 _id, uint32 _target) external;
  function GetIdToRollTarget(bytes32 _id) public view returns(uint32);
  function SetIdToWonPrizeTransfered(bytes32 _id, bool _transfered) external;
  function GetIdToWonPrizeTransfered(bytes32 _id) public view returns(bool);
  function SetIdToBetPrice(bytes32 _id, uint _betPrice) external;
  function GetIdToBetPrice(bytes32 _id) public view returns(uint);

  function SetPlayRollId(bytes32 _id, bool _val) external;
  function GetPlayRollId(bytes32 _id) public view returns(bool);

  function IncreaseRollTried() external;
  function IncreaseRollWonCount() external;
}