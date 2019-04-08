pragma solidity >= 0.5.0;

import "./Ownable.sol";
import "./SafeMath.sol";

import "./IF_EAS_artworks.sol";
import "./IF_EAS_types.sol";
import "./IF_EAS.sol";
import "./IF_EAS_platform.sol"; 
import "./IF_EAO_roll.sol";

contract EAM is Ownable{
  
  using SafeMath for uint32;
  string public name = "ETHERARTS";
  string public symbol = "EAC";

  IF_EAS_artworks   IFEAS_artworks;
  IF_EAS_types      IFEAS_types;
  IF_EAS            IFEAS;
  IF_EAS_platform   IFEAS_platform;


  //event EventBuyArtwork(address indexed player, uint32 indexed target, string indexed transactionHash);
  event GenerateBounty(address indexed _address, uint indexed artworksId, uint32 indexed _artworkType);
  event EventSpecialCardClaimed(address indexed _address, uint indexed _targetCardType, uint _id1, uint _id2);

  modifier recipeReady(uint _index) {
    require(msg.sender == IFEAS_artworks.GetArtworksOwner(_index), "msg.sender (recipeReady  error, EAM)");
    require(IFEAS_artworks.GetArtworksRecipeUsed(_index) == false, "special card already claimed, EAM");
    _;
  }

  modifier ownerOfArtwork(uint _index) {
    require(msg.sender == IFEAS_artworks.GetArtworksOwner(_index), "msg.sender (ownerOfArtwork error, EAM)");
    _;
  }

  modifier platform() {     /* Only EtherArts Platform (EtherArtsOperations, EtherArtsStorage, EtherArtsOracle, Contract owner) can access this contract */
    require(IFEAS_platform.accessAllowed(msg.sender) == true, "(platform error, EAM)");
    _;
  }

  constructor(address _addrEAS, address _addrEAS_types, address _addrEAS_artworks, address _addr_EAS_platform) public{
    IFEAS = IF_EAS(_addrEAS);
    IFEAS_types = IF_EAS_types(_addrEAS_types);
    IFEAS_artworks = IF_EAS_artworks(_addrEAS_artworks);
    IFEAS_platform = IF_EAS_platform(_addr_EAS_platform);
  }



/************************************************************************************/
/************               ERC-721 common interfaces here              *************/
/************************************************************************************/

  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

  function balanceOf(address _owner) public view returns (uint256 _balance) {
    return IFEAS_artworks.ownerArtworkCount(_owner); //ownerArtworkCount[_owner];
  }

  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
    return IFEAS_artworks.GetArtworksOwner(_tokenId); //artworks[_tokenId].owner;
  }

  function _transfer(address _from, address _to, uint256 _tokenId) private {
    require(IFEAS_artworks.GetArtworksUserSellFlag(_tokenId) == false); // if it is not registered on the user sell market.
    
    // card holder count ++
    IFEAS_artworks.UpdateCardHolderCount(_to); // card holder count ++ if it is new user.
    IFEAS_artworks.SetOwnerArtworkCount(_to, uint32(IFEAS_artworks.ownerArtworkCount(_to).add(1)));
    IFEAS_artworks.SetOwnerArtworkCount(_from, uint32(IFEAS_artworks.ownerArtworkCount(_from).sub(1)));
    IFEAS_artworks.SetArtworksOwner(_tokenId, _to);
    IFEAS_artworks.UpdateArtworksTimestampLastTransfer(_tokenId);
    emit Transfer(_from, _to, _tokenId);
  }

  function transfer(address _to, uint256 _tokenId) public ownerOfArtwork(_tokenId) {
    _transfer(msg.sender, _to, _tokenId);
  }

  // seller have to approve the change of ownership to certain address before buyer calls takeOwnership() function
  function approve(address _to, uint256 _tokenId) public ownerOfArtwork(_tokenId) {
    IFEAS.SetArtworkApprovals(_tokenId, _to);
    emit Approval(msg.sender, _to, _tokenId);
  }

  // buyer or acquiror have to call this function, after the seller's approve() function.
  function takeOwnership(uint256 _tokenId) public {
    require(IFEAS.GetArtworkApprovals(_tokenId) == msg.sender);
    address owner = ownerOf(_tokenId);
    _transfer(owner, msg.sender, _tokenId);
  }

  function setTokenURI(uint _tokenId, string memory _URI) public platform {
    IFEAS_artworks.SetTokenURI(_tokenId, _URI);
  }
  
  function totalSupply() public view returns (uint256) {
    return IFEAS_artworks.GetArtworksLength();
  }


