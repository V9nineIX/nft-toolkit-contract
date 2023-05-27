// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./Initializable.sol";
import "./Address.sol";
import "./Pausable.sol";
import "./ERC721A.sol";
import "./Math.sol";
import "./LibSalePhase.sol";
import "./RegisterFilter721.sol";

contract Template721ARandom is RegisterFilter721, Initializable, Pausable {
    using Address for address;

    event Received(address, uint);
    event TotalMintedChanged(uint256);
    event Revealed();
    event ClaimedAirdropNFT(address, uint);

    event TotalMint(
        uint phaseNum , 
        uint phaseMintCount ,
        uint availablePerWallet,
        uint totalSupply);

    //////////////
    // Constants
    //////////////
     uint public price;
    uint256 public maxMintPerTx = 5;
    uint256 public maxSupply = 10000;
    uint256 public teamNFTsCount = 10;
    uint256 public airdropNFTsCount = 100;
    bool public disableRandomMint = true;

    bool public useReserveForTeam = false;
    bool public useReserveForAirdrop = false;
    address public teamAddress;


    //////////////
    // Internal
    //////////////
    string private _baseTokenURI;    
    mapping(uint256 => uint256) private _tokenURIKeys;
    uint256[] private _unusedNums;
    uint256 private _requireNums = 10000;
    uint256 private _currentNums = 0;
    uint256 private _minRoundPublicNFTsCount = 1;
    

    bool private  _isTeamNFTsMinted = false;  
    bool private _isAirdropNFTsMinted = false;

    /////////////////////
    // Public Variables
    /////////////////////
    bool public revealed;
    string public notRevealedURI;
    mapping(address => uint) public  mintTransectionCount;
    mapping(address => mapping(uint => uint[])) public mintTransection;
    bool public isAirdropActive;
    address[] public airdropWhitelistAddresses;
    // address[] public claimedAirdropAddresses;
    string public baseExtension = ".json";

    mapping(address => uint[]) public whitelistAddressesAirdropIndex;
    address[] public whitelistAddressesAirdrop;
    mapping(address => bool) public claimedAirdropAddresses;

    bytes32 public merkleRoot = 0x0000000000000000000000000000000000000000000000000000000000000000;

    ////////////////
    // Actual Code
    ////////////////

    constructor() RegisterFilter721("Template721ARandom", "Template721ARandom") {

    }

    // Initiail
    function init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }


    function initialize(
        bytes calldata initArg1,
        bytes calldata initArg2,
        address owner_
    ) public initializer {
        (
            string memory name_,
            string memory symbol_,
            string memory baseURI_,
            string memory notRevealedURI_,
            uint maxPublicSupply_,
            uint maxSupply_,
            uint maxTokensPerAddress_
        ) = abi.decode(
                initArg1,
                (
                    string,
                    string,
                    string,
                    string,
                    uint,
                    uint,
                    uint
                )
            );

        (
            bool revealed_,
            uint price_,
            bool disableRandomMint_,
            bytes32  merkleRoot_,
            bool disableOperatorFilter_
        ) = abi.decode(
                initArg2,
                (
                    bool,
                    uint,
                    bool,
                    bytes32,
                    bool
                )
        );

        init_unchained(name_, symbol_);
        // setBaseURI(baseURI_);
        // setNotRevealedURI(notRevealedURI_);
        notRevealedURI = notRevealedURI_;
        _baseTokenURI   = baseURI_;
        baseExtension = ".json";
        maxMintPerTx =  maxTokensPerAddress_;
        disableOperatorFilter = disableOperatorFilter_;
        maxSupply = maxSupply_;
        price = price_;
        revealed = revealed_;
        disableRandomMint =  disableRandomMint_ ;
         _transferOwnership(owner_);
        // setDisableOperatorFilter(disableOperatorFilter_);
        // setDisableRandomMint(disableRandomMint_);


        //TODO: create defualt
        LibSalePhase.addPhase(
                "public",
                maxPublicSupply_,
                maxTokensPerAddress_,
                merkleRoot_,
                false,
                price_
        );

    }

    //////////////////////
    // Setters for Owner
    //////////////////////

    function setMaxMintPerTX(uint8 amount) external onlyOwner {
        maxMintPerTx = amount;
    }

    function setMaxSupply(uint256 maxSupply_) external onlyOwner {
        maxSupply = maxSupply_;
    }

     function burn(uint256 tokenId) external onlyOwner {
      super._burn( tokenId);
       maxSupply =  maxSupply-1;
     
    }

    function setMerkleRoot( bytes32 _root) external onlyOwner {
        merkleRoot = _root;
    }


    function reveal() public onlyOwner {
        revealed = true;
        emit Revealed();
    }

    function setDisableOperatorFilter(bool disable_) public onlyOwner {
        disableOperatorFilter = disable_;
    }

    function setDisableRandomMint(bool disable_) public onlyOwner {
        require(totalMinted() < 1, "Cannot disable random mint after minted");
        disableRandomMint = disable_;
    }

    function setTeamAddressAndCountAndActiveReseve(address address_, uint256 count_, bool active_) external onlyOwner {
        teamAddress = address_;
        teamNFTsCount = count_;
        useReserveForTeam = active_;
    }

    function setUseReserveForTeam(bool use_) public onlyOwner {
        useReserveForTeam = use_;
    }

    function setTeamAddress(address addr) public onlyOwner {
        teamAddress = addr;
    }

    function setTeamNFTsCount(uint256 count_) public onlyOwner {
        require(count_ + airdropNFTsCount + _minRoundPublicNFTsCount <= maxSupply, "Cannot assign count serve team more than for public round");
        teamNFTsCount = count_;
    }

    function setUseReserveForAirdrop(bool use_) public onlyOwner {
        useReserveForAirdrop = use_;
    }

    function setAirdropNFTsCount(uint256 count_) public onlyOwner {
        require(count_ + teamNFTsCount + _minRoundPublicNFTsCount <= maxSupply, "Cannot assign count serve team more than for public round");
        airdropNFTsCount = count_;
    }


    ///////////////
    // Phase setting
    ///////////////

    function getAllPhase() external view returns( LibSalePhase.PhaseSettings[] memory) {
       return   LibSalePhase.getAllPhase();
    }

    function  getPhase(uint numb_)  external view returns( LibSalePhase.PhaseSettings memory) {
       return  LibSalePhase.getPhase(numb_);
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

    function getActivePhase() public view returns(  LibSalePhase.PhaseSettings memory ) {
       return LibSalePhase.getActivePhase();
    } 


    function setPhaseStatus(uint phaseNum_ , uint status_) external onlyOwner {
        LibSalePhase.setPhaseStatus(phaseNum_ , status_);
    }


    ////////////
    // Minting
    ////////////

    function mintTeamNFTs() public onlyOwner {
        require(useReserveForTeam, "UseReserveForTeam is inactive");
        require(teamAddress != address(0), "Team wallet is not yet set");
        require(!_isTeamNFTsMinted, "Already minted");

        if (disableRandomMint) {
            _safeMint(teamAddress, teamNFTsCount);
        } else {
            _mintRandom(teamAddress, teamNFTsCount);
        }

        _isTeamNFTsMinted = true;
    }



    function mint(uint256 amount ,bytes32[] calldata merkleProof) external payable whenNotPaused {
        LibSalePhase.PhaseSettings memory currentPhase =  LibSalePhase.getActivePhase();
        uint256 airdropCount = useReserveForAirdrop ? airdropNFTsCount : 0;


        require(isWhiteList(msg.sender, merkleProof, currentPhase.phaseNum), "Address not in whitelist");
        require(currentPhase.status ==  LibSalePhase.STATE.START , "Sale Phase not start." );
        require(amount > 0, "Amount cannot be zero");
        require(totalMinted() + amount + airdropCount <= maxSupply, "Cannot mint more than maximum supply");
        require(amount <= mintableLeft(), "Not enough key left to mint.");
        require(amount <= maxMintPerTx, "You have reached maximum mint per transition");
        require(LibSalePhase.getMintAvailableAddress(msg.sender) >= amount, "Max tokens per address exceeded for this wave");
        require(currentPhase.maxSupply - currentPhase.amountMinted >= amount, "Not enough key left to mint.");

        uint256 cost =  amount * currentPhase.price;

        require(msg.value == cost, "Unmatched ether balance");

      


        if (disableRandomMint) {
            _safeMint(msg.sender, amount);
        } else {
            _mintRandom(msg.sender, amount);
        }

         LibSalePhase.setAmountMintedPhase(currentPhase.phaseNum  ,amount ,msg.sender);
    
        emit TotalMint( currentPhase.phaseNum,
             LibSalePhase.getPhaseTotalMint(currentPhase.phaseNum),
             LibSalePhase.getMintAvailableAddress(msg.sender),
              currentPhase.amountMinted + amount
            );

    }

    function _mintRandom(address to, uint256 amount) private {
        uint256 tokenId = totalMinted();
        for (uint i = 0; i < amount; i++) {
            if (_unusedNums.length < 1) {
                makeNums();
            }
            _tokenURIKeys[tokenId + i] = takeTokenIdRandom(i);
        }
            
        _safeMint(to, amount);
        emit TotalMintedChanged(totalMinted());
    }


    function makeNums() private {
        uint256 amount = _requireNums - _currentNums;
        amount = Math.min(500, amount);

        for (uint i = 0; i < amount; i++) {
            _unusedNums.push(i);
        }

        if (totalMinted() > 0) {
            _currentNums += amount;
        }
    }

    function takeTokenIdRandom(uint indexLoop) private returns (uint256) {
        require(_unusedNums.length > 0, "Not enough key left to pick.");

        uint256 randomNum = uint256(
            keccak256(
                abi.encode(
                    address(this),
                    block.number,
                    block.timestamp,
                    block.difficulty,
                    tx.gasprice,
                    _unusedNums.length,
                    indexLoop
                )
            )
        );

        uint256 index = randomNum % _unusedNums.length;
        uint256 picked_key = _unusedNums[index];
        _unusedNums[index] = _unusedNums[_unusedNums.length - 1];
        _unusedNums.pop();
        return picked_key + _currentNums;
    }

    function mintableLeft() public view returns (uint256) {
        return maxSupply - totalMinted();
    }

    //////////////
    // Airdrop
    //////////////

    function claimAirdrop() public {

    require(isAirdropActive, "Airdrop is inactive");
    require(!isClaimedAirdrop(msg.sender) , "Address already cliam airdrop");
    require(isAddressInAirdropWhitelist(msg.sender), "You need to be whitelisted to mint in the airdop round");

        uint256 startTokenId = _currentIndex;
        uint8 quantity = 1;
        require(totalMinted() + quantity <= maxSupply, "Cannot mint more than maximum supply");

        _safeMint(msg.sender, quantity);

        removeWhitelistAirdrop(msg.sender);

        if (whitelistAddressesAirdrop.length < 0) {
        _isAirdropNFTsMinted = true;
        }

        emit ClaimedAirdropNFT(msg.sender, startTokenId);
    }

    function setAirdropActive(bool _state) public onlyOwner {
        isAirdropActive = _state;
    }
 
    function setAirdropWhitelistAddress(address[] calldata _addresses) external onlyOwner {
        require(_addresses.length <= airdropNFTsCount, "Invalid count address");
        airdropWhitelistAddresses = _addresses;
    }

    function countAirdropWhitelistAddress() public view returns (uint256) {
        return airdropWhitelistAddresses.length;
    }


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


    //////////////
    // URI
    //////////////
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function setNotRevealedURI(string memory uri_) public onlyOwner {
        notRevealedURI = uri_;
    }


    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();

        if (!revealed)
            return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, Strings.toString(tokenId),baseExtension)) : '';
        if (disableRandomMint) {
            return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, Strings.toString(tokenId),baseExtension)) : '';
        } else {
            return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, Strings.toString(_tokenURIKeys[tokenId]),baseExtension)) : '';
        }
    }

    //////////////
    // phase whitelist 
    //////////////


    function isWhiteList(
        address _address ,  
        bytes32[] calldata _merkleProof ,
        uint _phaseNum
    ) public view returns(bool){
        return   LibSalePhase.isWhitelist( _address , _merkleProof , _phaseNum);

    }

    function setWhitelist(
        bytes32  _merkleRoot,
        uint _phaseNum
    ) public onlyOwner{
        LibSalePhase.setWhitelist(  _merkleRoot , _phaseNum);
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


    /////////////////
    // Public Views
    /////////////////
    function totalMinted() public view returns (uint256) {
        return _totalMinted();
    }

    ///////////////
    //  int transection
    ///////////////
    function  getPhaseTotalMint(uint numPhase_) public  view  returns(uint){
       return LibSalePhase.getPhaseTotalMint(numPhase_);
    }

    function getMintAvailableAddress(address address_)  public  view returns(uint){ 
        return LibSalePhase.getMintAvailableAddress(address_);
    }


  function  _afterTokenTransfers(address from, address to, uint256 tokenId,uint256 quantity) internal override {
       super._afterTokenTransfers( from ,to, tokenId,quantity);
      
        // mapping(address => mapping(uint => uint[])) public mintTransection;  
        uint mintCount  =  mintTransectionCount[to]+1;
        for(uint i = tokenId; i < tokenId+quantity; i++) {
               mintTransection[to][mintCount].push(i);
        }
         mintTransectionCount[to] = mintCount;

  }

  function getMintTransection(address user_ , uint index_) public view returns(uint[] memory){
       return    mintTransection[user_][index_];
  }

   function getLastedMintTransection(address user_) public view returns(uint[] memory){
        uint lastIndexMint =  mintTransectionCount[user_];
       return this.getMintTransection(user_ ,lastIndexMint);
  }


    function getBalance()  public  view  returns(uint) {
       return  address(this).balance;
    }


    // check claimed airdro aleady
 function isClaimedAirdrop(address _address)  public  view  returns(bool) {
         return claimedAirdropAddresses[_address];
 } 



function updateMaxSupply(uint _maxSupply , string calldata _baseUri ) external onlyOwner{
        require(_maxSupply > 0, "max supply should geater than 0");
            
        maxSupply = _maxSupply;
        _baseTokenURI =  _baseUri;
}



    ///////////////
    // Withdrawal
    ///////////////

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    /////////////
    // Fallback
    /////////////

    receive() external payable {
       emit Received(msg.sender, msg.value);
    }
}