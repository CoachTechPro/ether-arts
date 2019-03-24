pragma solidity >= 0.5.0;


contract IF_EAO_buy {

  event EventCardBuy(address indexed player, uint indexed cardNo, uint cardId, uint8 cardColor, uint priceInFinny);

  function BuyArtwork(uint32 _artworkType, address _msgSender, uint _msgValue, uint _msgSenderBalance) public returns(uint tokenId);
}
