pragma solidity >= 0.5.0;
import "./Ownable.sol";
//import "./IF_EAS_artworks.sol";
import "./IF_EAS_platform.sol"; 

contract EAS_roll is Ownable{

  uint8 constant GREEN = 0;
  uint8 constant OLIVE = 1;
  uint8 constant ORANGE = 2;
  uint8 constant RED = 3;
  uint8 constant GRAY = 4;
  uint8 constant BLUE = 5;
  uint8 constant BROWN = 6;
  uint8 constant WINE = 7;
  uint8 constant INDIGO = 8;
  uint8 constant ROSYBROWN = 9;
  uint8 constant AMBER = 10;
  uint8 constant SILVER = 11;
  uint8 constant GOLD = 12;
  uint8 constant EMERALD = 13;
  uint8 constant SAPPHIRE = 14;
  uint8 constant RUBY = 15;
  uint8 constant DIAMOND = 16;

  uint public rollTried = 0;
  uint public rollWonCount = 0;


  //mapping(uint => uint) rollWinnerCount;    // usage : rollWinnerCount[RED] = rollWinnerCount[RED].add(1);
  mapping(bytes32=>address payable) internal idToPlayer;
  mapping(bytes32=>uint32) internal idToRollTarget;
  mapping(bytes32=>bool) internal idToWon;
  mapping(bytes32=>bool) internal idToWonPrizeTransfered;
  mapping(bytes32=>uint) internal idToBetPrice;
  mapping(bytes32=>bool) internal playRollId;  // for oraclize query identification

  IF_EAS_platform   IFEAS_platform;

  modifier platform() {     /* Only EtherArts Platform (EtherArtsOperations contract, EtherArtsStorage contract, Contract owner) can access this contract */
      require(IFEAS_platform.accessAllowed(msg.sender) == true, "msg.sender (Platform error, EAS_roll");
      _;
  }

  constructor(address _addr_EAS_platform) public{
    IFEAS_platform = IF_EAS_platform(_addr_EAS_platform);
  }



 /***********************************************/
  /*              MAPPING INTERFACE              */
  /***********************************************/

  function SetIdToPlayer(bytes32 _id, address payable _player) external platform {
    idToPlayer[_id] = _player;
  }
  function GetIdToPlayer(bytes32 _id) public view returns(address payable){
    return idToPlayer[_id];
  }
  function SetIdToWon(bytes32 _id, bool _result) external platform {
    idToWon[_id] = _result;
  }
  function GetIdToWon(bytes32 _id) public view returns(bool){
    return idToWon[_id];
  }

  function SetIdToRollTarget(bytes32 _id, uint32 _target) external platform{
    idToRollTarget[_id] = _target;
  }
  function GetIdToRollTarget(bytes32 _id) public view returns(uint32){
    return idToRollTarget[_id];
  }
  function SetIdToWonPrizeTransfered(bytes32 _id, bool _transfered) external platform{
    idToWonPrizeTransfered[_id] = _transfered;
  }
  function GetIdToWonPrizeTransfered(bytes32 _id) public view returns(bool){
    return idToWonPrizeTransfered[_id];
  }
  function SetIdToBetPrice(bytes32 _id, uint _betPrice) external platform{
    idToBetPrice[_id] = _betPrice;
  }
  function GetIdToBetPrice(bytes32 _id) public view returns(uint){
    return idToBetPrice[_id];
  }
  function SetPlayRollId(bytes32 _id, bool _val) external platform{
    playRollId[_id] = _val;
  }
  function GetPlayRollId(bytes32 _id) public view returns(bool){
    return playRollId[_id];
  }


  /***********************************************/
  /*         ROLL PARAMETERS INTERFACE           */
  /***********************************************/

  function IncreaseRollTried() external platform {
    rollTried = rollTried + 1;
  }
  function IncreaseRollWonCount() external platform {
    rollWonCount = rollWonCount + 1;
  }



}