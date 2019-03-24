pragma solidity >= 0.5.0;
import "./Ownable.sol";
import "./IF_EAS_platform.sol"; 

contract EAS_artworks is Ownable{

  IF_EAS_platform   IFEAS_platform;

  uint public cardHolderCount = 0;
  uint public buyTried = 0;

  mapping(address  => uint32) public ownerArtworkCount;  // saves the number of artworks for each user(address)
  mapping(uint32 => uint[])   public tokenIds;           // type --> token IDs
  mapping(uint => string)     public tokenURIs;          // tokenId to URI

  struct singleArtwork {
    address owner;
    uint tokenId;       // card global seq ID (All-EtherArts' global sequence) 
    uint32 typeIndex;   // picture number
    uint32 timestamp;   // salt for generate random numbers
    uint64 localSeq;    // card local seq ID (same picture cards)
    bool userSellFlag;  // Ether-Arts' user marketplace sell flag
    uint32 userPriceInFinny;   // user's wanted price for user market
    bool recipeUsed;
  }
  singleArtwork[] public artworks;  // was internal
  
  modifier ownerOfArtwork(uint _id /* artworks seq no */) {
    require(msg.sender == GetArtworksOwner(_id), "msg.sender (ownerOfArtwork error, EAS_artwork)");
    _;
  }

  modifier platform() {     /* Only EtherArts Platform (EtherArtsOperations contract, EtherArtsStorage contract, Contract owner) can access this contract */
      require(IFEAS_platform.accessAllowed(msg.sender) == true, "msg.sender (platform error, EAS_artworks)");
      _;
  }

  constructor(address _addr_EAS_platform) public{
    IFEAS_platform = IF_EAS_platform(_addr_EAS_platform);
  }




  /* GENERATE AN INSTANCE OF CARD */
  function GenerateEtherArt(address _player, uint _tokenId, uint32 _typeIndex, uint32 _timestamp, uint64 _localSeq, bool _userSellFlag, uint32 _userPriceInFinny, bool _recipeUsed) external platform{
    // add some protection
    artworks.push(singleArtwork(_player, _tokenId, _typeIndex, _timestamp, _localSeq, _userSellFlag, _userPriceInFinny, _recipeUsed));
  }


  /***********************************************/
  /*             ARTWORKS INTERFACE              */
  /***********************************************/
  
  function ResetUserParameters(uint _cardId) public platform {
    SetArtworksUserSellFlag(_cardId, false);
    SetArtworksUserPriceInFinny(_cardId, 0);
  }

  function SetUserItem(uint _cardId, uint32 _userPriceInFinny) public ownerOfArtwork(_cardId) returns(bool){
    if(_userPriceInFinny == 0){
      SetArtworksUserSellFlag(_cardId, false);
    }else{
      SetArtworksUserSellFlag(_cardId, true);
      SetArtworksUserPriceInFinny(_cardId, _userPriceInFinny);
    }
  }

  function SetTokenURI(uint _cardId, string calldata _URI) external platform{
    tokenURIs[_cardId] = _URI;
  }
/*
  function GetTokenURI(uint _cardId) public view returns(string memory){
    return tokenURIs[_cardId];
  }
*/
  function IncreaseBuyTried() external platform{
    buyTried = buyTried + 1;
  }
  function UpdateCardHolderCount(address _player) external platform{
    if(ownerArtworkCount[_player] < 1){
      cardHolderCount = cardHolderCount + 1;
    }
  }

/*
  function GetOwnerArtworkCount(address _owner) public view returns(uint32){
    return ownerArtworkCount[_owner];
  }
*/
  function SetOwnerArtworkCount(address _owner, uint32 _val) public platform{
    ownerArtworkCount[_owner] = _val;
  }
  function GetArtworksLength() public view returns(uint){
    return artworks.length;
  }
  function SetArtworksOwner(uint _idx, address _owner) external platform{
    require(_idx >= 0 && _idx <artworks.length, "Index out of range, SetArtworksOwner");
    artworks[_idx].owner = _owner;
  }
  function GetArtworksOwner(uint _idx) public view returns(address){
    require(_idx >= 0 && _idx <artworks.length, "Index out of range, GetArtworksOwner");
    return artworks[_idx].owner;
  }
  function GetArtworksType(uint _idx) public view returns(uint32){
    require(_idx >= 0 && _idx <artworks.length, "Index out of range, GetArtworksType");
    return artworks[_idx].typeIndex;
  }
  function SetArtworksUserSellFlag(uint _idx, bool _val) internal{
    require(_idx >= 0 && _idx <artworks.length, "Index out of range, SetArtworksUserSellFlag");
    artworks[_idx].userSellFlag = _val;
  }
  function GetArtworksUserSellFlag(uint _idx) public view returns(bool){
    require(_idx >= 0 && _idx <artworks.length, "Index out of range, GetArtworksUserSellFlag");
    return artworks[_idx].userSellFlag;
  }

  function SetArtworksUserPriceInFinny(uint _idx, uint32 _priceInFinny) internal{
    require(_idx >= 0 && _idx <artworks.length, "Index out of range, SetArtworksUserPriceInFinny");
    artworks[_idx].userPriceInFinny = _priceInFinny;
  }
  function GetArtworksUserPriceInFinny(uint _idx) public view returns(uint32){
    require(_idx >= 0 && _idx <artworks.length, "Index out of range, GetArtworksUserPriceInFinny");
    return artworks[_idx].userPriceInFinny;
  }

  function GetArtworksTimestamp(uint _idx) public view returns(uint32){
    require(_idx >= 0 && _idx <artworks.length, "Index out of range, GetArtworksTimestamp");
    return artworks[_idx].timestamp;
  }
  function SetArtworksRecipeUsed(uint _idx) external platform{
    require(_idx >= 0 && _idx <artworks.length, "Index out of range, SetArtworksRecipeUsed");
    artworks[_idx].recipeUsed = true;
  }
  function GetArtworksRecipeUsed(uint _idx) public view returns(bool){
    require(_idx >= 0 && _idx <artworks.length, "Index out of range, GetArtworksRecipeUsed");
    return artworks[_idx].recipeUsed;
  }

  function GetArtworksTokenId(uint _idx) view public returns(uint64){ // external onlyOwner
  require(_idx >= 0 && _idx <artworks.length, "Index out of range, GetArtworksTokenId");
    return uint64(artworks[_idx].tokenId);
  }
/*
  function GetArtworksLocalSeq(uint _idx) view public returns(uint64){   // external onlyOwner
  require(_idx >= 0 && _idx <artworks.length, "Index out of range, GetArtworksLocalSeq");
    return artworks[_idx].localSeq;
  }
*/
  /*****************************************************/
  /*             ARTWORKS BATCH INTERFACE              */
  /*****************************************************/
  
  function GetAllArtworksOwner() public view returns(address[]  memory){
    address[] memory owners = new address[](GetArtworksLength());
    for(uint k=0; k<GetArtworksLength(); k++){
      owners[k] = artworks[k].owner;
    }
    return owners;
  }
  function GetAllArtworksType() public view returns(uint32[] memory){
    uint32[] memory types = new uint32[](GetArtworksLength());
    for(uint k=0; k<GetArtworksLength(); k++){
      types[k] = artworks[k].typeIndex;
    }
    return types;
  }
  function GetAllArtworksUserSellFlag() public view returns(bool[] memory){
    bool[] memory userSellFlag = new bool[](GetArtworksLength());
    for(uint k=0; k<GetArtworksLength(); k++){
      userSellFlag[k] = artworks[k].userSellFlag;
    }
    return userSellFlag;
  }
  function GetAllArtworksUserPriceInFinny() public view returns(uint32[] memory){
    uint32[] memory userPriceInFinny = new uint32[](GetArtworksLength());
    for(uint k=0; k<GetArtworksLength(); k++){
      userPriceInFinny[k] = artworks[k].userPriceInFinny;
    }
    return userPriceInFinny;
  }
  function GetAllArtworksRecipeUsed() public view returns(bool[] memory){
    bool[] memory recipeUsed = new bool[](GetArtworksLength());
    for(uint k=0; k<GetArtworksLength(); k++){
      recipeUsed[k] = artworks[k].recipeUsed;
    }
    return recipeUsed;
  }
  function GetAllArtworksLocalSeq() public view returns(uint64[] memory){   // external onlyOwner
    uint64[] memory localSeq = new uint64[](GetArtworksLength());
    for(uint k=0; k<GetArtworksLength(); k++){
      localSeq[k] = artworks[k].localSeq;
    }
    return localSeq;
  }



  /*************************************************************/
  /**                    TYPE TO ARTWORKS#                    **/
  /*************************************************************/

  function GetTypeLength(uint32 _typeId) public view returns(uint){
    return tokenIds[_typeId].length;
  }

  function GetTokenId(uint32 _typeId, uint _index) public view returns(uint){
    require(_index < tokenIds[_typeId].length, "_index out of range");
    return tokenIds[_typeId][_index];
  }

  function AppendTokenIdToTypeId(uint32 _typeId, uint _value) external platform{
    for(uint k = 0; k<GetTypeLength(_typeId); k++){
        if(GetTokenId(_typeId, k) == _value){
            revert("tokenIds[].push error");
        }
    }
    tokenIds[_typeId].push(_value);
  }

  function GetTokenIdFromType(uint32 _type) public view returns(uint[] memory){
    return tokenIds[_type];
  }

  function GetAllOwnersOfType(uint32 _typeId) public view returns(address[] memory){
    address[] memory ownersAddress = new address[](GetTypeLength(_typeId));
    for(uint k = 0; k<GetTypeLength(_typeId); k++)
        ownersAddress[k] = GetArtworksOwner(GetTokenId(_typeId, k));
    return ownersAddress;
  }


  function GetAllRecipeUsedOfType(uint32 _type) public view returns(bool[] memory){
    bool[] memory recipeUsed = new bool[](GetTypeLength(_type));
    for(uint k=0; k<GetTypeLength(_type); k++){
      recipeUsed[k] = GetArtworksRecipeUsed(GetTokenId(_type, k));
    }
    return recipeUsed;
  }

  function GetAllUserPricesOfType(uint32 _typeId) public view returns(uint[] memory){
    uint[] memory priceInFinny = new uint[](GetTypeLength(_typeId));
    
    for(uint k = 0; k<GetTypeLength(_typeId); k++){
      uint tokenId = GetTokenId(_typeId, k);
      
      bool sellFlag = GetArtworksUserSellFlag(tokenId);
      uint price = GetArtworksUserPriceInFinny(tokenId);
      if(sellFlag == true){
        priceInFinny[k] = price;
      }else{
        priceInFinny[k] = 0;
      }
    }
    return priceInFinny;
  }

}