// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Ownable.sol";
import "./Address.sol";
import "./Initializable.sol";
import "./ERC1155.sol";
import "./Strings.sol";
import "./Pausable.sol";
import "./LibSalePhase.sol";
import "./ERC2981.sol";
import "./operator_filter_registry/DefaultOperatorFilterer.sol";


/// @notice Items struct
struct Item {
  uint64 id;
  uint64 maxSupply;
  uint64 minted;
  uint64 supply;
  bool exist;
}


error ERC1155_Error404();
error ERC1155_BurnAmountExceedSupply();
error ERC1155_Paused();


contract Factory  is ERC1155, ERC2981, Initializable, Ownable, DefaultOperatorFilterer {

    using Strings for uint256;

    event MaxSupply_Change(uint64 id, uint64 maxSupply);

    /// @notice token tracker
    string public name;
    string public symbol;

    mapping(uint256 => Item) public items;
    uint256 public totalMinted;
    uint256 public maxMint;
    
    uint256[] internal _avialableTokenIdMints;


    constructor() ERC1155("") {
        
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     *      In this example the added modifier ensures that the operator is allowed by the OperatorFilterRegistry.
     */
    function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     *      In this example the added modifier ensures that the operator is allowed by the OperatorFilterRegistry.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, uint256 amount, bytes memory data)
        public
        override
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     *      In this example the added modifier ensures that the operator is allowed by the OperatorFilterRegistry.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override onlyAllowedOperator(from) {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }


    // Initiail
    function init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        name = name_;
        symbol = symbol_;
    }

    function addItemKeys(uint64[] memory keys, uint64[] memory amounts) public {
        require(keys.length == amounts.length, "keys and amounts length mismatch");

        for (uint i = 0; i < keys.length; i++) {
            addItem(keys[i], uint64(amounts[i]));
        }    
    }


    /// @notice add new item
    function addItem(uint64 id, uint64 maxSupply) internal {
        Item memory item = Item(id, maxSupply, 0, 0, true);
        items[id] = item;
        maxMint += maxSupply;

        _avialableTokenIdMints.push(id);
    }

    /// @notice edit item.uri  
    function editItemMaxSupply(uint64 id, uint64 maxSupply) external onlyOwner {
        require(totalMinted == 0, "Cannot edit because start minted!");
        if (!exists(id)) revert ERC1155_Error404();
        Item storage item = items[id];

        require(maxSupply > 0, "maxSupply cannot be zero");

        maxMint -= item.maxSupply;
        maxMint += maxSupply;

        item.maxSupply = maxSupply;
        emit MaxSupply_Change(id, maxSupply);
    }

    function mintableLeft() public view returns (uint256) {
        return maxMint - totalMinted;
    }

    /// @notice check if an item exists by id.
    function exists(uint256 id) public view returns (bool) {
        if (items[id].exist) {        
            return true;
        }
        return false;
    }

    /// @notice item's uri by id
    // function uri(uint256 id) public view virtual override returns (string memory) {
    //     if (!exists(id)) revert ERC1155_Error404();

    //     string memory baseURI = super.uri(0);
    //     return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, id.toString())) : "";
    // }

    /// @notice item's supply by id.
    function totalSupply(uint256 id) public view returns (uint256) {
        if (!exists(id)) revert ERC1155_Error404();
        return items[id].supply;
    }


    /* -------------------------------------------------------------------------- */
    /*                         Supply & Permission                                */
    /* -------------------------------------------------------------------------- */

    /**
    * @dev See {IERC1155-isApprovedForAll}. Allow controllers
    */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return super.isApprovedForAll(account, operator);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        // mint -> increase supply
        if (from == address(0)) {
            for (uint256 i; i < ids.length; ++i) {
                Item storage item = items[ids[i]];
                items[ids[i]].supply = item.supply + uint64(amounts[i]);

                totalMinted += amounts[i];
            }
        }

        // burn -> decrease supply
        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                Item storage item = items[ids[i]];
                uint64 amount = uint64(amounts[i]);
                if (amount > item.supply) revert ERC1155_BurnAmountExceedSupply();
                unchecked {
                    items[ids[i]].supply -= uint64(amount);
                }
            }
        }
    }
}

