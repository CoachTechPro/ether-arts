pragma solidity >= 0.5.0;
import "./Ownable.sol";
import "./IF_EAS_platform.sol"; 

contract EAS_types is Ownable{
  IF_EAS_platform   IFEAS_platform;

  mapping(uint => uint8[])    public recipeBook;

  struct artworkTypeStruct {
    address addressForArtist;   
    uint32 priceInFinny;  // scale in 1/1000 of ether
    uint32 totalSupply;
    uint32 reserved;
    uint32 sold;
    uint32 maxBounty;
    uint32 RRForArtist;
    bytes32 artworkTitle;
    bytes32 description;
    uint8 cardColor;
  }
  artworkTypeStruct[] artworkTypes;  // was internal


  modifier platform() {     /* Only EtherArts Platform (EtherArtsOperations contract, EtherArtsStorage contract, Contract owner) can access this contract */
      require(IFEAS_platform.accessAllowed(msg.sender) == true, "msg.sender (platform error, EAS_types)");
      _;
  }

  constructor(address _addr_EAS_platform) public{
    IFEAS_platform = IF_EAS_platform(_addr_EAS_platform);
  }

  /* REGISTER NEW TYPE OF CARD */
  //RegisterArtwork(jsonData[type].addressForArtist, jsonData[type].priceInFinny, jsonData[type].totalSupply, jsonData[type].reserved, jsonData[type].maxBounty, jsonData[type].rrForArtist, jsonData[type].title, jsonData[type].description1, cardColorEnum[`${jsonData[type].color}`.toUpperCase()]);
  function RegisterArtwork(address _addressForArtist, uint32 _priceInFinny, uint32 _totalSupply, uint32 _reserved, uint32 _maxBounty, uint32 _RRForArtist, bytes32 _artworkTitle, bytes32 _description, uint8 _cardColor, uint8 _recipe1, uint8 _recipe2) external onlyOwner{ // external onlyOwner
    artworkTypes.push(artworkTypeStruct(_addressForArtist, _priceInFinny, _totalSupply, _reserved, 0, _maxBounty, _RRForArtist, _artworkTitle, _description, _cardColor));
    
    uint typeLength = GetArtworkTypesLength();
    require(typeLength > 0, "Recipe update impossible. No types registered");
    SetRecipeBook(uint32(typeLength)-1, _recipe1, _recipe2);
  }

  function SetRecipeBook(uint32 _type, uint8 _recipe1, uint8 _recipe2) public onlyOwner {
    if(_recipe1 != 0 && _recipe2 != 0){
      delete recipeBook[_type];
      recipeBook[_type].push(_recipe1);
      recipeBook[_type].push(_recipe2);
    }
  }
/*
  function GetRecipeBook(uint32 _type) view public returns (uint8, uint8){
    require(recipeBook[_type].length > 0, "Recipe empty, GetRecipeBook");
    return (recipeBook[_type][0], recipeBook[_type][1]);
  }
*/
  function IsBuyable(uint32 _artworkType) view public returns(bool) {
    if(GetArtworkTypesTotalSupply(_artworkType) - GetArtworkTypesReserved(_artworkType) > GetArtworkTypesSold(_artworkType)){
      if(GetArtworkTypesPriceInFinny(_artworkType) > 0){
        return true;
      }
      else{
        return false;
      }
    }else {
      return false;
    }
  }


  function UpdateArtwork(uint32 _typeNo, uint32 _priceInFinny, uint32 _totalSupply, uint32 _reserved, uint32 _maxBounty, uint8 _cardColor, uint8 _recipe1, uint8 _recipe2, address _addressForArtist, uint32 _RRForArtist, bytes32 _artworkTitle, bytes32 _description) public onlyOwner{
    UpdateArtwork1(_typeNo, _priceInFinny, _totalSupply, _reserved, _maxBounty, _cardColor, _recipe1, _recipe2);
    UpdateArtwork2(_typeNo, _addressForArtist, _RRForArtist, _artworkTitle, _description);
  }

  function UpdateArtwork1(uint32 _typeNo, uint32 _priceInFinny, uint32 _totalSupply, uint32 _reserved, uint32 _maxBounty, uint8 _cardColor, uint8 _recipe1, uint8 _recipe2) internal {
    uint32 uint32Value = GetArtworkTypesPriceInFinny(_typeNo);
    if(uint32Value != _priceInFinny){
      SetArtworkTypesPriceInFinny(_typeNo, _priceInFinny);
    }
    // total supply
    uint32Value = GetArtworkTypesTotalSupply(_typeNo);
    if(uint32Value != _totalSupply){
      SetArtworkTypesTotalSupply(_typeNo, _totalSupply);
    }
    // reserved
    uint32Value = GetArtworkTypesReserved(_typeNo);
    if(uint32Value != _reserved){
      SetArtworkTypesReserved(_typeNo, _reserved);
    }
    // max bounty
    uint32Value = GetArtworkTypesMaxBounty(_typeNo);
    if(uint32Value != _maxBounty){
      SetArtworkTypesMaxBounty(_typeNo, _maxBounty);
    }   
    // cardColor
    uint8 uint8Value1 = GetArtworkTypesCardColor(_typeNo);
    if(uint8Value1 != _cardColor){
      SetArtworkTypesCardColor(_typeNo, _cardColor);
    }

    SetRecipeBook(_typeNo, _recipe1, _recipe2);

  }

  function UpdateArtwork2(uint32 _typeNo, address _addressForArtist, uint32 _RRForArtist, bytes32 _artworkTitle, bytes32 _description) internal {
    address addressForArtist = GetArtworkTypesAddressForArtist(_typeNo);
    if(addressForArtist != _addressForArtist){
      SetArtworkTypesAddressForArtist(_typeNo, _addressForArtist);
    }
    uint32 rrForArtist = GetArtworkTypesRRForArtist(_typeNo);
    if(rrForArtist != _RRForArtist){
      SetArtworkTypesRRForArtist(_typeNo, _RRForArtist);
    }
    bytes32 artworkTitle = GetArtworkTypesArtworkTitle(_typeNo);
    if(artworkTitle != _artworkTitle){
      SetArtworkTypesArtworkTitle(_typeNo, _artworkTitle);
    }
    bytes32 description = GetArtworkTypesDescription(_typeNo);
    if(description != _description){
      SetArtworkTypesDescription(_typeNo, _description);
    }
  }

  /***********************************************/
  /*          ARTWORK-TYPES INTERFACE            */
  /***********************************************/

  function GetArtworkTypesLength() public view returns(uint) {
    return artworkTypes.length;
  }
  function SetArtworkTypesSold(uint _type, uint32 _val) public platform{
    artworkTypes[_type].sold = _val;
  }
  function GetArtworkTypesSold(uint _type) public view returns(uint32){
    require(_type < GetArtworkTypesLength(), "type >= type length");
    return artworkTypes[_type].sold;
  }
  function SetArtworkTypesPriceInFinny(uint _type, uint32 _priceInFinny) public platform{
    artworkTypes[_type].priceInFinny = _priceInFinny;
  }
  function GetArtworkTypesPriceInFinny(uint _type) public view returns(uint32){
    require(_type < GetArtworkTypesLength(), "type >= type length");
    return artworkTypes[_type].priceInFinny;
  }
  function SetArtworkTypesAddressForArtist(uint _type, address _addr) public platform{
    artworkTypes[_type].addressForArtist = _addr;
  }
  function GetArtworkTypesAddressForArtist(uint _type) public view returns(address){
    require(_type < GetArtworkTypesLength(), "type >= type length");
    return artworkTypes[_type].addressForArtist;
  }
  function SetArtworkTypesCardColor(uint _type, uint8 _color) public platform{
    artworkTypes[_type].cardColor = _color;
  }
  function GetArtworkTypesCardColor(uint _type) public view returns(uint8){
    require(_type < GetArtworkTypesLength(), "type >= type length");
    return artworkTypes[_type].cardColor;
  }
  function SetArtworkTypesMaxBounty(uint _type, uint32 _maxBounty) public platform{
    artworkTypes[_type].maxBounty = _maxBounty;
  }
  function GetArtworkTypesMaxBounty(uint _type) public view returns(uint32){
    require(_type < GetArtworkTypesLength(), "type >= type length");
    return artworkTypes[_type].maxBounty;
  }
  function SetArtworkTypesReserved(uint _type, uint32 _reserved) public platform{
    artworkTypes[_type].reserved = _reserved;
  }
  function GetArtworkTypesReserved(uint _type) public view returns(uint32){
    require(_type < GetArtworkTypesLength(), "type >= type length");
    return artworkTypes[_type].reserved;
  }
  function SetArtworkTypesRRForArtist(uint _type, uint32 _rrForArtist) public platform{
    artworkTypes[_type].RRForArtist = _rrForArtist;
  }
  function GetArtworkTypesRRForArtist(uint _type) public view returns(uint32){
    require(_type < GetArtworkTypesLength(), "type >= type length");
    return artworkTypes[_type].RRForArtist;
  }
  function SetArtworkTypesArtworkTitle(uint _type, bytes32 _artworkTitle) public platform{
    artworkTypes[_type].artworkTitle = _artworkTitle;
  }
  function GetArtworkTypesArtworkTitle(uint _type) public view returns(bytes32){
    require(_type < GetArtworkTypesLength(), "type >= type length");
    return artworkTypes[_type].artworkTitle;
  }
  function SetArtworkTypesDescription(uint _type, bytes32 _description) public platform{
    artworkTypes[_type].description = _description;
  }
  function GetArtworkTypesDescription(uint _type) public view returns(bytes32){
    require(_type < GetArtworkTypesLength(), "type >= type length");
    return artworkTypes[_type].description;
  }
  function SetArtworkTypesTotalSupply(uint _type, uint32 _totalSupply) public platform{
    artworkTypes[_type].totalSupply = _totalSupply;
  }
  function GetArtworkTypesTotalSupply(uint _type) public view returns(uint32){
    require(_type < GetArtworkTypesLength(), "type >= type length");
    return artworkTypes[_type].totalSupply;
  }



  /*************************************************************/
  /**                  BATCH GETTER FUNCTIONS                 **/
  /*************************************************************/

  function GetTypePricesInFinny() view public returns(uint32[] memory){
    uint32[] memory priceInFinny = new uint32[](artworkTypes.length);
    for(uint i = 0; i < artworkTypes.length; i++){
      priceInFinny[i] = artworkTypes[i].priceInFinny;
    }
    return priceInFinny;
  }
  function GetTypeAddressForArtist() view public returns(address[] memory){
    address[] memory addressForArtist = new address[](artworkTypes.length);
    for(uint i = 0; i < artworkTypes.length; i++){
      addressForArtist[i] = artworkTypes[i].addressForArtist;
    }
    return addressForArtist;
  }
  function GetTypeTotalSupplies() view public returns(uint32[] memory){
    uint32[] memory totalSupply = new uint32[](artworkTypes.length);
    for(uint i = 0; i < artworkTypes.length; i++){
      totalSupply[i] = artworkTypes[i].totalSupply;
    }
    return totalSupply;
  }
  function GetTypeReserveds() view public returns(uint32[] memory){
    uint32[] memory reserved = new uint32[](artworkTypes.length);
    for(uint i = 0; i < artworkTypes.length; i++){
      reserved[i] = artworkTypes[i].reserved;
    }
    return reserved;
  }
  function GetTypeSolds() view public returns(uint32[] memory){
    uint32[] memory solds = new uint32[](artworkTypes.length);
    for(uint i = 0; i < artworkTypes.length; i++){
      solds[i] = artworkTypes[i].sold;
    }
    return solds;
  }
  function GetTypeMaxBounties() view public returns(uint32[] memory){
    uint32[] memory bounties = new uint32[](artworkTypes.length);
    for(uint i = 0; i < artworkTypes.length; i++){
      bounties[i] = artworkTypes[i].maxBounty;
    }
    return bounties;
  }
 
  function GetTypeRRForArtist() view public returns(uint32[] memory){
    uint32[] memory RRForArtist = new uint32[](artworkTypes.length);
    for(uint i = 0; i < artworkTypes.length; i++){
      RRForArtist[i] = artworkTypes[i].RRForArtist;
    }
    return RRForArtist;
  } 
 
  function GetTypeTitles() view public returns(bytes32[] memory){
    bytes32[] memory artworkTitle = new bytes32[](artworkTypes.length);
    for(uint i = 0; i < artworkTypes.length; i++){
      artworkTitle[i] = artworkTypes[i].artworkTitle;
    }
    return artworkTitle;
  }
  function GetTypeDescriptions() view public returns(bytes32[] memory){
    bytes32[] memory descriptions = new bytes32[](artworkTypes.length);
    for(uint i = 0; i < artworkTypes.length; i++){
      descriptions[i] = artworkTypes[i].description;
    }
    return descriptions;
  }
  function GetTypeCardColors() view public returns(uint8[] memory){
    uint8[] memory cardColors = new uint8[](artworkTypes.length);
    for(uint i=0; i < artworkTypes.length; i++){
      cardColors[i] = artworkTypes[i].cardColor;
    }
    return cardColors;
  }


  function GetTypeInfo() public view returns(uint8[] memory, uint32[] memory, uint32[] memory, uint32[] memory, uint32[] memory, address[] memory){
    return (GetTypeCardColors(),
            GetTypeTotalSupplies(),
            GetTypeSolds(),
            GetTypeReserveds(),
            GetTypePricesInFinny(),
            GetTypeAddressForArtist());
  }
}