// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//
//  888    888                                          888b     d888          888               888          
//  888    888                                          8888b   d8888          888               888          
//  888    888                                          88888b.d88888          888               888          
//  8888888888  8888b.  88888b.  88888b.  888  888      888Y88888P888  .d88b.  888  .d88b.   .d88888 888  888 
//  888    888     "88b 888 "88b 888 "88b 888  888      888 Y888P 888 d8P  Y8b 888 d88""88b d88" 888 888  888 
//  888    888 .d888888 888  888 888  888 888  888      888  Y8P  888 88888888 888 888  888 888  888 888  888 
//  888    888 888  888 888 d88P 888 d88P Y88b 888      888   "   888 Y8b.     888 Y88..88P Y88b 888 Y88b 888 
//  888    888 "Y888888 88888P"  88888P"   "Y88888      888       888  "Y8888  888  "Y88P"   "Y88888  "Y88888 
//                      888      888           888                                                        888 
//                      888      888      Y8b d88P                                                   Y8b d88P 
//                      888      888       "Y88P"                                                     "Y88P"  
//

import "./Address.sol";
import "./Ownable.sol";
import "./Pausable.sol";
import "./ERC721A.sol";
import "./RegisterFilter721.sol";
import "./LibSalePhase.sol";

import {MerkleProof} from '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';