contract Ko1155 is Factory, Pausable {

    using Strings for uint256;

    event Received(address, uint);
    event Revealed();

    //////////////
    // Internal
    //////////////

    string private _baseURIExtended;


    mapping(uint256 => uint8) private _nonces;

    uint8 public maxMintPerTX = 100;


    /////////////////////
    // Public Variables
    /////////////////////
    bool public revealed = true;
    string public notRevealedURI;
    string public  baseExtension =".json";


    mapping(address => bool) public isWhitelisted;
    uint64[] private _nums;

    mapping(address => uint) public  mintTransectionCount;
    mapping(address => mapping(uint => uint[])) public mintTransection;



    event TotalMint(
        uint phaseNum , 
        uint phaseMintCount ,
        uint availablePerWallet,
        uint totalSupply);


    constructor(string memory uri_) {
        // uint64[] memory keys = new uint64[](2);
        // uint64[] memory quantitys = new uint64[](2);

        // keys[0] = 0;
        // keys[1] = 1;
        // quantitys[0] = 10;
        // quantitys[1] = 10;

        // addItemKeys(keys, quantitys);
    }

    function initialize(bytes calldata initArg1, bytes calldata initArg2, address owner) public initializer {
        (
            string memory name_,
            string memory symbol_,
            string memory baseURI_,
            string memory notRevealedURI_,
            uint maxPublicSupply_,
            uint maxTokensPerAddress_
        ) = abi.decode(
            initArg1,
            (
                string,
                string,
                string,
                string,
                uint,
                uint
            )
        );

        (
            bool revealed_,
            uint price_,
            uint64[] memory keys,
            uint64[] memory amounts,
            bool disableOperatorFilter_,
            bytes32  merkleRoot_
        ) = abi.decode( initArg2,
            (
                bool,
                uint,
                uint64[],
                uint64[],
                bool,
                bytes32 
            )
        );
    
        init_unchained(name_, symbol_);
        _setURI(baseURI_);
        baseExtension =".json";
        notRevealedURI = notRevealedURI_;
        revealed = revealed_;
        maxMintPerTX = 100;
        _transferOwnership(owner);
        setDisableOperatorFilter(disableOperatorFilter_);
        addItemKeys(keys, amounts);

        //TODO: create defualt
        this.addPhase(
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
    function reveal() public onlyOwner {
        revealed = true;
        emit Revealed();
    }

    function setBaseURI(string memory baseURI) external onlyOwner {
        _setURI(baseURI);
    }

    function setNotRevealedURI(string memory uri_) external onlyOwner {
        notRevealedURI = uri_;
    }

    function uri(uint256 id) public view  override returns (string memory) {
        if (!revealed) {
            return notRevealedURI;  
        } else {
         string memory baseURI = super.uri(0);
         return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, id.toString() ,baseExtension)) : "";
        }
    }

    function setMaxMintPerTX(uint8 amounts) external onlyOwner {
        maxMintPerTX = amounts;
    }

    function setDisableOperatorFilter(bool disable_) public onlyOwner {
        disableOperatorFilter = disable_;
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

    ) external {
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

    ) external {
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

    function setActiveState(uint64 activeState_) external {
         LibSalePhase.setActiveState(activeState_);
    }

    function getActivePhase()  public  view  returns(  LibSalePhase.PhaseSettings memory ){
       return   LibSalePhase.getActivePhase();
    } 


    function  setPhaseStatus(uint phaseNum_ , uint status_) external {
        LibSalePhase.setPhaseStatus(phaseNum_ , status_);
    }

    
    ///////////////
    // Mint
    ///////////////
    function mint(uint256 amount) external payable whenNotPaused {
        LibSalePhase.PhaseSettings memory currentPhase =  LibSalePhase.getActivePhase();
    
        require(currentPhase.status ==  LibSalePhase.STATE.START , "Sale Phase not start." );
        require(amount > 0, "Amount cannot be zero");
        // require(LibSalePhase.isWhitelist(msg.sender, currentPhase.phaseNum), "You need to be whitelisted to mint in this phase");
        require(amount <= mintableLeft(), "Not enough key left to mint.");
        require(amount <= maxMintPerTX, "You have reached maximum mint per transition");
        require(LibSalePhase.getMintAvailableAddress(msg.sender) >= amount, "Max tokens per address exceeded for this wave");
        require(currentPhase.maxSupply - currentPhase.amountMinted >= amount, "Not enough key left to mint.");

        uint256 cost =  amount * currentPhase.price;

        require(msg.value == cost, "Unmatched ether balance");

        mint(msg.sender, amount);

        LibSalePhase.setAmountMintedPhase(currentPhase.phaseNum  ,amount ,msg.sender);
    

         emit TotalMint( currentPhase.phaseNum,
                         LibSalePhase.getPhaseTotalMint(currentPhase.phaseNum),
                         LibSalePhase.getMintAvailableAddress(msg.sender),
                         mintableLeft()
                         );

    }

    function mint(address to, uint256 amount) internal virtual {

        uint mintCount  =  mintTransectionCount[to]+1;
        for (uint i = 0; i < amount; i++) {
            uint256 tokenId = takeTokenIdRandom(i);
            _mint(to, tokenId, 1, bytes(""));
            //TODO: log mint transection
               mintTransection[to][mintCount].push(tokenId);
        }
        mintTransectionCount[to] = mintCount;
    
    }

    function takeTokenIdRandom(uint indexLoop) private returns (uint256) {
        require(mintableLeft() > 0, "Not enough key left to pick.");

        uint256 randomNum = uint256(
            keccak256(
                abi.encode(
                    address(this),
                    block.number,
                    block.timestamp,
                    block.difficulty,
                    tx.gasprice,
                    _avialableTokenIdMints.length,
                    indexLoop
                )
            )
        );

        uint256 index = randomNum % _avialableTokenIdMints.length;
        uint256 tokenId = _avialableTokenIdMints[index];

        unchecked {
            Item storage item = items[tokenId];
            item.minted++;
            if (item.minted >= item.maxSupply) {
                _avialableTokenIdMints[index] = _avialableTokenIdMints[_avialableTokenIdMints.length - 1];
                _avialableTokenIdMints.pop();
            }
        }

        return tokenId;
    }


    ///////////////
    // Whitelist
    ///////////////
    function addWhitelist(address[] calldata users, uint phaseNum) public onlyOwner {
        // LibSalePhase.addWhitelist(users, phaseNum);
    }
  
    function unWhitelist(address[] calldata users, uint phaseNum) public onlyOwner {
        LibSalePhase.unWhitelist(users, phaseNum);
    }


    ///////////////
    // Withdrawal
    ///////////////

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function getBalance() public view returns(uint256) {
       return address(this).balance;
    }


    ///////////////
    //  int transection
    ///////////////

  function getMintTransection(address user_ , uint index_) public view returns(uint[] memory){
       return    mintTransection[user_][index_];
  }

   function getLastedMintTransection(address user_) public view returns(uint[] memory){
        uint lastIndexMint =  mintTransectionCount[user_];
       return getMintTransection(user_ ,lastIndexMint);
  }

  function maxSupply() public view returns(uint){
    return maxMint;
  }


 function  getPhaseTotalMint(uint numPhase_) public  view  returns(uint){
       return   LibSalePhase.getPhaseTotalMint(numPhase_);
   }


function getMintAvailableAddress(
     address address_
  )  public  view returns(uint){ 
    return   LibSalePhase.getMintAvailableAddress(address_);

  }




    /////////////
    // Fallback
    /////////////

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

}