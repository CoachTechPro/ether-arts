pragma solidity >= 0.5.0;
import "./Ownable.sol";
import "./IF_EAS.sol";
import "./IF_EAS_artworks.sol";
import "./IF_EAS_platform.sol"; 

contract EAS_mission is Ownable{
    
  uint16 public recentRangeOffset = 30;

  mapping(uint => address[])  public winners1;         // [stageNo] => Mission Winners
  mapping(uint => address[])  public winners2;         // [stageNo] => Mission Winners
  mapping(uint => address[])  public winners3;         // [stageNo] => Mission Winners

  mapping(uint => mapping(address => uint)) public unclaimedRewards;
  mapping(uint => mapping(address => uint)) public winnerTag;
  // ex) unclaimedRewards[stageNo][userAddress] = unclaimed amount of reward for userAddress (in Wei)

  mapping(uint => uint64[])   public stageTargets;
  mapping(uint => uint[])     public stageRewards;
  mapping(uint => uint)       public stageCutOffId;

  mapping(uint=>uint)         internal stageTimestamp;
  mapping(bytes32=>uint)      internal idToStage;
  mapping(bytes32=>bool)      internal playMissionId;  // for oraclize query identification

  IF_EAS            IFEAS;
  IF_EAS_artworks   IFEAS_artworks;
  IF_EAS_platform   IFEAS_platform;

  modifier platform() {     /* Only EtherArts Platform (EtherArtsOperations contract, EtherArtsStorage contract, Contract owner) can access this contract */
      require(IFEAS_platform.accessAllowed(msg.sender) == true, "msg.sender (platform error, EAS_mission");
      _;
  }

  constructor(address _addrEAS, address _addrEAS_artworks, address _addr_EAS_platform) public{
    IFEAS = IF_EAS(_addrEAS);
    IFEAS_artworks = IF_EAS_artworks(_addrEAS_artworks);
    IFEAS_platform = IF_EAS_platform(_addr_EAS_platform);
  }

  function SetRecentRangeOffset(uint16 _newValue) public onlyOwner{
    recentRangeOffset = _newValue;
  }
  function GetRecentRangeOffset() public view returns (uint16){
    return recentRangeOffset;
  }


  function FinalizeStage(uint _stageNo) public platform{
    uint lastIndex = 0;
    if(IFEAS_artworks.GetArtworksLength() > 0){
      lastIndex = IFEAS_artworks.GetArtworksLength() - 1;
    }
    stageCutOffId[_stageNo] = IFEAS_artworks.GetArtworksLength() - 1;  // final card-id for stage
    IFEAS.SetStageNo(_stageNo + 1);
  }

  function GetStageCutoffId(uint _stageNo) public view returns(uint){
    require(_stageNo <= IFEAS.stageNo() && _stageNo >= 0, "EAS_MIS, 1");
    return stageCutOffId[_stageNo];
  }


  /***********************************************/
  /*       MAPPING FOR MISSION INTERFACE         */
  /***********************************************/

  function SetReward(uint _stageNo, address _address, uint _rewardInWei) public platform {
    require(_stageNo <= IFEAS.stageNo() && _stageNo >= 0, "EAS_MIS, 2");
    require(_rewardInWei >= 0, "EAS_MIS, 3");
    unclaimedRewards[_stageNo][_address] = _rewardInWei;
  
    if(_rewardInWei > 0){
      winnerTag[_stageNo][_address] = _rewardInWei;
    }
  }

  function GetUserRewards(address _Owner) public view returns(uint[] memory){
    require(msg.sender == _Owner, "EAS_MIS, 3");
    uint numStages = IFEAS.stageNo();
    uint[] memory rewards = new uint[](numStages);
    for(uint i=0; i<numStages; i++){
      rewards[i] = unclaimedRewards[i][_Owner];
    }
    return rewards;
  }

/*
  function GetUserWinnerTag(uint _stageNo, address _address) public view returns(uint){
    require(_stageNo <= IFEAS.stageNo() && _stageNo >= 0, "StageNo RangeErr, GetUserStageReward");
    return(winnerTag[_stageNo][_address]);
  }
*/

  function GetUserStageReward(uint _stageNo, address _address) public view returns(uint){
    require(_stageNo <= IFEAS.stageNo() && _stageNo >= 0, "EAS_MIS, 4");
    return(unclaimedRewards[_stageNo][_address]);
  }

  function SetStageRewards(uint _stageNo, uint _reward1, uint _reward2, uint _reward3) public platform{
    // need to add some protection here
    stageRewards[_stageNo].push(_reward1);
    stageRewards[_stageNo].push(_reward2);
    stageRewards[_stageNo].push(_reward3);
  }
/*
  function GetStageRewards(uint _stageNo) public view returns (uint, uint){
    require(stageRewards[_stageNo].length == 2, "EAS_MIS, 5");
    return(stageRewards[_stageNo][0], stageRewards[_stageNo][1]);
  }
*/
  function GetStageRewardsHistory() public view returns (uint[] memory, uint[] memory, uint[] memory){
    uint stages = IFEAS.stageNo();
    uint[] memory reward1 = new uint[](stages);
    uint[] memory reward2 = new uint[](stages);   
    uint[] memory reward3 = new uint[](stages);
    for(uint i=0; i<stages; i++){
      reward1[i] = stageRewards[i][0];  // reward history for single 1st winners
      reward2[i] = stageRewards[i][1];  // reward history for single 2nd winners, (card type1 only)
      reward3[i] = stageRewards[i][2];  // reward history for single 2nd winners, (card type2 only)
    }
    return(reward1, reward2, reward3);
  }


  function SetPlayMissionId(bytes32 _id, bool _val) external platform{
    playMissionId[_id] = _val;
  }
  function GetPlayMissionId(bytes32 _id) public view returns(bool){
    return playMissionId[_id];
  }


  function SetStageTargets(uint _stageNo, uint64 num1, uint64 num2) external platform{
    require(_stageNo == IFEAS.stageNo(), "EAS_MIS, 6");
    require(stageTargets[_stageNo].length == 0, "EAS_MIS, 7");
    stageTargets[_stageNo].push(num1);
    stageTargets[_stageNo].push(num2);
  }

/*
  function GetStageTargets(uint _stageNo) view public returns(uint64, uint64) {
    require(_stageNo <= IFEAS.stageNo() && _stageNo >= 0, "EAS_MIS, 10");
    if(stageTargets[_stageNo].length == 2){
      return(stageTargets[_stageNo][0], stageTargets[_stageNo][1]);
    }else{
      return(0, 0);
    }
  }
*/


  function AppendWinner1(uint _stageNo, address _winner) external platform{
    require(_stageNo <= IFEAS.stageNo() && _stageNo >= 0, "EAS_MIS, 11");
    if(IsNewWinner1(_stageNo, _winner)){
      winners1[_stageNo].push(_winner);
    }
  }
  function IsNewWinner1(uint _stageNo, address _newAddr) view public returns(bool){
    require(_stageNo <= IFEAS.stageNo() && _stageNo >= 0, "EAS_MIS, 12");
    uint lenth = GetWinner1Length(_stageNo);
    for(uint i=0; i<lenth; i++){
      if(winners1[_stageNo][i] == _newAddr){
        return false;
      }
    }
    return true;
  }
  function GetWinner1Length(uint _stageNo) view public returns(uint) {
    require(_stageNo <= IFEAS.stageNo() && _stageNo >= 0, "EAS_MIS, 13");
    return winners1[_stageNo].length;
  }
  function GetWinner1(uint _stageNo, uint _idx) view public returns(address) {
    require(_stageNo <= IFEAS.stageNo() && _stageNo >= 0, "EAS_MIS, 14");
    return winners1[_stageNo][_idx];
  }


  function AppendWinner2(uint _stageNo, address _winner) external platform{
    require(_stageNo <= IFEAS.stageNo() && _stageNo >= 0, "EAS_MIS, 21");
    if(IsNewWinner2(_stageNo, _winner)){
      winners2[_stageNo].push(_winner);
    }
  }
  function IsNewWinner2(uint _stageNo, address _newAddr) view public returns(bool){
    require(_stageNo <= IFEAS.stageNo() && _stageNo >= 0, "EAS_MIS, 22");
    uint lenth = GetWinner2Length(_stageNo);
    for(uint i=0; i<lenth; i++){
      if(winners2[_stageNo][i] == _newAddr){
        return false;
      }
    }
    return true;
  }
  function GetWinner2Length(uint _stageNo) view public returns(uint) {
    require(_stageNo <= IFEAS.stageNo() && _stageNo >= 0, "EAS_MIS, 23");
    return winners2[_stageNo].length;
  }
  function GetWinner2(uint _stageNo, uint _idx) view public returns(address) {
    require(_stageNo <= IFEAS.stageNo() && _stageNo >= 0, "EAS_MIS, 24");
    return winners2[_stageNo][_idx];
  }



  function AppendWinner3(uint _stageNo, address _winner) external platform{
    require(_stageNo <= IFEAS.stageNo() && _stageNo >= 0, "EAS_MIS, 31");
    if(IsNewWinner3(_stageNo, _winner)){
      winners3[_stageNo].push(_winner);
    }
  }
  function IsNewWinner3(uint _stageNo, address _newAddr) view public returns(bool){
    require(_stageNo <= IFEAS.stageNo() && _stageNo >= 0, "EAS_MIS, 32");
    uint lenth = GetWinner3Length(_stageNo);
    for(uint i=0; i<lenth; i++){
      if(winners3[_stageNo][i] == _newAddr){
        return false;
      }
    }
    return true;
  }
  function GetWinner3Length(uint _stageNo) view public returns(uint) {
    require(_stageNo <= IFEAS.stageNo() && _stageNo >= 0, "EAS_MIS, 33");
    return winners3[_stageNo].length;
  }
  function GetWinner3(uint _stageNo, uint _idx) view public returns(address) {
    require(_stageNo <= IFEAS.stageNo() && _stageNo >= 0, "EAS_MIS, 34");
    return winners3[_stageNo][_idx];
  }


  function GetIdToStage(bytes32 _id) public view returns (uint){
    return idToStage[_id];
  }
  function SetIdToStage(bytes32 _id, uint _stageNo) external platform{
    idToStage[_id] = _stageNo;
  }


}