contract HappyMelody is RegisterFilter721, Pausable {
  using Address for address;

  event Received(address, uint);
  event ClaimedAirdropNFT(address, uint);
  
  event TotalMint(
    uint phaseNum , 
    uint phaseMintCount ,
    uint availablePerWallet,
    uint totalSupply);


  //////////////
  // Constants
  //////////////

  uint256 public MAX_MINT_PER_TX = 890;
  uint256 public MAX_SUPPLY = 1000;
  uint256 public AIRDROP_NFT_COUNT = 10;
  uint256 public TEAM_NFT_COUNT = 100;


  //////////////
  // Internal
  //////////////
  string private _baseTokenURI;
  bool private _isTeamNFTsMinted = false;  
  bool private _isAirdropNFTsMinted = false;
  mapping(address => uint) private _mintTransectionCount;
  mapping(address => mapping(uint => uint[])) private _mintTransection;
  bytes32 private _merkleRoot = 0x0000000000000000000000000000000000000000000000000000000000000000;
  string private _baseExtension = ".json";
  bool private _isTransferProfit = false;  // is  transfer profit when mint

  /////////////////////
  // Public Variables
  /////////////////////

  uint256 public publicRoundMintPrice;
  address public artistAddress;
  mapping(address => uint256) public addressTokenMinted;
  address public teamAddress;
  mapping(address => uint[]) public whitelistAddressesAirdropIndex;


  address[] public whitelistAddressesAirdrop;

  bool public isAirdropActive;
//   address[] public claimedAirdropAddresses;
 mapping(address => bool) public claimedAirdropAddresses;


  ////////////////
  // Actual Code
  ////////////////

  constructor(
      string memory baseURIToken_, 
      uint256 publicMintPrice_, 
      address teamAddress_ 
    )
   RegisterFilter721("Happy Melody", "HPM") {
    
    _baseTokenURI = baseURIToken_;
    publicRoundMintPrice = publicMintPrice_;
    teamAddress = teamAddress_;
    disableOperatorFilter = true;

    uint256 totalSupplyPublicMint = MAX_SUPPLY - TEAM_NFT_COUNT - AIRDROP_NFT_COUNT;

    addPhase(
        "public",
        totalSupplyPublicMint,
        totalSupplyPublicMint,
        _merkleRoot,
        false,
        publicRoundMintPrice
    );

  }

  //////////////////////
  // Setters for Owner
  //////////////////////

  function setTeamAddress(address addr) public onlyOwner {
    teamAddress = addr;
  }

  function setPublicRoundMintPrice(uint256 price) public onlyOwner {
    publicRoundMintPrice = price;
  }

  function setArtistAddress(address addr) public onlyOwner {
    require(!Address.isContract(addr), "Address cannot is contract");
    artistAddress = addr;
  }

  function setAirdropActive(bool _state) public onlyOwner {
        isAirdropActive 
        = _state;
   }

   function setDisableOperatorFilter(bool _state)public onlyOwner {
        disableOperatorFilter = _state;
   }


   function isDisableOperatorFilter() public  view  returns(bool) {
       return  disableOperatorFilter;
   }

   function setIsTransferProfit(bool _state) external onlyOwner {
        _isTransferProfit = _state;
   } 

   function isTransferProfit()  public  view  returns(bool) {
     return   _isTransferProfit;
   } 
 
 

  
  ////////////
  // Minting
  ////////////

  function mintTeamNFTs() public onlyOwner {
    require(teamAddress != address(0), "Team wallet is not yet set");
    require(!_isTeamNFTsMinted, "Already minted");

    string memory baseURI = _baseURI();
    require(bytes(baseURI).length != 0, "baseURI is not yet set");

    _safeMint(teamAddress, TEAM_NFT_COUNT);

    _isTeamNFTsMinted = true;
  }


  function mint(uint256 quantity ,bytes32[] calldata merkleProof) external payable whenNotPaused {
    LibSalePhase.PhaseSettings memory currentPhase =  LibSalePhase.getActivePhase();
    
    require(isWhiteList(msg.sender, merkleProof, currentPhase.phaseNum), "Address not in whitelist");
    require(currentPhase.status ==  LibSalePhase.STATE.START , "Sale Phase not start." );
    require(quantity > 0, "Quantity cannot be zero");
    require(quantity <= MAX_MINT_PER_TX, "Cannot mint more than maximum per transition");
    require(totalMinted() + AIRDROP_NFT_COUNT + quantity <= MAX_SUPPLY, "Cannot mint more than maximum supply");
    uint256 cost = quantity * currentPhase.price;
    require(msg.value == cost, "Unmatched ether balance");

    _safeMint(msg.sender, quantity);

    addressTokenMinted[msg.sender] = addressTokenMinted[msg.sender] + quantity;

    if(_isTransferProfit){
        //  require(artistAddress != address(0), "Artist wallet is not yet set");

        if (artistAddress != address(0)) {
           payable(artistAddress).transfer(msg.value);
        }
 
    }



    
    LibSalePhase.setAmountMintedPhase(currentPhase.phaseNum ,quantity ,msg.sender);
    // uint256 remain = MAX_SUPPLY - (AIRDROP_NFT_COUNT + totalMinted());
    


    emit TotalMint(
        currentPhase.phaseNum,
        LibSalePhase.getPhaseTotalMint(currentPhase.phaseNum),
        LibSalePhase.getMintAvailableAddress(msg.sender),
        currentPhase.amountMinted + quantity  // current total supple page
        );

  }

      // check claimed airdro aleady
 function isClaimedAirdrop(address _address)  public  view  returns(bool) {
         return claimedAirdropAddresses[_address];
}

  function claimAirdrop() public {
    require(isAirdropActive, "Airdrop is inactive");
    require(!isClaimedAirdrop(msg.sender) , "Address already cliam airdrop");
    require(isAddressInAirdropWhitelist(msg.sender), "You need to be whitelisted to mint in the airdop round");
    require(!_isAirdropNFTsMinted, "Already cliam airdrop");


    uint256 startTokenId = _currentIndex;
    uint8 quantity = 1;
    require(totalMinted() + quantity <= MAX_SUPPLY, "Cannot mint more than maximum supply");

    _safeMint(msg.sender, quantity);

     removeWhitelistAirdrop(msg.sender);

    if (whitelistAddressesAirdrop.length < 0) {
      _isAirdropNFTsMinted = true;
    }

    emit ClaimedAirdropNFT(msg.sender, startTokenId);
  }

  ///////////////
  // Whitelist Airdrop
  ///////////////

    function addAirdropWhitelistAddresses(address[] calldata _addresses) external onlyOwner {

        uint whitelistAddressesAirdropLength =  whitelistAddressesAirdrop.length;
        for (uint i = 0; i < _addresses.length; i++) {

             whitelistAddressesAirdropIndex[_addresses[i]].push(whitelistAddressesAirdropLength+i);
             whitelistAddressesAirdrop.push(_addresses[i]);
             claimedAirdropAddresses[_addresses[i]] = false;
        }
    }

 
    function getWhitelistAddressesAirdrop() public view returns( address[] memory){
       return whitelistAddressesAirdrop;
    }

     function getWhitelistAddressesAirdropIndex(address _address) public view returns( uint[] memory){
       return whitelistAddressesAirdropIndex[_address];
    }

  function  isAddressInAirdropWhitelist(address _address) public view returns (bool) {
    return whitelistAddressesAirdropIndex[_address].length > 0 ;
  }

  function removeWhitelistAirdrop(address _address) internal {

    uint lengthIndex  =  whitelistAddressesAirdropIndex[_address].length-1;
    uint indexToRemove = whitelistAddressesAirdropIndex[_address][lengthIndex];
    

     whitelistAddressesAirdrop[indexToRemove] = address(0);
     whitelistAddressesAirdropIndex[_address].pop();

    // if claimed all set to true  
     if(whitelistAddressesAirdropIndex[_address].length == 0){
          claimedAirdropAddresses[_address] = true;
     }

  }

  function removeWhitelistAirdropByOwner(address _address)  external onlyOwner  {

     uint lengthIndex  =  whitelistAddressesAirdropIndex[_address].length-1;
     uint indexToRemove = whitelistAddressesAirdropIndex[_address][lengthIndex];
    
      whitelistAddressesAirdrop[indexToRemove] = address(0);
      whitelistAddressesAirdropIndex[_address].pop();

   }


   function setClaimedAirdropAddresses(address _address , bool _status) external onlyOwner{
     claimedAirdropAddresses[_address] = _status;
   }

  ///////////////
  // Phase setting
  ///////////////

  function getAllPhase() external view returns( LibSalePhase.PhaseSettings[] memory) {
    return LibSalePhase.getAllPhase();
  }

  function getPhase(uint numb_)  external view returns( LibSalePhase.PhaseSettings memory) {
    return LibSalePhase.getPhase(numb_);
  }

  function addPhase(
    string memory name_,
    uint maxSupply_,
    uint maxPerWallet_,
    bytes32 merkleRoot_,
    bool isActive_,
    uint256 price_
    ) public onlyOwner {
    
    LibSalePhase.addPhase(
        name_,
        maxSupply_,
        maxPerWallet_,
        merkleRoot_,
        isActive_,
        price_
    );
  }

  function updatePhase(
        string  memory name_,
        uint  maxSupply_,
        uint  maxPerWallet_,
        bytes32 merkleRoot_,
        bool    isActive_,
        uint256 price_,
        uint    numPhase_
    ) external onlyOwner {

    LibSalePhase.updatePhase(
        name_,
        maxSupply_,
        maxPerWallet_,
        merkleRoot_,
        isActive_,
        price_,
        numPhase_
    );

  }

  function setActiveState(uint64 activeState_) external onlyOwner {
    LibSalePhase.setActiveState(activeState_);
  }

  function getActivePhase() public view returns(LibSalePhase.PhaseSettings memory) {
    return LibSalePhase.getActivePhase();
  } 

  function setPhaseStatus(uint phaseNum_ , uint status_) external onlyOwner {
    LibSalePhase.setPhaseStatus(phaseNum_ , status_);
  }


     function isWhiteList(
        address _address ,  
        bytes32[] calldata _merkleProof ,
        uint _phaseNum
    ) public view returns(bool){
        return   LibSalePhase.isWhitelist( _address , _merkleProof , _phaseNum);

    }

    function setWhitelist(
        bytes32  merkleRoot,
        uint _phaseNum
    ) public onlyOwner{
        LibSalePhase.setWhitelist(  merkleRoot , _phaseNum);
    }


  //////////////
  // Pausable
  //////////////

  function pause() public onlyOwner {
    _pause();
  }

  function unpause() public onlyOwner {
    _unpause();
  }

  ///////////////////
  // Internal Views
  ///////////////////
  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function setBaseURI(string calldata baseURI) external onlyOwner {
    _baseTokenURI = baseURI;
  }
  /////////////////
  // Public Views
  /////////////////
  function totalMinted() public view returns (uint256) {
    return _totalMinted();
  }

  function  _afterTokenTransfers(address from, address to, uint256 tokenId,uint256 quantity) internal override {
    super._afterTokenTransfers( from ,to, tokenId,quantity);
      
    uint mintCount = _mintTransectionCount[to] + 1;
    for(uint i = tokenId; i < tokenId+quantity; i++) {
        _mintTransection[to][mintCount].push(i);
    }
    _mintTransectionCount[to] = mintCount;

  }

  function getMintTransection(address user_ , uint index_) public view returns(uint[] memory){
    return _mintTransection[user_][index_];
  }

  function getLastedMintTransection(address user_) public view returns(uint[] memory){
    uint lastIndexMint = _mintTransectionCount[user_];
    return this.getMintTransection(user_ ,lastIndexMint);
  }

    function getMintAvailableAddress(address address_)  public  view returns(uint){ 
        return LibSalePhase.getMintAvailableAddress(address_);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
          string memory baseURI = _baseURI();
            return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, Strings.toString(tokenId),_baseExtension )) : '';
    }

    function maxSupply() public view returns(uint) {
        return MAX_SUPPLY;
    }

    function setMaxSupply(uint _maxSupply) external onlyOwner {
         MAX_SUPPLY = _maxSupply;
    }


    function getBalance()  public  view  returns(uint) {
       return  address(this).balance;
    }


  

  ///////////////
  // Withdrawal
  ///////////////

  function withdraw() public onlyOwner {
    uint256 balance = address(this).balance;
    payable(msg.sender).transfer(balance);
  }


  ///////////////
  // Burn
  ///////////////

  function burn(uint256 tokenId) external onlyOwner {
      super._burn( tokenId);
      MAX_SUPPLY =  MAX_SUPPLY-1;
     
 }

 function updateMaxSupply(uint _maxSupply , string calldata _uri ) external onlyOwner{
       require(_maxSupply > 0, "max supply should geater than 0");
        
      MAX_SUPPLY = _maxSupply;
     _baseTokenURI = _uri;
 }


  /////////////
  // Fallback
  /////////////

  receive() external payable {
    emit Received(msg.sender, msg.value);
  }
}