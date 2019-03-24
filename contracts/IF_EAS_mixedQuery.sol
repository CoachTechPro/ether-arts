pragma solidity >= 0.5.0;

contract IF_EAS_mixedQuery {

  /*************************************************************/
  /**          FUNCTIONS DEAL WITH SPECIFIC "TYPE"            **/
  /*************************************************************/

  // filtered userPrice only for specified type,  (_type : starts from 0)
  function GetUserSellFlagsOfType(uint32 _type) view external returns(bool[] memory);

  // filtered userPrice only for specified type,  (_type : starts from 0)
  function GetUserSellPricesOfType(uint32 _type) view external returns(uint32[] memory);

  // filtered ownerAddress only for specified type, (_type : starts from 0)
  function GetOwnersOfType(uint32 _type) view external returns(address[] memory);

  // returns card numbers for each player who has "_type" cards(owners of _type card),  (_type : starts from 0)
  function GetNumCardsWhoOwnsType(uint32 _type) view external returns(uint32[] memory);

  function GetRecipeUsedsOfType(uint32 _type) view external returns(bool[] memory);


/**************************************************************************/
/************     FUNCTIONS DEAL WITH SPECIFIC "ADDRESS"      *************/
/**************************************************************************/

  function GetArtworkIndexesOfAddress(address _addr) view external returns(uint32[] memory);
  function GetTypesOfAddress(address _addr) view external returns(uint32[] memory);
  function GetUserSellFlagsOfAddress(address _addr) view external returns(bool[] memory);
  function GetRecipeUsedsOfAddress(address _addr) view external returns(bool[] memory);
  function GetUserSellPricesOfAddress(address _addr) view external returns(uint32[] memory);
  function GetCardColorsOfAddress(address _addr) view external returns(uint8[] memory);

}