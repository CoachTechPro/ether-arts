pragma solidity >= 0.5.0;

contract IF_EAO{
  
  function UpdateIFEAO_roll(address _newIFEAO_roll_addr) public;
  function UpdateIFEAO_mission(address _newIFEAO_mission_addr) public;
  function UpdateIFEAO_buy(address _newIFEAO_buy_addr) public;

  function PlayRoll(uint32 _artworkId) public;
  function PlayMission() public;
  function RollWin(uint32 _artworkType, bytes32 queryId) external returns(bool);
  function RollLose(uint32 _artworkType, bytes32 queryId) external returns(bool);
  function BuyArtwork(uint32 _artworkType) public payable returns(uint);

  function oraclize_getPrice(string memory datasource) public returns (uint);
  function oraclize_getPrice(string memory datasource, uint gaslimit) public returns (uint);
  function oraclize_query(string memory datasource, string memory arg) public returns (bytes32 id);
  function oraclize_query(string memory datasource, string memory arg, uint gaslimit) public returns (bytes32 id);
  function oraclize_cbAddress() public returns (address);
  function oraclize_setCustomGasPrice(uint) public;

  function AssignReward(uint stageNo, address _EAO_MISSION_ADDR) public ;
  function CalculateRewardForWinner(uint _stageNo) public view returns(uint, uint, uint);

  //function FundBackupToEAS() external;
  function TransferFund(address _addressTo, uint _amountInWei) public;
  function GetBalance() public view returns(uint);
  function GetBalanceInFinny() public view returns(uint);
}
