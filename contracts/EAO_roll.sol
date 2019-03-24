pragma solidity >= 0.5.0;

import "./IF_EAO.sol";
import "./IF_EAS_roll.sol";
import "./IF_EAS_artworks.sol";
import "./IF_EAS_types.sol";
import "./IF_EAS.sol";
import "./IF_EAS_platform.sol"; 

import "./IF_EAM.sol";

import "./SafeMath.sol";
import "./Ownable.sol";
import "./strings.sol";

contract EAO_roll is Ownable{

  using SafeMath for uint256;
  using SafeMath for uint32;
  using strings for *;

  uint gasPriceForOracleQuery = 10000000000;
  uint gasLimitForOracleQuery = 800000;

  IF_EAO            IFEAO;
  IF_EAS_roll       IFEAS_roll;
  IF_EAS_artworks   IFEAS_artworks;
  IF_EAS_types      IFEAS_types;
  IF_EAS            IFEAS;
  IF_EAM            IFEAM;
  IF_EAS_platform   IFEAS_platform;

  event EventRollQueried(bytes32 queryId, address indexed player, uint32 indexed cardType, uint betSizeInWei);
  event EventRollReceived(bytes32 queryId, address indexed player, uint32 indexed cardNo, uint8 myRandomNumber, bool indexed won, uint cardId);

  modifier platform() {     /* Only EtherArts Platform (EtherArtsOperations, EtherArtsStorage, EtherArtsOracle, Contract owner) can access this contract */
      require(IFEAS_platform.accessAllowed(msg.sender) == true, "msg.sender (platform error, EAO_roll)");
      _;
  }

  constructor(address _addrEAS, address _addrEAS_roll, address _addrEAS_types, address _addrEAS_artworks, address _addrEAS_mission, address _addr_EAS_platform, address _addr_EAO) public{
    IFEAS = IF_EAS(_addrEAS);
    IFEAS_roll = IF_EAS_roll(_addrEAS_roll);
    IFEAS_types = IF_EAS_types(_addrEAS_types);
    IFEAS_artworks = IF_EAS_artworks(_addrEAS_artworks);
    IFEAS_platform = IF_EAS_platform(_addr_EAS_platform);
    IFEAO = IF_EAO(_addr_EAO);
  }

  function UpdateIFEAM(address _newIFEAM_addr) public onlyOwner{
    IFEAM = IF_EAM(_newIFEAM_addr);
  }


/************************************************************************************/
/************     ROLL AND MISSION PLAY RELATED ORACLE FUNCTIONS        *************/
/************************************************************************************/
  function PlayRoll(uint32 _type, address _msgSender, uint _msgValue, uint _msgSenderBalance) public platform {

    require(uint(IFEAS_types.GetArtworkTypesPriceInFinny(_type)) * 5 * 10**14 == _msgValue, "playroll, price error");

    if (IFEAO.oraclize_getPrice("WolframAlpha") > _msgSenderBalance) {
      //LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
    } else {
      IFEAO.oraclize_setCustomGasPrice(gasPriceForOracleQuery); // set gas price to 10 Gwei

      bytes32 queryId = IFEAO.oraclize_query("WolframAlpha", "2 unique random numbers between 0 to 100000", gasLimitForOracleQuery);
      // roll tried count ++
      IFEAS_roll.IncreaseRollTried(); 

      emit EventRollQueried(queryId, _msgSender, _type, _msgValue);

      IFEAS_roll.SetPlayRollId(queryId, true);
      IFEAS_roll.SetIdToPlayer(queryId, _msgSender);
      IFEAS_roll.SetIdToBetPrice(queryId, _msgValue);
      IFEAS_roll.SetIdToRollTarget(queryId, _type);
    }
  
  }

  function SetGasPrice(uint price) external onlyOwner{ // default : 5000000000 (5 Gwei)
    gasPriceForOracleQuery = price;
  }

  function SetGasLimit(uint limit) external onlyOwner{ // default : 400000 gas
    gasLimitForOracleQuery = limit;
  }

  function __callback_PlayRoll(bytes32 queryId, string calldata result) external platform{ // get 2 RNs from wolfram alpha, msg.sender == EAO
    uint rn1 = 0;
    uint rn2 = 0;

    strings.slice memory s = result.toSlice();
    strings.slice memory delim = ", ".toSlice();
    s.beyond("{".toSlice()).until("}".toSlice());

    rn1 = IFEAS.parseInt(s.split(delim).toString());

    bool won = (rn1.mod(100) < 50);  // have to less than, not equal
    IFEAS_roll.SetIdToWon(queryId, won);

    EmitEventRollReceived(queryId, uint8(rn1.mod(100)), won);
    // emit EventRoll(IFEAS_roll.GetIdToPlayer(queryId), IFEAS_roll.GetIdToRollTarget(queryId), IFEAS_roll.GetIdToRollProb(queryId), won, rn1, rn2, IFEAS_artworks.GetArtworksLength());
    // have to issue and transfer card here.
    // don't forget to mark into idToWonPrizeTransfered[] mapping variable. prize could be sent multiple times without this flag.

    if(IFEAS_roll.GetIdToWonPrizeTransfered(queryId) != true){

      if(won == true){
        RollWin(queryId);
      }else{
        RollLose(IFEAS_roll.GetIdToRollTarget(queryId), queryId);
      }
      IFEAS_roll.SetIdToWonPrizeTransfered(queryId, true);
    }
  }

  function EmitEventRollReceived(bytes32 queryId, uint8 rn, bool won) internal platform{
    emit EventRollReceived(
      queryId,
      IFEAS_roll.GetIdToPlayer(queryId), 
      IFEAS_roll.GetIdToRollTarget(queryId), 
      rn, 
      won, 
      IFEAS_artworks.GetArtworksLength());
  }


  function RollWin(bytes32 queryId) internal platform returns(bool) {
    // increase owner's artwork count

    address player = IFEAS_roll.GetIdToPlayer(queryId);
    uint32 target = IFEAS_roll.GetIdToRollTarget(queryId);

    IFEAS_artworks.SetOwnerArtworkCount(player, uint32(IFEAS_artworks.ownerArtworkCount(player).add(1)));
    
    uint tokenId = IFEAS_artworks.GetArtworksLength();

    // roll winner count ++
    IFEAS_roll.IncreaseRollWonCount(); 
    
    // card holder count ++
    IFEAS_artworks.UpdateCardHolderCount(player); // card holder count ++

    // Create new card and set       owner, tokenId, typeIndex,    timestamp,   sold (local seq),                       userSellFlag, userPriceInFinny,                   recipeUsed
    IFEAS_artworks.GenerateEtherArt(player, tokenId, target, uint32(now), IFEAS_types.GetArtworkTypesSold(target), false, IFEAS.GetDefaultUserPriceInFinny(), false); // msg.sender == EAO
  
    // tokenId marking for cards management
    IFEAS_artworks.AppendTokenIdToTypeId(target, tokenId);

    // increase supply counter for that type. this will be used in the next line.
    IFEAS_types.SetArtworkTypesSold(target, uint32(IFEAS_types.GetArtworkTypesSold(target).add(1)));
    
    // make copyright fee transaction
    uint artist_copyright_distribute_amount = (uint(IFEAS_types.GetArtworkTypesPriceInFinny(target)) * 10**14); // 10**15 : finny, 10**14 : 10% for copyright fee in finny
    uint marketing_distribute_amount = IFEAS_roll.GetIdToBetPrice(queryId).mul(IFEAS.MARKETING_DISTRIBUTE_RATIO()).div(100);
    uint team_distribute_amount = IFEAS_roll.GetIdToBetPrice(queryId).mul(IFEAS.TEAM_DISTRIBUTE_RATIO()).div(100);

    IFEAO.TransferFund(IFEAS_types.GetArtworkTypesAddressForArtist(target), artist_copyright_distribute_amount);
    IFEAO.TransferFund(IFEAS.ADDRESS_MARKETING(), marketing_distribute_amount);
    IFEAO.TransferFund(IFEAS.ADDRESS_TEAM(), team_distribute_amount);

    ////IFEAS_types.GetArtworkTypesAddressForArtist(target).transfer(artist_copyright_distribute_amount);  
  }


  function RollLose(uint32 _artworkType, bytes32 queryId) internal platform returns(bool) {
    /* make copyright fee transaction */
    uint marketing_distribute_amount = IFEAS_roll.GetIdToBetPrice(queryId).mul(IFEAS.MARKETING_DISTRIBUTE_RATIO()).div(100);
    uint team_distribute_amount = IFEAS_roll.GetIdToBetPrice(queryId).mul(IFEAS.TEAM_DISTRIBUTE_RATIO()).div(100);
    IFEAO.TransferFund(IFEAS.ADDRESS_MARKETING(), marketing_distribute_amount);
    IFEAO.TransferFund(IFEAS.ADDRESS_TEAM(), team_distribute_amount);
    
    //IFEAS.ADDRESS_MARKETING().transfer(marketing_distribute_amount);
    //IFEAS.ADDRESS_TEAM().transfer(team_distribute_amount);
  }



}
