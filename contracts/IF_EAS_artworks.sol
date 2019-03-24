pragma solidity >= 0.5.0;

contract IF_EAS_artworks{
 
  uint public cardHolderCount = 0;
  uint public buyTried = 0;

  mapping(address  => uint32) public ownerArtworkCount;  // saves the number of artworks for each user(address)
  mapping(uint32 => uint[])   public tokenIds;           // type --> token IDs
  mapping(uint => string)     public tokenURIs;          // tokenId to URI

  //function allowAccess(address _address) public;
  //function denyAccess(address _address) public;
  //function GetAllAddressesAllowed() public returns (address[] memory);

  /* GENERATE AN INSTANCE OF CARD */
  function GenerateEtherArt(address _player, uint _tokenId, uint32 _typeIndex, uint32 _timestamp, uint64 _localSeq, bool _userSellFlag, uint32 _userPriceInFinny, bool _recipeUsed) external;
  
  /***********************************************/
  /*             ARTWORKS INTERFACE              */
  /***********************************************/

  function ResetUserParameters(uint _cardId) public;
  function SetUserItem(uint _cardId, uint32 _userPriceInFinny) public returns(bool);
  function SetTokenURI(uint _cardId, string calldata _URI) external;
  //function GetTokenURI(uint _cardId) public view returns(string memory);
  function SetOwnerArtworkCount(address _owner, uint32 _val) public;
  //function GetOwnerArtworkCount(address _owner) public view returns(uint32);
  
  // variable getter/setter for individual artwork
  function GetArtworksLength() public view returns(uint);
  function SetArtworksOwner(uint _idx, address _owner) external;
  function GetArtworksOwner(uint _idx) public view returns(address);
  //function SetArtworksType(uint _idx, uint32 _type);
  function GetArtworksType(uint _idx) public view returns(uint32);
  function SetArtworksUserSellFlag(uint _idx, bool _val) internal;
  function GetArtworksUserSellFlag(uint _idx) public view returns(bool);
  function SetArtworksUserPriceInFinny(uint _idx, uint32 _priceInFinny) internal;
  function GetArtworksUserPriceInFinny(uint _idx) public view returns(uint32);
  //function SetArtworksTimestamp(uint _idx, uint32 _timestamp);
  function GetArtworksTimestamp(uint _idx) public view returns(uint32);
  function SetArtworksRecipeUsed(uint _idx) external;
  function GetArtworksRecipeUsed(uint _idx) public view returns(bool);
  //function SetArtworksTokenId(uint _idx, uint _tokenId) returns(uint);
  function GetArtworksTokenId(uint _idx) public view returns(uint64);
  //function GetArtworksLocalSeq(uint _idx) public view returns(uint64);


  // batch loading
  function GetAllArtworksOwner() public view returns(address[] memory);
  function GetAllArtworksType() public view returns(uint32[] memory);
  function GetAllArtworksUserSellFlag() public view returns(bool[] memory);
  function GetAllArtworksUserPriceInFinny() public view returns(uint32[] memory);
  function GetAllArtworksRecipeUsed() public view returns(bool[] memory);
  function GetAllArtworksLocalSeq() public view returns(uint64[] memory);


  function GetTokenIdFromType(uint32 _type) public view returns(uint[] memory);
  function GetTypeLength(uint32 _typeId) public view returns(uint);
  function GetTokenId(uint32 _typeId, uint _index) public view returns(uint);
  function GetAllOwnersOfType(uint32 _typeId) public view returns(address[] memory);
  function GetAllRecipeUsedOfType(uint32 _type) public view returns(bool[] memory);
  function GetAllUserPricesOfType(uint32 _typeId) public view returns(uint[] memory);
  function AppendTokenIdToTypeId(uint32 _typeId, uint _value) external;
  
  function UpdateCardHolderCount(address _addr) external;
  function IncreaseBuyTried() external;
  //function AddBountyInfo(uint _type, uint _tokenId) external;
  //function AddSpecialCardInfo(address _address, uint _targetCardType, uint _id1, uint _id2, uint _tokenId) public;

  //function GetUserCards(address _address) public view returns(uint32[] memory, uint64[] memory);
}