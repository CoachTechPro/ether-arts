pragma solidity >= 0.5.0;

import "./SafeMath.sol";
import "./Ownable.sol";

import "./IF_EAO_userMarket.sol";
import "./IF_EAS_artworks.sol";
import "./IF_EAS.sol";
import "./IF_EAS_platform.sol"; 

contract EAO_userMarket is Ownable{

  int256 constant INT256_MIN = int256(uint256(1) << 255);
  int256 constant INT256_MAX = int256(~(uint256(1) << 255));
  uint256 constant UINT256_MIN = 0;
  uint256 constant UINT256_MAX = ~uint256(0);

  using SafeMath for uint256;
  using SafeMath for uint32;

  IF_EAS_artworks   IFEAS_artworks;
  IF_EAS            IFEAS;
  IF_EAS_platform   IFEAS_platform;

  event EventUserMarketBuy(address indexed seller, address indexed buyer, uint32 finny_value, uint cardId);

  modifier sellFlagEnabled(uint _id){
    require(IFEAS_artworks.GetArtworksUserSellFlag(_id) == true, "(sellFlagEnabled error, EAO_userMarket)");
    _;
  }

  modifier platform() {     /* Only EtherArts Platform (EtherArtsOperations, EtherArtsStorage, EtherArtsOracle, Contract owner) can access this contract */
    require(IFEAS_platform.accessAllowed(msg.sender) == true, "(platform error, EAO_userMarket)");
    _;
  }

  constructor(address _addrEAS, address _addrEAS_artworks, address _addr_EAS_platform) public{

    IFEAS = IF_EAS(_addrEAS);
    IFEAS_artworks = IF_EAS_artworks(_addrEAS_artworks);
    IFEAS_platform = IF_EAS_platform(_addr_EAS_platform);
  }

  function() external payable{}

  function GetBalance() public view returns(uint){
    return address(this).balance;
  }




function ListUserOffer(uint32 _cardType, bool _claimedUsed) public view returns(address, uint, address, uint){

  uint[] memory ownerPriceInFinny = IFEAS_artworks.GetAllUserPricesOfType(_cardType);
  address[] memory ownerAddresses = IFEAS_artworks.GetAllOwnersOfType(_cardType);
  uint[] memory tokenIds = IFEAS_artworks.GetTokenIdFromType(_cardType);
  bool[] memory recipeUsed = IFEAS_artworks.GetAllRecipeUsedOfType(_cardType);

  uint length = ownerPriceInFinny.length;

  // finding lowest value over zero
  uint lowest_value = UINT256_MAX;
  uint lowest_idx = 1000;
  uint next_value = UINT256_MAX;
  uint next_idx = 1000;

  for(uint i=0; i<length; i++){
    if(ownerPriceInFinny[i] > 0 && recipeUsed[i] == _claimedUsed){
      if(ownerPriceInFinny[i] < lowest_value){
        lowest_value = ownerPriceInFinny[i];
        lowest_idx = i;
      }
    }
  }

  for(uint i=0; i<length; i++){
    if((ownerPriceInFinny[i] > lowest_value) && recipeUsed[i] == _claimedUsed){
      if(ownerPriceInFinny[i] < next_value){
        next_value = ownerPriceInFinny[i];
        next_idx = i;
      }
    }
  }
  if(lowest_idx >= 120 && next_idx >= 120){
    return (address(0),0,address(0),0);
  }else if(lowest_idx < 120 && next_idx >= 120){
    return (ownerAddresses[lowest_idx], ownerPriceInFinny[lowest_idx], address(0),0);
  }else if(lowest_idx < 120 && next_idx < 120){
    return (ownerAddresses[lowest_idx], ownerPriceInFinny[lowest_idx], ownerAddresses[next_idx], ownerPriceInFinny[next_idx]);
  }
}




function ListingNextOffer(uint _cardType, uint _priceBest) public view returns(address, uint){

}

function IsUserMarketAvailable(uint _cardType) public view returns (bool){

}

  function BuyOnTheUserMarket(uint _cardId) public payable sellFlagEnabled(_cardId) returns(bool){
    uint32 finny_value = IFEAS_artworks.GetArtworksUserPriceInFinny(_cardId);
    uint wei_value = uint(finny_value) * 10**15;
    require(msg.value == wei_value, "(Price not matched)");
    require(msg.value > 0, "(Price have to be larger than 0)");

    // transfer ether to seller
    wei_value = msg.value.mul(97).div(100);
    address sellerAddr = IFEAS_artworks.GetArtworksOwner(_cardId);
    TransferFund(sellerAddr, wei_value);

    // transfer commission fee
    wei_value = msg.value.mul(3).div(100);
    TransferFund(IFEAS.ADDRESS_TEAM(), wei_value);

    IFEAS_artworks.UpdateCardHolderCount(msg.sender);
    
    IFEAS_artworks.SetOwnerArtworkCount(msg.sender, uint32(IFEAS_artworks.ownerArtworkCount(msg.sender).add(1)));
    IFEAS_artworks.SetOwnerArtworkCount(sellerAddr, uint32(IFEAS_artworks.ownerArtworkCount(sellerAddr).sub(1)));

    IFEAS_artworks.ResetUserParameters(_cardId);
    IFEAS_artworks.SetArtworksOwner(_cardId, msg.sender);
    IFEAS_artworks.UpdateArtworksTimestampLastTransfer(_cardId);

    emit EventUserMarketBuy(sellerAddr, msg.sender, finny_value, _cardId);
    return true;
  }

  function TransferFund(address _addressTo, uint _amountInWei) internal{
    address payable addrTo = address(uint160(_addressTo));
    addrTo.transfer(_amountInWei);
  }

  function MigrateToNewUserMarket(address _newUserMarket) external onlyOwner{
    address payable addrTo = address(uint160(_newUserMarket));
    selfdestruct(addrTo);
  }


}