/************************************************************************************/
/************             CARD GENERATION related functions             *************/
/************************************************************************************/
  
  function GenerateBountyToken(uint32 _artworkType /* start from 0 */, address _address) public onlyOwner returns(bool) {
    require(_artworkType >= 0);
    require(_artworkType < IFEAS_types.GetArtworkTypesLength());
    require(IFEAS_types.GetArtworkTypesMaxBounty(_artworkType) > 0);
    
    // card holder count ++
    IFEAS_artworks.UpdateCardHolderCount(_address); // card holder count ++

    // increase owner's artwork count
    IFEAS_artworks.SetOwnerArtworkCount(_address, uint32(IFEAS_artworks.ownerArtworkCount(_address).add(1)));

    // decrease artworkType's maxBounty field. if it is set zero, no more bounty token could be generated in this type. default value is ranging from 0-2 for all types.
    IFEAS_types.SetArtworkTypesMaxBounty(_artworkType, uint32(IFEAS_types.GetArtworkTypesMaxBounty(_artworkType).sub(1)));

    uint tokenId = IFEAS_artworks.GetArtworksLength();

    // Create new card and set         owner, tokenId, typeIndex,    creat/transaction time, 4:Bounty, localSeq,                    userSellFlag, userPriceInFinny,            recipeUsed
    IFEAS_artworks.GenerateEtherArt(_address, tokenId, _artworkType, block.timestamp, 4, IFEAS_types.GetArtworkTypesSold(_artworkType), false, IFEAS.GetDefaultUserPriceInFinny(), false);

    //IFEAS_artworks.AddBountyInfo(uint(_artworkType), tokenId);

    // tokenId marking for cards management
    IFEAS_artworks.AppendTokenIdToTypeId(_artworkType, tokenId);

    // increase supply counter for that type.
    IFEAS_types.SetArtworkTypesSold(_artworkType, uint32(IFEAS_types.GetArtworkTypesSold(_artworkType).add(1)));

    emit GenerateBounty(_address, uint(IFEAS_artworks.GetArtworksLength()), _artworkType);
    //transferartwork(_artworkID, msg.sender);
  }



  /* Claim Special Card */
  function ClaimSpecialCard(uint _targetCardType, uint _id1, uint _id2) public recipeReady(_id1) recipeReady(_id2){
    require(_targetCardType < IFEAS_types.GetArtworkTypesLength());
    require(IFEAS_types.GetArtworkTypesCardColor(_targetCardType) >= 10, "Special cards must >= 10(AMBER).");
    require(IFEAS_types.GetArtworkTypesTotalSupply(_targetCardType) > IFEAS_types.GetArtworkTypesReserved(_targetCardType) + IFEAS_types.GetArtworkTypesSold(_targetCardType));
  
    // card holder count ++
    IFEAS_artworks.UpdateCardHolderCount(msg.sender); // card holder count ++

    // increase owner's artwork count
    IFEAS_artworks.SetOwnerArtworkCount(msg.sender, uint32(IFEAS_artworks.ownerArtworkCount(msg.sender).add(1)));  //platform

    uint tokenId = IFEAS_artworks.GetArtworksLength();

    IFEAS_artworks.SetArtworksRecipeUsed(_id1); //platform
    IFEAS_artworks.SetArtworksRecipeUsed(_id2); //platform

    // Create new card and set           owner, tokenId, typeIndex,               timestamp,   6: special card claim, localSeq,                     userSellFlag, userPriceInFinny,            recipeUsed
    IFEAS_artworks.GenerateEtherArt(msg.sender, tokenId, uint32(_targetCardType), block.timestamp, 6, IFEAS_types.GetArtworkTypesSold(_targetCardType), false, IFEAS.GetDefaultUserPriceInFinny(), false);

    // tokenId marking for cards management
    IFEAS_artworks.AppendTokenIdToTypeId(uint32(_targetCardType), tokenId); //platform

    // increase supply counter for that type.
    IFEAS_types.SetArtworkTypesSold(_targetCardType, uint32(IFEAS_types.GetArtworkTypesSold(_targetCardType).add(1)));

    emit EventSpecialCardClaimed(msg.sender, _targetCardType, _id1, _id2);
    //transferartwork(_artworkID, msg.sender);
  }


  /*************************************************************/
  /**                  MISC FUNCTIONS                         **/
  /*************************************************************/

  /* This function is optimized for the reply of Wolfram alpha, though oraclize interface. */
  function SplitNumbers(string memory _base, string memory _value) public returns (uint, uint) {
      bytes memory _baseBytes = bytes(_base);
      uint _offset = 0;
      uint[] memory RNs;
      uint rnCnt = 0;
      while(_offset < _baseBytes.length) {  // eliminate the curly braces '{}'
          int _limit = IndexOf(_base, _value, _offset);
          if (_limit == -1) {
              _limit = int(_baseBytes.length);
          }
          string memory _tmp = new string(uint(_limit)-_offset);
          bytes memory _tmpBytes = bytes(_tmp);

          uint j = 0;
          for(uint i = _offset; i < uint(_limit); i++) {
            //if(_baseBytes[i] != " "){ // adds this line to eliminate space ' '
              _tmpBytes[j++] = _baseBytes[i];
            //}
          }
          _offset = uint(_limit) + 1;
          RNs[rnCnt++] = (IFEAS.parseInt(string(_tmpBytes)));
      }
      return (RNs[0], RNs[1]);
  }
  
  function Length(string memory _base) public returns (uint) {
      bytes memory _baseBytes = bytes(_base);
      return _baseBytes.length;
  }
  function IndexOf(string memory _base, string memory _value, uint _offset) public returns (int) {
      bytes memory _baseBytes = bytes(_base);
      bytes memory _valueBytes = bytes(_value);
      assert(_valueBytes.length == 1);
      for(uint i = _offset; i < _baseBytes.length; i++) {
          if (_baseBytes[i] == _valueBytes[0]) {
              return int(i);
          }
      }
      return -1;
  }



}