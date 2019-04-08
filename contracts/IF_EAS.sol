pragma solidity >= 0.5.0;


contract IF_EAS{

  uint     public stageNo;
  uint8    public MARKETING_DISTRIBUTE_RATIO;
  address  public ADDRESS_MARKETING;
  uint8    public TEAM_DISTRIBUTE_RATIO;
  address  public ADDRESS_TEAM;
  uint8    public WINNERS1_DIST_RATIO;
  uint8    public WINNERS2_DIST_RATIO;

/*
  function FundRestoreToEAO() external;
  function FundRestoreToEAOMission() external;
*/
  function SetEAOFundSaved(uint amount) external;
  function SetEAOMissionFundSaved(uint amount) external;

  function UpdateIFEAO(address _newIFEAO_addr) public;

  function GetBalance() public view returns(uint);
//  function GetEAOBalanceInFinny() public view returns(uint);
//  function GetEAOmissionBalanceInFinny() public view returns(uint);

  /* GENERATE AN INSTANCE OF CARD */
  //function GetStageNo() public view returns(uint);
  function SetStageNo(uint _stageNo) external;
  function GetDefaultUserPriceInFinny() public view returns(uint32);
  function SetDefaultUserPriceInFinny(uint32 _priceInFinny) external;


  /***********************************************/
  /*        FOR ERC-721 TRANSFER FUNCTION        */
  /***********************************************/
  function SetArtworkApprovals(uint _tokenId, address _to) external;
  function GetArtworkApprovals(uint _tokenId) public view returns(address);


  /***********************************************/
  /*  DISTRIBUTION ADDRESS & RATIO INFORMATION   */
  /***********************************************/

  //function GetWinner1DistributeRatio() public view returns(uint8);
  //function GetWinner2DistributeRatio() public view returns(uint8);
  function SetWinner1DistributeRatio(uint8 _newRatio) external;
  function SetWinner2DistributeRatio(uint8 _newRatio) external;

  function SetMarketingDistRatio(uint8 _newRatio) external;
  //function GetMarketingDistRatio() public view returns(uint8);
  function SetTeamDistRatio(uint8 _newRatio) external;
  //function GetTeamDistRatio() public view returns(uint8);
  function SetMarketingAddress(address _newAddr) external;
  //function GetMarketingAddress() public view returns(address);
  function SetTeamAddress(address _newAddr) external;
  //function GetTeamAddress() public view returns(address);

  function GetCardInfo(address _address) public view returns(uint32[] memory, uint64[] memory, address[] memory, bool[] memory, bool[] memory, uint32[] memory);
  function GetCardInfo2(address _address) public view returns(uint[] memory, uint[] memory);
//https://github.com/willitscale/solidity-util/blob/master/lib/Integers.sol
  //function parseInt(string memory _value) public returns (uint _ret);
  function toString(uint _base) public returns (string memory);

  // parseInt
  function parseInt(string memory _a) public pure returns (uint);
  // parseInt(parseFloat*10^_b)
  function parseInt(string memory _a, uint _b) public pure returns (uint);

}