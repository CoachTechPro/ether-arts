pragma solidity >= 0.5.0;
import "./Ownable.sol";
import "./SafeMath.sol";

import "./IF_EAS_types.sol";
import "./IF_EAS_artworks.sol";
import "./IF_EAS_platform.sol"; 

contract EAS_mixedQuery is Ownable{

  using SafeMath for uint256;
      
  mapping(address => bool)    accessAllowed;
  address[] platformAddressList;

  IF_EAS_types    IFEAS_types;
  IF_EAS_artworks IFEAS_artworks;
  IF_EAS_platform   IFEAS_platform;

  modifier ownerOfArtwork(uint _index) {
    require(msg.sender == IFEAS_artworks.GetArtworksOwner(_index), "msg.sender (ownerOfArtwork error, EAS_mixedQuery)");
    _;
  }

  modifier platform() {     /* Only EtherArts Platform (EtherArtsOperations contract, EtherArtsStorage contract, Contract owner) can access this contract */
      require(IFEAS_platform.accessAllowed(msg.sender) == true, "msg.sender (platform error, EAS_mixedQuery)");
      _;
  }

  constructor(address _address_IF_EAS_types, address _address_IF_EAS_artworks, address _addr_EAS_platform) public{
    IFEAS_platform = IF_EAS_platform(_addr_EAS_platform);
    IFEAS_types = IF_EAS_types(_address_IF_EAS_types);
    IFEAS_artworks = IF_EAS_artworks(_address_IF_EAS_artworks);
  }

  /*************************************************************/
  /**          FUNCTIONS DEAL WITH SPECIFIC "TYPE"            **/
  /*************************************************************/

  // filtered userPrice only for specified type,  (_type : starts from 0)
  function GetUserSellFlagsOfType(uint32 _type) view external returns(bool[] memory){
    bool[] memory userSellFlags = new bool[](IFEAS_types.GetArtworkTypesSold(_type));
    uint j = 0;
    for(uint i = 0; i < IFEAS_artworks.GetArtworksLength(); i++){
      if(IFEAS_artworks.GetArtworksType(i) == _type){
        if(IFEAS_artworks.GetArtworksUserSellFlag(i) == true){
          userSellFlags[j] = true;
        }else{
          userSellFlags[j] = false;  // NOT SET
        }
        j = j.add(1);
      }
    }
    return userSellFlags;
  }

  // filtered userPrice only for specified type,  (_type : starts from 0)
  function GetUserSellPricesOfType(uint32 _type) view external returns(uint32[] memory){
    uint32[] memory userPriceInFinny = new uint32[](IFEAS_types.GetArtworkTypesSold(_type));
    uint j = 0;
    for(uint i = 0; i < IFEAS_artworks.GetArtworksLength(); i++){
      if(IFEAS_artworks.GetArtworksType(i) == _type){
        if(IFEAS_artworks.GetArtworksUserSellFlag(i) == true){
          userPriceInFinny[j] = (IFEAS_artworks.GetArtworksUserPriceInFinny(i));
        }else{
          userPriceInFinny[j] = 0;  // NOT SET
        }
        j = j.add(1);
      }
    }
    return userPriceInFinny;
  }

  // filtered ownerAddress only for specified type, (_type : starts from 0)
  function GetOwnersOfType(uint32 _type) view external returns(address[] memory){
    address[] memory ownerAddress = new address[](IFEAS_types.GetArtworkTypesSold(_type));
    uint j = 0;
    for(uint i = 0; i < IFEAS_artworks.GetArtworksLength(); i++){
      if(IFEAS_artworks.GetArtworksType(i) == _type){
        ownerAddress[j] = IFEAS_artworks.GetArtworksOwner(i);
        j = j.add(1);
      }
      if(j == IFEAS_types.GetArtworkTypesSold(_type))
        return ownerAddress;
    }
    return ownerAddress;
  }

  // returns card numbers for each player who has "_type" cards(owners of _type card),  (_type : starts from 0)
  function GetNumCardsWhoOwnsType(uint32 _type) view external returns(uint32[] memory){
    uint32[] memory numCards = new uint32[](IFEAS_types.GetArtworkTypesSold(_type));
    uint j = 0;
    for(uint i = 0; i < IFEAS_artworks.GetArtworksLength(); i++){
      if(IFEAS_artworks.GetArtworksType(i) == _type){
        address ownerAddress = (IFEAS_artworks.GetArtworksOwner(i));
        numCards[j] = IFEAS_artworks.ownerArtworkCount(ownerAddress);
        j = j.add(1);
      }
      if(j == IFEAS_types.GetArtworkTypesSold(_type))
        return numCards;
    }
    return numCards;
  }


  function GetRecipeUsedsOfType(uint32 _type) view external returns(bool[] memory){
    bool[] memory recipeUseds = new bool[](IFEAS_types.GetArtworkTypesSold(_type));
    uint j = 0;
    for(uint i = 0; i < IFEAS_artworks.GetArtworksLength(); i++){
      if(IFEAS_artworks.GetArtworksType(i) == _type){
        recipeUseds[j] = IFEAS_artworks.GetArtworksRecipeUsed(i);
        j = j.add(1);
      }
      if(j == IFEAS_types.GetArtworkTypesSold(_type))
        return recipeUseds;
    }
    return recipeUseds;
  }



/**************************************************************************/
/************     FUNCTIONS DEAL WITH SPECIFIC "ADDRESS"      *************/
/**************************************************************************/

  function GetArtworkIndexesOfAddress(address _addr) view external returns(uint32[] memory){
    uint32[] memory ownedArtworks = new uint32[](IFEAS_artworks.ownerArtworkCount(_addr));
    uint i = 0; uint j = 0;

    for(i = 0; i < IFEAS_artworks.GetArtworksLength(); i++){
      if(IFEAS_artworks.GetArtworksOwner(i) == _addr){
        ownedArtworks[j] = uint32(i); // artwork index
        j = j.add(1);
        if(j >= IFEAS_artworks.ownerArtworkCount(_addr)){
          return ownedArtworks;
        }
      }
    }
    return ownedArtworks;
  }

  function GetTypesOfAddress(address _addr) view external returns(uint32[] memory){
    uint32[] memory ownedArtworks = new uint32[](IFEAS_artworks.ownerArtworkCount(_addr));
    uint i = 0; uint j = 0;

    for(i = 0; i < IFEAS_artworks.GetArtworksLength(); i++){
      if(IFEAS_artworks.GetArtworksOwner(i) == _addr){
        ownedArtworks[j] = IFEAS_artworks.GetArtworksType(i); // artwork index
        j = j.add(1);
        if(j >= IFEAS_artworks.ownerArtworkCount(_addr)){
          return ownedArtworks;
        }
      }
    }
    return ownedArtworks;
  }

  function GetUserSellFlagsOfAddress(address _addr) view external returns(bool[] memory){
    bool[] memory userSellFlags = new bool[](IFEAS_artworks.ownerArtworkCount(_addr));
    uint i = 0; uint j = 0;

    for(i = 0; i < IFEAS_artworks.GetArtworksLength(); i++){
      if(IFEAS_artworks.GetArtworksOwner(i) == _addr){
        userSellFlags[j] = IFEAS_artworks.GetArtworksUserSellFlag(i); // artwork index
        j = j.add(1);
        if(j >= IFEAS_artworks.ownerArtworkCount(_addr)){
          return userSellFlags;
        }
      }
    }
    return userSellFlags;
  }

  function GetRecipeUsedsOfAddress(address _addr) view external returns(bool[] memory){
    bool[] memory recipeUseds = new bool[](IFEAS_artworks.ownerArtworkCount(_addr));
    uint i = 0; uint j = 0;

    for(i = 0; i < IFEAS_artworks.GetArtworksLength(); i++){
      if(IFEAS_artworks.GetArtworksOwner(i) == _addr){
        recipeUseds[j] = IFEAS_artworks.GetArtworksRecipeUsed(i); // artwork index
        j = j.add(1);
        if(j >= IFEAS_artworks.ownerArtworkCount(_addr)){
          return recipeUseds;
        }
      }
    }
    return recipeUseds;
  }

  function GetUserSellPricesOfAddress(address _addr) view external returns(uint32[] memory){
    uint32[] memory userSellPrices = new uint32[](IFEAS_artworks.ownerArtworkCount(_addr));
    uint i = 0; uint j = 0;

    for(i = 0; i < IFEAS_artworks.GetArtworksLength(); i++){
      if(IFEAS_artworks.GetArtworksOwner(i) == _addr){
        userSellPrices[j] = IFEAS_artworks.GetArtworksUserPriceInFinny(i); // artwork index
        j = j.add(1);
        if(j >= IFEAS_artworks.ownerArtworkCount(_addr)){
          return userSellPrices;
        }
      }
    }
    return userSellPrices;
  }

  function GetCardColorsOfAddress(address _addr) view external returns(uint8[] memory){
    uint8[] memory cardColors = new uint8[](IFEAS_artworks.ownerArtworkCount(_addr));
    uint i = 0; uint j = 0;

    for(i = 0; i < IFEAS_artworks.GetArtworksLength(); i++){
      if(IFEAS_artworks.GetArtworksOwner(i) == _addr){
        cardColors[j] = IFEAS_types.GetArtworkTypesCardColor(IFEAS_artworks.GetArtworksType(i)); // artwork index
        j = j.add(1);
        if(j >= IFEAS_artworks.ownerArtworkCount(_addr)){
          return cardColors;
        }
      }
    }
    return cardColors;
  }

}