pragma solidity >= 0.5.0;

contract IF_EAM{

  event GenerateBounty(address indexed _address, uint indexed artworksId, uint32 indexed _artworkType);
  event EventSpecialCardClaimed(address indexed _address, uint indexed _targetCardType, uint _id1, uint _id2);
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

/************************************************************************************/
/************               ERC-721 common interfaces here              *************/
/************************************************************************************/

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function _transfer(address _from, address _to, uint256 _tokenId) public;
  function transfer(address _to, uint256 _tokenId) public;
  function setTokenURI(uint _tokenId, string memory _URI) public;
  function totalSupply() public view returns (uint256);

  // seller have to approve the change of ownership to certain address before buyer calls takeOwnership() function
  function approve(address _to, uint256 _tokenId) public;

  // buyer or acquiror have to call this function, after the seller's approve() function.
  function takeOwnership(uint256 _tokenId) public;


/************************************************************************************/
/************             CARD GENERATION related functions             *************/
/************************************************************************************/
  
  function GenerateBountyToken(uint32 _artworkType /* start from 0 */, address _address) public returns(bool);
  function ClaimSpecialCard(uint _targetCardType, uint _id1, uint _id2) public;

  /*************************************************************/
  /**                  MISC FUNCTIONS                         **/
  /*************************************************************/

  /* This function is optimized for the reply of Wolfram alpha, though oraclize interface. */
  function SplitNumbers(string memory _base, string memory _value) public returns (uint, uint);
  function Length(string memory _base) public returns (uint);
  function IndexOf(string memory _base, string memory _value, uint _offset) public returns (int);

}
