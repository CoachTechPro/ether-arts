pragma solidity >= 0.5.0;

contract IF_EAO_mission{

  event EventMissionGenerated(uint indexed stageNo, uint32 indexed blockNo, bytes32 queryId);
  event EventMissionResult(uint indexed stageNo, uint indexed totalTypes, uint rn1, uint rn2);
  event EventRewardClaimed(address indexed player, uint indexed stageNo, uint rewardInFinny);

  function UpdateIFEAM(address _newIFEAM_addr) public;
  function GetBalance() public returns(uint);
  function GetBalanceInFinny() public view returns(uint);

  //function FundBackupToEAS() external;

  function PlayMission(uint8 delayType) public;
  function SetGasPrice(uint price) external;
  function SetGasLimit(uint limit) external;
  function __callback_PlayMission(bytes32 queryId, string memory result) public;
  function AssignMissionWinners(uint stageNo, uint64 winType1, uint64 winType2) public;
  function RewardClaim(uint _stageNo, address _Owner) public ;

}