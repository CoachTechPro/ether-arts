pragma solidity >= 0.5.0;

import "./SafeMath.sol";
import "./Ownable.sol";

import "./IF_EAS_roll.sol";
import "./IF_EAS_artworks.sol";
import "./IF_EAS_types.sol";
import "./IF_EAS.sol";
import "./IF_EAO.sol";
import "./IF_EAS_platform.sol"; 

contract EAO_buy is Ownable{

  using SafeMath for uint256;
  using SafeMath for uint32;

  event EventCardBuy(address indexed player, uint indexed cardNo, uint cardId, uint8 cardColor, uint priceInFinny);

  IF_EAS_artworks   IFEAS_artworks;
  IF_EAS_types      IFEAS_types;
  IF_EAS            IFEAS;
  IF_EAO            IFEAO;
  IF_EAS_platform   IFEAS_platform;

  modifier platform() {     /* Only EtherArts Platform (EtherArtsOperations, EtherArtsStorage, EtherArtsOracle, Contract owner) can access this contract */
      require(IFEAS_platform.accessAllowed(msg.sender) == true, "(platform error, EAO_buy)");
      _;
  }

  constructor(address _addrEAS, address _addrEAS_types, address _addrEAS_artworks, address _addr_EAS_platform, address _addr_EAO) public{
    IFEAS = IF_EAS(_addrEAS);
    IFEAS_types = IF_EAS_types(_addrEAS_types);
    IFEAS_artworks = IF_EAS_artworks(_addrEAS_artworks);
    IFEAS_platform = IF_EAS_platform(_addr_EAS_platform);
    IFEAO = IF_EAO(_addr_EAO);
  }


/************************************************************************************/
/************     ROLL AND MISSION PLAY RELATED ORACLE FUNCTIONS        *************/
/************************************************************************************/

  function BuyArtwork(uint32 _artworkType, address _msgSender, uint _msgValue, uint _msgSenderBalance) external platform returns(uint) {

    // check price in ether
    uint wei_value = uint(IFEAS_types.GetArtworkTypesPriceInFinny(_artworkType)) * 10**15;
    require(_msgValue == wei_value, "msgValue is not matched.");
    require(wei_value > 0, "weiValue is smaller than 0.");

    // buy tried count ++
    IFEAS_artworks.IncreaseBuyTried();
    
    // card holder count ++
    IFEAS_artworks.UpdateCardHolderCount(_msgSender); // card holder count ++ if it is new user.
    
    // increase owner's artwork count
    IFEAS_artworks.SetOwnerArtworkCount(_msgSender, uint32(IFEAS_artworks.ownerArtworkCount(_msgSender).add(1)));

    uint tokenId = IFEAS_artworks.GetArtworksLength();
    // Create new card and set      owner,      tokenId, typeIndex,    timestamp,   1:marketBuy, localSeq,                            userSellFlag, userPriceInFinny,            recipeUsed
    IFEAS_artworks.GenerateEtherArt(_msgSender, tokenId, _artworkType, block.timestamp, 1, IFEAS_types.GetArtworkTypesSold(_artworkType), false, IFEAS.GetDefaultUserPriceInFinny(), false);

    // tokenId marking for cards management
    IFEAS_artworks.AppendTokenIdToTypeId(_artworkType, tokenId);
    
    IFEAS_types.SetArtworkTypesSold(_artworkType, uint32(IFEAS_types.GetArtworkTypesSold(_artworkType).add(1)));

    // transfer copyright fee 
    wei_value = _msgValue.mul(10).div(100);
    IFEAO.TransferFund(IFEAS_types.GetArtworkTypesAddressForArtist(_artworkType), wei_value);

    // transfer marketing fee
    wei_value = _msgValue.mul(IFEAS.MARKETING_DISTRIBUTE_RATIO()).div(100);
    IFEAO.TransferFund(IFEAS.ADDRESS_MARKETING(), wei_value);

    // transfer team interest
    wei_value = _msgValue.mul(IFEAS.TEAM_DISTRIBUTE_RATIO()).div(100);
    IFEAO.TransferFund(IFEAS.ADDRESS_TEAM(), wei_value);

    emit EventCardBuy(_msgSender, _artworkType, tokenId, IFEAS_types.GetArtworkTypesCardColor(_artworkType), IFEAS_types.GetArtworkTypesPriceInFinny(_artworkType));
    return tokenId;
  }
}

