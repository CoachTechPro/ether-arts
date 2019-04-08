pragma solidity >= 0.5.0;

contract IF_EAS_mission{

  /***********************************************/
  /*       MAPPING FOR MISSION INTERFACE         */
  /***********************************************/
  function SetRecentRangeOffset(uint16 _newValue) public;
  function GetRecentRangeOffset() public view returns (uint16);
  function GetStageCutoffId(uint _stageNo) public view returns(uint);

  function SetReward(uint _stageNo, address _address, uint _rewardInWei) public;
  function GetUserRewards(address _Owner) public view returns(uint[] memory);
  
  function GetUserStageReward(uint _stageNo, address _address) public view returns(uint);
  //function GetUserWinnerTag(uint _stageNo, address _address) public view returns(uint);

  function FinalizeStage(uint _stageNo) public;
  function SetStageRewards(uint _stageNo, uint _reward1, uint _reward2, uint _reward3) public;
  //function GetStageRewards(uint _stageNo) public view returns (uint, uint);
  function GetStageRewardsHistory() public view returns (uint[] memory, uint[] memory, uint[] memory);
  function SetStageTargets(uint _stageNo, uint64 num1, uint64 num2) external;
  //function GetStageTargets(uint _stageNo) view public returns(uint64, uint64);

  function AppendWinner1(uint _stageNo, address _winner) external;
  function IsNewWinner1(uint _stageNo, address _newAddr) view public returns(bool);
  function GetWinner1Length(uint _stageNo) view public returns(uint);
  function GetWinner1(uint _stageNo, uint _idx) view public returns(address);
  
  function AppendWinner2(uint _stageNo, address _winner) external;
  function IsNewWinner2(uint _stageNo, address _newAddr) view public returns(bool);
  function GetWinner2Length(uint _stageNo) view public returns(uint);
  function GetWinner2(uint _stageNo, uint _idx) view public returns(address);

  function AppendWinner3(uint _stageNo, address _winner) external;
  function IsNewWinner3(uint _stageNo, address _newAddr) view public returns(bool);
  function GetWinner3Length(uint _stageNo) view public returns(uint);
  function GetWinner3(uint _stageNo, uint _idx) view public returns(address);

  function SetPlayMissionId(bytes32 _id, bool _val) external;
  function GetPlayMissionId(bytes32 _id) public view returns(bool);

  function GetIdToStage(bytes32 _id) public view returns (uint);
  function SetIdToStage(bytes32 _id, uint _stageNo) external;

}