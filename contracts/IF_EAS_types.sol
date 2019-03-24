pragma solidity >= 0.5.0;

contract IF_EAS_types{

  mapping(uint => uint8[])    public recipeBook;
  
  /* REGISTER NEW TYPE OF CARD */
  function RegisterArtwork(address _addressForArtist, uint32 _priceInFinny, uint32 _totalSupply, uint32 _reserved, uint32 _maxBounty, uint32 _RRForArtist, bytes32 _artworkTitle, bytes32 _description, uint8 _cardColor, uint8 _recipe1, uint8 _recipe2) external;
  //function GetRecipeBook(uint32 _type) view public returns (uint8, uint8);
  function SetRecipeBook(uint32 _type, uint8 _recipe1, uint8 _recipe2) public;

  function UpdateArtwork(uint32 _typeNo, uint32 _priceInFinny, uint32 _totalSupply, uint32 _reserved, uint32 _maxBounty, uint8 _cardColor, uint8 _recipe1, uint8 _recipe2, address _addressForArtist, uint32 _RRForArtist, bytes32 _artworkTitle, bytes32 _description) public;
  function IsBuyable(uint32 _artworkType) view public returns(bool);
  /***********************************************/
  /*          ARTWORK-TYPES INTERFACE            */
  /***********************************************/
  function GetArtworkTypesLength() public view returns(uint);
  function SetArtworkTypesSold(uint _type, uint32 _val) public;
  function GetArtworkTypesSold(uint _type) public view returns(uint32);
  function SetArtworkTypesPriceInFinny(uint _type, uint32 _priceInFinny) public;
  function GetArtworkTypesPriceInFinny(uint _type) public view returns(uint32);
  function SetArtworkTypesAddressForArtist(uint _type, address _addr) public;
  function GetArtworkTypesAddressForArtist(uint _type) public view returns(address);
  function SetArtworkTypesCardColor(uint _type, uint8 _color) public;
  function GetArtworkTypesCardColor(uint _type) public view returns(uint8);
  function SetArtworkTypesMaxBounty(uint _type, uint32 _maxBounty) public;
  function GetArtworkTypesMaxBounty(uint _type) public view returns(uint32);
  function SetArtworkTypesReserved(uint _type, uint32 _reserved) public;
  function GetArtworkTypesReserved(uint _type) public view returns(uint32);
  function SetArtworkTypesRRForArtist(uint _type, uint32 _rrForArtist) public;
  function GetArtworkTypesRRForArtist(uint _type) public view returns(uint32);
  function SetArtworkTypesArtworkTitle(uint _type, bytes32 _artworkTitle) public;
  function GetArtworkTypesArtworkTitle(uint _type) public view returns(bytes32);
  function SetArtworkTypesDescription(uint _type, bytes32 _description) public;
  function GetArtworkTypesDescription(uint _type) public view returns(bytes32);
  function SetArtworkTypesTotalSupply(uint _type, uint32 _totalSupply) public;
  function GetArtworkTypesTotalSupply(uint _type) public view returns(uint32);


  /*************************************************************/
  /**                  BATCH GETTER FUNCTIONS                 **/
  /*************************************************************/

  function GetTypePricesInFinny() view public returns(uint32[] memory);
  function GetTypeAddressForArtist() view public returns(address[] memory);
  function GetTypeTotalSupplies() view public returns(uint32[] memory);
  function GetTypeReserveds() view public returns(uint32[] memory);
  function GetTypeSolds() view public returns(uint32[] memory);
  function GetTypeMaxBounties() view public returns(uint32[] memory);
 
  function GetTypeRRForArtist() view public returns(uint32[] memory);
  function GetTypeTitles() view public returns(bytes32[] memory);
  function GetTypeDescriptions() view public returns(bytes32[] memory);
  function GetTypeCardColors() view public returns(uint8[] memory);

  function GetTypeInfo() public view returns(uint8[] memory, uint32[] memory, uint32[] memory, uint32[] memory, uint32[] memory, address[] memory);
}