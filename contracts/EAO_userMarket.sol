pragma solidity >= 0.5.0;

import "./SafeMath.sol";
import "./Ownable.sol";

import "./IF_EAO_userMarket.sol";
import "./IF_EAS_artworks.sol";
import "./IF_EAS.sol";
import "./IF_EAS_platform.sol"; 

contract EAO_userMarket is Ownable{

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