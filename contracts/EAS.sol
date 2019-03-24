pragma solidity >= 0.5.0;
import "./Ownable.sol";
import "./IF_EAS_artworks.sol";
import "./IF_EAS_platform.sol"; 
import "./IF_EAO.sol";
import "./IF_EAO_mission.sol";

contract EAS is Ownable{
  
  uint     public stageNo = 0;
  uint8    public MARKETING_DISTRIBUTE_RATIO = 5;
  address  public ADDRESS_MARKETING = address(0x10CbE0583c643f541E6B631351E533EECb6049E4); // now for testing, real address : 0x2DcCa9B61E50D79A90a813fcD6a42c3A3Ac52e6f;
  uint8    public TEAM_DISTRIBUTE_RATIO = 35;
  address  public ADDRESS_TEAM = address(0x7529498fa97BCfCf8BA50134Dd6298BD4b4B5b3F);      // now for testing.
  uint8    public WINNERS1_DIST_RATIO = 45;
  uint8    public WINNERS2_DIST_RATIO = 35;

  mapping(uint => address)   artworkApprovals;   // transfer(), approve() use this.
  
  uint userMarketExchanged = 0;
  uint32 default_user_price_in_finny = 0; // 0 means "reselling card disabled"
  address EAO_restore_address;
  address EAO_mission_restore_address;

  uint public EAO_FUND_STORED;
  uint public EAO_MISSION_FUND_STORED;
  uint public EAO_FUND_STORED_IN_FINNY;
  uint public EAO_MISSION_FUND_STORED_IN_FINNY;

  IF_EAS_artworks   IFEAS_artworks;
  IF_EAS_platform   IFEAS_platform;
  IF_EAO            IFEAO;
  IF_EAO_mission    IFEAO_mission;

  modifier ownerOfArtwork(uint _index) {
    require(msg.sender == IFEAS_artworks.GetArtworksOwner(_index));
    _;
  }

  modifier platform() {     /* Only EtherArts Platform (EtherArtsOperations contract, EtherArtsStorage contract, Contract owner) can access this contract */
      require(IFEAS_platform.accessAllowed(msg.sender) == true, "msg.sender (platform, EAS)");
      _;
  }

  function() external payable{}
  
  function GetBalance() public view returns(uint){
    return address(this).balance;
  }
/*
  function GetEAOBalanceInFinny() public view returns(uint){
    return EAO_FUND_STORED/(10**15);
  }
  function GetEAOmissionBalanceInFinny() public view returns(uint){
    return EAO_MISSION_FUND_STORED/(10**15);
  }
*/
  function SetEAOFundSaved(uint amount) external platform{
    EAO_FUND_STORED = amount;
    EAO_FUND_STORED_IN_FINNY = amount / (10**15);
  }

  function SetEAOMissionFundSaved(uint amount) external platform{
    EAO_MISSION_FUND_STORED = amount;
    EAO_MISSION_FUND_STORED_IN_FINNY = amount / (10**15);
  }

  function FundRestoreToEAO() external onlyOwner{
    address payable addrTo = address(uint160(EAO_restore_address));
    addrTo.transfer(EAO_FUND_STORED);
    EAO_FUND_STORED = 0;
    EAO_FUND_STORED_IN_FINNY = 0;
  }

  function FundRestoreToEAOMission() external onlyOwner{
    address payable addrTo = address(uint160(EAO_mission_restore_address));
    addrTo.transfer(EAO_MISSION_FUND_STORED);
    EAO_MISSION_FUND_STORED = 0;
    EAO_MISSION_FUND_STORED_IN_FINNY = 0;
  }

  constructor(address _address_EAS_artworks, address _addr_EAS_platform) public {
    IFEAS_artworks = IF_EAS_artworks(_address_EAS_artworks);
    IFEAS_platform = IF_EAS_platform(_addr_EAS_platform);
  }

  function UpdateIFEAO(address _newIFEAO_addr) public onlyOwner{
    IFEAO = IF_EAO(_newIFEAO_addr);
    EAO_restore_address = _newIFEAO_addr;
  }

  function UpdateIFEAO_mission(address _newIFEAO_mission_addr) public onlyOwner{
    IFEAO_mission = IF_EAO_mission(_newIFEAO_mission_addr);
    EAO_mission_restore_address = _newIFEAO_mission_addr;
  }

  function SetStageNo(uint _stageNo) external platform{
    stageNo = _stageNo;
  }
  function GetDefaultUserPriceInFinny() public view returns(uint32){
    return default_user_price_in_finny;
  }
  function SetDefaultUserPriceInFinny(uint32 _priceInFinny) external onlyOwner{
    default_user_price_in_finny = _priceInFinny;
  }
  function IncreaseUserMarketExchanged() public platform{
    
  }

  /***********************************************/
  /*        FOR ERC-721 TRANSFER FUNCTION        */
  /***********************************************/
  function SetArtworkApprovals(uint _tokenId, address _to) external ownerOfArtwork(_tokenId){
    artworkApprovals[_tokenId] = _to;
  }
  function GetArtworkApprovals(uint _tokenId) public view returns(address){
    return artworkApprovals[_tokenId];
  }


  /***********************************************/
  /*  DISTRIBUTION ADDRESS & RATIO INFORMATION   */
  /***********************************************/
  function SetWinner1DistributeRatio(uint8 _newRatio) external onlyOwner{
    WINNERS1_DIST_RATIO = _newRatio;
  }
  function SetWinner2DistributeRatio(uint8 _newRatio) external onlyOwner{
    WINNERS2_DIST_RATIO = _newRatio;
  }
  function SetMarketingDistRatio(uint8 _newRatio) external platform{
    MARKETING_DISTRIBUTE_RATIO = _newRatio;
  }
  function SetTeamDistRatio(uint8 _newRatio) external platform{
    TEAM_DISTRIBUTE_RATIO = _newRatio;
  }
  function SetMarketingAddress(address _newAddr) external platform{
    ADDRESS_MARKETING = _newAddr;
  }
  function SetTeamAddress(address _newAddr) external platform{
    ADDRESS_TEAM = _newAddr;
  }

  //function GetWinner1DistributeRatio() public view returns(uint8){
  //  return WINNERS1_DIST_RATIO;
  //}
  //function GetWinner2DistributeRatio() public view returns(uint8){
  //  return WINNERS2_DIST_RATIO;
  //}
  //function GetMarketingDistRatio() public view returns(uint8){
  //  return MARKETING_DISTRIBUTE_RATIO;
  //}
  //function GetTeamDistRatio() public view returns(uint8){
  //  return TEAM_DISTRIBUTE_RATIO;
  //}
  //function GetMarketingAddress() public view returns(address){
  //  return ADDRESS_MARKETING;
  //}
  //function GetTeamAddress() public view returns(address){
  //  return ADDRESS_TEAM;
  //}



  // return all card's data if _address is equal to address(0)
  function GetCardInfo(address _address) public view returns(uint32[] memory, uint64[] memory, address[] memory, bool[] memory, bool[] memory, uint32[] memory){
    uint length;
    if(_address == address(0x1000000000000000000000000000000000000001)){ 
      length = IFEAS_artworks.GetArtworksLength();
    } else {
      length = IFEAS_artworks.ownerArtworkCount(_address);
    }

    uint32[] memory types = new uint32[](length);
    uint64[] memory cardId = new uint64[](length);
    address[] memory cardOwner = new address[](length);
    bool[] memory cardRecipeUsed = new bool[](length);
    bool[] memory cardUserSellFlag = new bool[](length);
    uint32[] memory cardUserPriceInFinny = new uint32[](length);

    uint userCardIdx = 0;
    for(length = 0; length < IFEAS_artworks.GetArtworksLength(); length++){
      if(_address == IFEAS_artworks.GetArtworksOwner(length) || (_address == address(0x1000000000000000000000000000000000000001))){
        types[userCardIdx] = IFEAS_artworks.GetArtworksType(length);
        cardId[userCardIdx] = IFEAS_artworks.GetArtworksTokenId(length);
        cardOwner[userCardIdx] = IFEAS_artworks.GetArtworksOwner(length);
        cardRecipeUsed[userCardIdx] = IFEAS_artworks.GetArtworksRecipeUsed(length);
        cardUserSellFlag[userCardIdx] = IFEAS_artworks.GetArtworksUserSellFlag(length);
        cardUserPriceInFinny[userCardIdx] = IFEAS_artworks.GetArtworksUserPriceInFinny(length);
        userCardIdx++;
      }
    }
    return (types, cardId, cardOwner, cardRecipeUsed, cardUserSellFlag, cardUserPriceInFinny);
  }



//https://github.com/willitscale/solidity-util/blob/master/lib/Integers.sol
/*
    function parseInt(string memory _value) 
        public
        returns (uint _ret) {
        bytes memory _bytesValue = bytes(_value);
        uint j = 1;
        for(uint i = _bytesValue.length-1; i >= 0 && i < _bytesValue.length; i--) {
            assert(uint(bytes32(_bytesValue[i])) >= 48 && uint(bytes32(_bytesValue[i])) <= 57);
            _ret += (uint(bytes32(_bytesValue[i])) - 48)*j;
            j*=10;
        }
    }
*/
    
//https://github.com/willitscale/solidity-util/blob/master/lib/Integers.sol
    function toString(uint _base) public returns (string memory) {
      
      bytes memory _tmp = new bytes(32);
      uint i;
      for(i = 0;_base > 0;i++) {
          _tmp[i] = byte(uint8((_base % 10) + 48));
          _base /= 10;
      }
      bytes memory _real = new bytes(i--);
      for(uint j = 0; j < _real.length; j++) {
          _real[j] = _tmp[i--];
      }
      return string(_real);
    }

  // parseInt
  function parseInt(string memory _a) public pure returns (uint) {
      return parseInt(_a, 0);
  }

  // parseInt(parseFloat*10^_b)
  function parseInt(string memory _a, uint _b) public pure returns (uint) {
      bytes memory bresult = bytes(_a);
      uint mint = 0;
      bool decimals = false;
      for (uint i=0; i<bresult.length; i++){
          if ((uint8(bresult[i]) >= 48)&&(uint8(bresult[i]) <= 57)){
              if (decimals){
                  if (_b == 0) break;
                  else _b--;
              }
              mint *= 10;
              mint += uint(uint8(bresult[i])) - 48;
          } else if (uint8(bresult[i]) == 46) decimals = true;
      }
      if (_b > 0) mint *= 10**_b;
      return mint;
  }

}