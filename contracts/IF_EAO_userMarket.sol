pragma solidity >= 0.5.0;

contract IF_EAO_userMarket {
  
  event EventUserMarketBuy(address indexed seller, address indexed buyer, uint32 finny_value, uint cardId);

  function GetBalance() public view returns(uint);
  function BuyOnTheUserMarket(uint _cardId) public payable;
  function TransferFund(address _addressTo, uint _amountInWei) internal;
  function MigrateToNewUserMarket(address _newUserMarket) external;
}
