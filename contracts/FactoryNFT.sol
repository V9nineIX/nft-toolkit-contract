// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface  ICloneContract {
    function initialize(
      bytes calldata initArg1,
      bytes calldata initArg2,
      address user
    ) external;
}


contract FactoryNFT is Ownable {
  
  address public addressERC721;
  address public addressERC1155;
 struct nft{
        address nftAddress;
  }
  mapping(address => nft[]) public addressMapping;

  event FactoryCreated(address clone);

  constructor() {
    
  }

  function setAddress721(address address_) public onlyOwner {
    addressERC721 = address_;
  }

  function setAddress1155(address address_) public onlyOwner {
    addressERC1155 = address_;
  }

  function cloneNFT(bytes calldata initArg1, bytes calldata initArg2 ,string memory tokenType) public {
      require(addressERC721 != address(0), "Not found clone");

      // bytes memory initArg3 = abi.encode(msg.sender);
      address templateContractAddress =  addressERC721;

      if( keccak256(abi.encodePacked((tokenType))) == keccak256(abi.encodePacked(("ERC1155"))) ){
           templateContractAddress =  addressERC1155;
      }

      require(templateContractAddress != address(0), "not found templete smart contract");

  
      address clone = ClonesUpgradeable.clone(templateContractAddress);
      ICloneContract(clone).initialize(initArg1, initArg2, msg.sender);

      addressMapping[msg.sender].push(nft(clone));
    
      emit FactoryCreated(clone);
  }


  function testCloneNFT(
      string memory name,
      string memory symbol,
      string memory baseURI, 
      string memory baseExtension, 
      string memory notRevealedURI,
      string memory tokenType,
      uint maxPublicSupply,
      uint maxSupply,
      uint state, 
      uint maxTokensPerAddress,
      uint price
  ) public {
      require(addressERC721 != address(0), "Not found clone");

      bool revealed = false;
      bool disableWhitelist = true;
      bytes memory initArg1 = abi.encode(name, symbol, baseURI, baseExtension, notRevealedURI, maxPublicSupply, maxSupply);
      bytes memory initArg2 = abi.encode(revealed, state, maxTokensPerAddress, price, disableWhitelist);

     address templateContractAddress =  addressERC721;

      if( keccak256(abi.encodePacked((tokenType))) == keccak256(abi.encodePacked(("ERC1155"))) ){
           templateContractAddress =  addressERC1155;
      }


     address clone = ClonesUpgradeable.clone(templateContractAddress);
     ICloneContract(clone).initialize(initArg1, initArg2, msg.sender);
    
     addressMapping[msg.sender].push(nft(clone));

     emit FactoryCreated(clone);
  }


  function getAllNftAddress(address owner_ ) public view returns(address[] memory){
       address[] memory mAddress = new address[](addressMapping[owner_].length);
      for(uint i = 0; i <  addressMapping[owner_].length; i++){
        mAddress[i] =  addressMapping[owner_][i].nftAddress;
      }
      return mAddress;
  }

  function getLastedNftAddress(address owner_) public view returns(address){
     uint lastedIndex = addressMapping[owner_].length-1;
     return  addressMapping[owner_][lastedIndex].nftAddress;

 }


   

}// end class
