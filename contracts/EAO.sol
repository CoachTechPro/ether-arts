pragma solidity >= 0.5.0;
import "./usingOraclize.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

import "./IF_EAO_mission.sol";
import "./IF_EAO_roll.sol";
import "./IF_EAO_buy.sol";

import "./IF_EAS_roll.sol";
import "./IF_EAS.sol";
import "./IF_EAS_mission.sol";
import "./IF_EAS_platform.sol"; 

contract EAO is usingOraclize, Ownable{

  address EAS_backup_address;
  using SafeMath for uint256;
  using SafeMath for uint32;

  IF_EAO_mission    IFEAO_mission;
  IF_EAO_roll       IFEAO_roll;
  IF_EAO_buy        IFEAO_buy;

  IF_EAS_roll       IFEAS_roll;
  IF_EAS            IFEAS;
  IF_EAS_mission    IFEAS_mission;
  IF_EAS_platform   IFEAS_platform;

  modifier platform() {     /* Only EtherArts Platform (EtherArtsOperations, EtherArtsStorage, EtherArtsOracle, Contract owner) can access this contract */
      require(IFEAS_platform.accessAllowed(msg.sender) == true, "(platform, EAO)");
      _;
  }

  function() external payable{}

  function GetBalance() public view returns(uint){
    return address(this).balance;
  }
  function GetBalanceInFinny() public view returns(uint){
    return address(this).balance/(10**15);
  }

  constructor(address _addrEAS, address _addrEAS_roll, address _addrEAS_types, address _addrEAS_artworks, address _addrEAS_mission, address _addr_EAS_platform) public{
    OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);  // for ethereum-bridge
    //OAR = OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);  // for RINKEBY TESTNET
    //OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);  // for ROPSTEN TESTNET
    //OAR = OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);  // for KOVAN TESTNET
    //OAR = OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);  // for Browser Solidity
    //OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);  // for MAINNET

    IFEAS = IF_EAS(_addrEAS);
    IFEAS_roll = IF_EAS_roll(_addrEAS_roll);
    IFEAS_mission = IF_EAS_mission(_addrEAS_mission);
    IFEAS_platform = IF_EAS_platform(_addr_EAS_platform);
    EAS_backup_address = _addrEAS;
  }


  function UpdateIFEAO_roll(address _newIFEAO_roll_addr) public onlyOwner{
    IFEAO_roll = IF_EAO_roll(_newIFEAO_roll_addr);
  }

  function UpdateIFEAO_mission(address _newIFEAO_mission_addr) public onlyOwner{
    IFEAO_mission = IF_EAO_mission(_newIFEAO_mission_addr);
  }

  function UpdateIFEAO_buy(address _newIFEAO_buy_addr) public onlyOwner{
    IFEAO_buy = IF_EAO_buy(_newIFEAO_buy_addr);
  }

  function FundBackupToEAS() external onlyOwner{
    IFEAS.SetEAOFundSaved(address(this).balance);
    address payable addrTo = address(uint160(EAS_backup_address));
    addrTo.transfer(address(this).balance);
  }

/************************************************************************************/
/************     ROLL AND MISSION PLAY RELATED ORACLE FUNCTIONS        *************/
/************************************************************************************/

  function PlayRoll(uint32 _artworkId) public payable {    
    IFEAO_roll.PlayRoll(_artworkId, msg.sender, msg.value, msg.sender.balance);
  }

  function PlayMission() public onlyOwner{
    IFEAO_mission.PlayMission();
  }

  function BuyArtwork(uint32 _artworkType) external payable returns(uint) {
    return IFEAO_buy.BuyArtwork(_artworkType, msg.sender, msg.value, msg.sender.balance);
  }


  function TransferFund(address _addressTo, uint _amountInWei) public platform{
    address payable addrTo = address(uint160(_addressTo));
    addrTo.transfer(_amountInWei);
  }

  function __callback(bytes32 myid, string memory result) public {  // callback function of GetNewRandomNumbersFromOracle()

    //if (msg.sender != oraclize_cbAddress()) revert("cbAddress not matched"); // only cbAddress can run this code!
    
    if(IFEAS_roll.GetPlayRollId(myid) == true){ // If and only if this callback is generated due to the PlayRoll()
      IFEAO_roll.__callback_PlayRoll(myid, result);
      IFEAS_roll.SetPlayRollId(myid, false);
    }else if (IFEAS_mission.GetPlayMissionId(myid) == true){ // If and only if this callback is generated due to the PlayMission()
      IFEAO_mission.__callback_PlayMission(myid, result);
      IFEAS_mission.SetPlayMissionId(myid, false);
    }else{   // Either RollId marked or playMissionId marked : revert case 
      revert("__callback_reverted.");
    }
  }


/******************************************************************************/
/************            REWARD DISTRIBUTION functions            *************/
/******************************************************************************/

  function AssignReward(uint _stageNo, address _EAO_MISSION_ADDR) public platform {

    // Send fund to EAO_MISSION contract for withdrawal claim
    uint stage_reward = 0;
    if(IFEAS_mission.GetWinner1Length(_stageNo) > 0){
      stage_reward += address(this).balance.mul(uint(IFEAS.WINNERS1_DIST_RATIO())).div(100);
    }
    if(IFEAS_mission.GetWinner2Length(_stageNo) > 0){
      stage_reward += address(this).balance.mul(uint(IFEAS.WINNERS2_DIST_RATIO())).div(100);  
    }
    
    address payable addrTo = address(uint160(_EAO_MISSION_ADDR));
    addrTo.transfer(stage_reward);
    IFEAS_mission.FinalizeStage(_stageNo);  // Record last card-id that has been issued, then increase stage number.
  }


  // distribute ether pool to mission winners
  function CalculateRewardForWinner(uint _stageNo) public view returns(uint, uint, uint){
    /* returns amount of ethers for mission reward : If there is at least one winners */
    uint reward1;
    uint reward2;
    uint reward3;
    uint numWinner1 = IFEAS_mission.GetWinner1Length(_stageNo);
    uint numWinner2 = IFEAS_mission.GetWinner2Length(_stageNo);
    uint numWinner3 = IFEAS_mission.GetWinner3Length(_stageNo);

    if(IFEAS_mission.GetWinner1Length(_stageNo) > 0){
      reward1 = address(this).balance.mul(IFEAS.WINNERS1_DIST_RATIO()).div(100).div(numWinner1); 
    }else{
      reward1 = 0;
    }
    
    if(IFEAS_mission.GetWinner2Length(_stageNo) > 0){
      reward2 = address(this).balance.mul(IFEAS.WINNERS2_DIST_RATIO()).div(200).div(numWinner2);
    }else{
      reward2 = 0;
    }

    if(IFEAS_mission.GetWinner3Length(_stageNo) > 0){
      reward3 = address(this).balance.mul(IFEAS.WINNERS2_DIST_RATIO()).div(200).div(numWinner3);
    }else{
      reward3 = 0;
    }

    return (reward1, reward2, reward3);
  }


}
