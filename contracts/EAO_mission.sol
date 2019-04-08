pragma solidity >= 0.5.0;

import "./IF_EAS_artworks.sol";
import "./IF_EAS_types.sol";
import "./IF_EAS.sol";
import "./IF_EAS_mission.sol";
import "./IF_EAS_platform.sol"; 

import "./IF_EAO.sol";
import "./IF_EAM.sol";

import "./strings.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

contract EAO_mission is Ownable{

  using SafeMath for uint;
  using strings for *;
  
  uint gasPriceForOracleQuery = 6000000000;
  uint gasLimitForOracleQuery = 1000000;
  address EAS_backup_address;
  uint[5] timeDelay = [0, 60, 60*60, 60*60*24, 60*60*24*7];

  IF_EAS_artworks   IFEAS_artworks;
  IF_EAS_types      IFEAS_types;
  IF_EAS            IFEAS;
  IF_EAS_mission    IFEAS_mission;
  IF_EAS_platform   IFEAS_platform;

  IF_EAM            IFEAM;
  IF_EAO            IFEAO;

  event EventMissionGenerated(uint indexed stageNo, uint32 indexed blockNo, bytes32 queryId);
  event EventMissionResult(uint indexed stageNo, uint totalTypes, uint rn1, uint rn2, uint rn3, uint indexed win1, uint indexed win2);
  event EventRewardClaimed(address indexed player, uint indexed stageNo, uint rewardInFinny);

  modifier platform() {     /* Only EtherArts Platform (EtherArtsOperations, EtherArtsStorage, EtherArtsOracle, Contract owner) can access this contract */
      require(IFEAS_platform.accessAllowed(msg.sender) == true, "(platform error, EAO_mission)");
      _;
  }

  function() external  payable{}

  function GetBalance() public view returns(uint){
    return address(this).balance;
  }
  function GetBalanceInFinny() public view returns(uint){
    return address(this).balance/(10**15);
  
  }

  function FundBackupToEAS() external onlyOwner{
    IFEAS.SetEAOMissionFundSaved(address(this).balance);
    address payable addrTo = address(uint160(EAS_backup_address));
    addrTo.transfer(address(this).balance);
  }


  constructor(address _addrEAS, address _addrEAS_types, address _addrEAS_artworks, address _addrEAS_mission, address _addr_EAS_platform, address _addr_EAO) public {
    IFEAS = IF_EAS(_addrEAS);
    IFEAS_types = IF_EAS_types(_addrEAS_types);
    IFEAS_artworks = IF_EAS_artworks(_addrEAS_artworks);
    IFEAS_mission = IF_EAS_mission(_addrEAS_mission);
    IFEAS_platform = IF_EAS_platform(_addr_EAS_platform);
    IFEAO = IF_EAO(_addr_EAO);
    
    EAS_backup_address = _addrEAS;
  }

  function UpdateIFEAM(address _newIFEAM_addr) public onlyOwner{
    IFEAM = IF_EAM(_newIFEAM_addr);
  }



  function PlayMission(uint8 delayType) public platform{
    uint stageNo = IFEAS.stageNo();
    // have to add time constraint => Time period between last call and this call have to be longer than 5 days!!
    if (IFEAO.oraclize_getPrice("URL") > msg.sender.balance) {
      //LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
    } else {
      IFEAO.oraclize_setCustomGasPrice(gasPriceForOracleQuery); // set gas price to 5 Gwei

      uint typeLength = IFEAS_types.GetArtworkTypesLength() - 1;
      bytes32 queryId = IFEAO.oraclize_query(timeDelay[delayType], "WolframAlpha", "3 unique random numbers between 0 to 100000", gasLimitForOracleQuery);
      //bytes32 queryId = IFEAO.oraclize_query("WolframAlpha", "3 unique random numbers between 0 to ".toSlice().concat(IFEAS.toString(typeLength).toSlice()), gasLimitForOracleQuery);
      IFEAS_mission.SetPlayMissionId(queryId, true);
      IFEAS_mission.SetIdToStage(queryId, stageNo);

      emit EventMissionGenerated(stageNo, uint32(now), queryId);
    }
  }

  function SetGasPrice(uint price) external onlyOwner{ // default : 5000000000 (5 Gwei)
    gasPriceForOracleQuery = price;
  }

  function SetGasLimit(uint limit) external onlyOwner{ // default : 400000 gas
    gasLimitForOracleQuery = limit;
  }

  function __callback_PlayMission(bytes32 queryId, string calldata result) external platform{
    //require(msg.sender == oraclize_cbAddress(), "__callback_playmission : have to be called from oracle_cbaddress");
    require(IFEAS_mission.GetIdToStage(queryId) == IFEAS.stageNo(), "__callback_playmission : queryId to stageNo is not matched");

    uint rn1 = 12;
    uint rn2 = 34;
    uint rn3 = 56;

    strings.slice memory s = result.toSlice();
    strings.slice memory delim = ", ".toSlice();
    s.beyond("{".toSlice()).until("}".toSlice());
    
    rn1 = IFEAS.parseInt(s.split(delim).toString());
    rn2 = IFEAS.parseInt(s.split(delim).toString());
    rn3 = IFEAS.parseInt(s.toString());

    uint totalTypes = IFEAS_types.GetArtworkTypesLength();
    uint missionRange = IFEAS_mission.GetRecentRangeOffset();

    // prepare one rn
    uint winnerType1 = rn1.mod(totalTypes);
    uint winnerType2 = 0;
    uint winnerType3 = 0;

    if(totalTypes < missionRange){
      // prepare two more rns
      winnerType2 = rn2.mod(totalTypes);
      winnerType3 = rn3.mod(totalTypes);

      // equality test : we do not want get two same numbers.
      // we'll finally select winnerType1, winnerType2
      if(winnerType1 == winnerType2){
        winnerType2 = winnerType3;
        if(winnerType1 == winnerType2){
          winnerType2 = (winnerType1.add(winnerType2).add(winnerType3)).mod(totalTypes);
          if(winnerType1 == winnerType2){
            winnerType2 = (winnerType1.mul(winnerType2).add(winnerType3)).mod(totalTypes);
          }
        }
      }

    }else if(totalTypes >= missionRange){
      // select 1 from all range, 1 from recent recentRangeOffset cards.
      winnerType2 = (totalTypes - 1) - rn2.mod(missionRange);
      winnerType3 = (totalTypes - 1) - rn3.mod(missionRange);

      if(winnerType1 == winnerType2){
        winnerType2 = winnerType3;
        if(winnerType1 == winnerType2){
          winnerType2 = (totalTypes - 1) - (winnerType1.add(winnerType2).add(winnerType3)).mod(missionRange);
          if(winnerType1 == winnerType2){
            winnerType2 = (totalTypes - 1) - (winnerType1.mul(winnerType2).add(winnerType3)).mod(missionRange);
          }
        }
      }
    }

    emit EventMissionResult(IFEAS.stageNo(), uint(totalTypes), rn1, rn2, rn3, winnerType1, winnerType2);
    AssignMissionWinners(IFEAS.stageNo(), uint64(winnerType1), uint64(winnerType2));
  }



  function AssignMissionWinners(uint stageNo, uint64 winnerType1, uint64 winnerType2) public platform {  // external onlyOwner
    uint reward1 = 0;
    uint reward2 = 0;
    uint reward3 = 0;

    /**************** SAVE WINNER CARDS HERE ********************/
    IFEAS_mission.SetStageTargets(stageNo, winnerType1, winnerType2);

    /**************** WINNER CALCULATING & COUNTING ********************/
    uint card1Holders = IFEAS_artworks.GetTypeLength(uint32(winnerType1));
    uint card2Holders = IFEAS_artworks.GetTypeLength(uint32(winnerType2));

    // loop for each address that has type1 card
    for(uint i=0; i<card1Holders; i++){
      address winUser = IFEAS_artworks.GetArtworksOwner(IFEAS_artworks.GetTokenId(uint32(winnerType1), i)); // returns the address of owner that has i-th winnerType1 card
      bool isFirstWinner = false;

      // loop for each address that has type 2 card
      for(uint j=0; j<card2Holders; j++){
        if(winUser == IFEAS_artworks.GetArtworksOwner(IFEAS_artworks.GetTokenId(uint32(winnerType2), j))){
          isFirstWinner = true;
        }
      }
      if(isFirstWinner == true){
        IFEAS_mission.AppendWinner1(stageNo, winUser);  // first prize winners
      }else{
        IFEAS_mission.AppendWinner2(stageNo, winUser);  // second prize winners (owns winnerType1 only)
      }
    }

    for(uint i=0; i<card2Holders; i++){
      address winUser = IFEAS_artworks.GetArtworksOwner(IFEAS_artworks.GetTokenId(uint32(winnerType2), i)); // returns the address of owner that has i-th winnerType2 card
      if(IFEAS_mission.IsNewWinner1(stageNo, winUser) == true){   // if it is not in list1
        if(IFEAS_mission.IsNewWinner2(stageNo, winUser) == true){ // if it is not in list2
          IFEAS_mission.AppendWinner3(stageNo, winUser);          // second prize winners (owns winnerType2 only)
        }
      }
    }
 
    (reward1, reward2, reward3) = IFEAO.CalculateRewardForWinner(stageNo);
    
    // SAVE WINNER REWARDS HERE
    IFEAS_mission.SetStageRewards(stageNo, reward1, reward2, reward3);

    for(uint i=0; i<IFEAS_mission.GetWinner1Length(stageNo); i++){
      //                      stageNo,            Winner1,                   reward
      IFEAS_mission.SetReward(stageNo, IFEAS_mission.GetWinner1(stageNo, i), reward1);  // first prize winners
    }
    for(uint i=0; i<IFEAS_mission.GetWinner2Length(stageNo); i++){
      //                      stageNo,            Winner2,                   reward
      IFEAS_mission.SetReward(stageNo, IFEAS_mission.GetWinner2(stageNo, i), reward2);  // second prize winners (winnertype1 card only)
    }
    for(uint i=0; i<IFEAS_mission.GetWinner3Length(stageNo); i++){
      //                      stageNo,            Winner3,                   reward
      IFEAS_mission.SetReward(stageNo, IFEAS_mission.GetWinner3(stageNo, i), reward3);  // second prize winners (winnertype2 card only)
    }

    /* Fund transfer request from EAO to this contract for player reward claim */
    IFEAO.AssignReward(stageNo, address(this));
  }



  /* Winners will call this function from js frontend */
  function RewardClaim(uint _stageNo, address _Owner) public {
    require(msg.sender == _Owner, "Only account holder can claim own reward!, RewardClaim");
    require(IFEAS_mission.GetUserStageReward(_stageNo, _Owner) > 0, "Invalid Request, RewardClaim");
    uint stageNo = IFEAS.stageNo();
    uint reward = IFEAS_mission.GetUserStageReward(_stageNo, _Owner);
    IFEAS_mission.SetReward(_stageNo, _Owner, 0);//unclaimedRewards[_stageNo][_Owner] = 0;
    
    address payable addrTo = address(uint160(_Owner));
    addrTo.transfer(reward);
    emit EventRewardClaimed(_Owner, _stageNo, reward/(10**15));
  }

}