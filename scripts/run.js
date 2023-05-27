// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { ethers , waffle} = require("hardhat");
const hre = require("hardhat");
const { MerkleTree } = require('merkletreejs')
const KECCAK256 = require('keccak256')

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy

  await run('compile');


//   const HelloWorld = await ethers.getContractFactory("HelloWorld");
//   const hello_world = await HelloWorld.deploy("Hello World!");

//   await hello_world.deployed()
//   console.log(" hello world Contract deployed to address:", hello_world.address);
//  console.log("Greeter deployed to:", greeter.address);
// deploy factory  contarct 




const Lib = await ethers.getContractFactory("LibSalePhase");
const lib = await Lib.deploy();
await lib.deployed()


  console.log("lib  deployed to address:",lib.address);

//   const erc721Contract    = await ethers.getContractFactory("Template721ARandom" ,
//    {
//     libraries: {
//         LibSalePhase: lib.address,
//     },
//   });
//   const erc721_nft = await  erc721Contract.deploy();

//   await  erc721_nft.deployed()

//   console.log("ERC721 NFT Contract deployed to address:", erc721_nft.address);






const erc721Contract   = await ethers.getContractFactory("HappyMelodyCloset" ,
{
 libraries: {
     LibSalePhase: lib.address,
 },
});



// const generateAddresses = async () => {
//     const numAddresses = 10000;
//     const walletPromises = [];
  
//     for (let i = 0; i < numAddresses; i++) {
//       const wallet = ethers.Wallet.createRandom();
//       walletPromises.push(wallet.getAddress());
//     }
  
//     const addresses = await Promise.all(walletPromises);
//     return addresses;
//   }

//   const addresses  =   await  generateAddresses()
//   addresses.push('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266')

//   console.log("addresss" ,addresses)


const addresses = [
    '0xEE0b356B07c57491b1F5B22Ab773F50D0761b100',
    '0x1Ef783A063bbF0c62887E256bfEcC6dF93e14164',
    '0xE72785921778Ec0004161BBDd5A160B1Ad5947F4',
    '0x59806fddA0300CB31D5620C9cD49D4757C14f221',
    '0x3243aD4099af28b77a3aB24c66d98D68AdeB6984',
    '0xA9bd3F876E2153603bbc871dD566034774c370b5',
    '0x7bBc228012689c5E1CC0D1175458B10fCA6cE063',
    '0xc2eAdacB575BBdD4A434b8DB44477A678D60EE69',
    '0x49af09BEB384739719Ab9a89F8C92A9c85dc84e3',
    '0x3Bb63438736e7930B8148f73E402f1807f93e53d',
    '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266'
    ]





// const leaves = addresses.map(x => KECCAK256(x));
// const tree = new MerkleTree(leaves, KECCAK256, { sort: true })

// const buf2hex = x => '0x' + x.toString('hex')


// console.log("tree" , tree.toString())

// const root = buf2hex(tree.getRoot())

// console.log("root", root)


// let leaf = buf2hex(KECCAK256('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266'));
// let proof = tree.getProof(leaf).map(x => buf2hex(x.data));

// console.log("proof" , proof )


// const mockproof = [
//     '0xe974313b6a9cef04318240993325448aea1f2e96d8e4fb6077169d6d92e7b53d',
//     '0x98cc78ade3a3e3cfab54d1046e065eb4ca1cd8ec200fcbb73d8d3127c9f2feb0',
//     '0x226395b163c33bcc6a3fe88aa49abb26b2fce89aad86c36d00a7285d4bd2b392',
//     '0x0fd631af76f1de3c66e5f85216e72019e352aef8eb92bf69bedb52bd9f0b6946',
//     '0xc9a46334dd555a14879bfd1ed8cbe4f7c70679a79a1ea7f210c62c64e751aacb',
//     '0xbc0275e60f8232e24cd715fdd28896e03928cd8fdf946c898e18238231240fb2',
//     '0x7d54ae4dd1e78be962075a6a05633e06e8fb124339458663968752e25824d70a',
//     '0x330f6d57e2f4cc43c92e5429dc631518813c7a80e374c1b902e3b9fd4fe3b7eb',
//     '0x47acc94b63fa20b668d63a43d42da4e9cef59a05f9b6988e2d3596fc78cc177a',
//     '0xb60766cd39ed2092294238862b90be5215daeb5428e90b884ee4f4c4ea799de9',
//     '0xadc1ecf77d51e3512fe42e542a4b9f2f7e9207992ecc31095ce3d42c121e4aa6',
//     '0xe39dde856cc560bcfb0f0888a91ad38a1356265cd2de9795dcfdaa1603c32b24'
//   ]



const provider = waffle.provider;
const balance0ETHint = await provider.getBalance("0x70997970C51812dc3A010C7d01b50e0d17dc79C8");
 const initBA = ethers.utils.formatEther(balance0ETHint  )

  console.log("artist balance" , initBA )


// const erc721_nft = await  erc721Contract.deploy();

const pricehexValue = ethers.utils.parseUnits("0.02", 18)
const PRICE = pricehexValue.toString()


const happyMelodyContract  = await ethers.getContractFactory("HappyMelody" ,
{
 libraries: {
     LibSalePhase: lib.address,
 },
});


  const happyMelody_nft   =  await happyMelodyContract.deploy(
   "https://sleepy-hev-api.onepirate.finance/folder/579a260e-91f8-49d5-a034-012819fb3267-Happy-closet/build/json/",
    PRICE ,
    "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
  )

  await  happyMelody_nft.deployed()
  console.log("happyMelody Contract deployed to address:",  happyMelody_nft.address);



const erc721_nft = await  erc721Contract.deploy(
    "https://sleepy-hev-api.onepirate.finance/folder/579a260e-91f8-49d5-a034-012819fb3267-Happy-closet/build/json/",
    PRICE,
    happyMelody_nft.address
);

const setCharacterContactAddressTX = await  erc721_nft.setCharacterContactAddress(happyMelody_nft.address);




  await  erc721_nft.deployed()

  console.log("ERC721 NFT Contract deployed to address:", erc721_nft.address);

   
//   await erc721_nft.setMerkleRoot("0x0000000000000000000000000000000000000000000000000000000000000000")

//   const setMaxSupply = await erc721_nft.setMaxSupply(99)

// const event = checkMerkleProofStatus.events.MerkleProofVerified;
// const isProofValid = event.returnValues.isValid;

// console.log(`Merkle proof verification result: ${isProofValid}`);

  const max  =  await  erc721_nft.maxSupply()
  console.log("max supply", max)




//   const balance  =  await  erc721_nft.getBalance()
//   console.log("balance" ,balance)



   //team mint


//    const mintTeamNFTsTx         = await  erc721_nft.mintTeamNFTs() 
//    const receiptmintTeamNFTsTx  = await  mintTeamNFTsTx.wait()

//    for (const event of receiptmintTeamNFTsTx.events) {
//        console.log(`Event ${event.event} with args ${event.args}`);
//    }
  

// const erc1555Contract    = await ethers.getContractFactory("Ko1155" ,
// {
//  libraries: {
//      LibSalePhase: lib.address,
//  },
// });
// const erc155_nft = await  erc1555Contract.deploy('');
// console.log("ERC1155 NFT Contract deployed to address:", erc155_nft.address);
// await  erc155_nft.deployed()


// await erc155_nft.addItemKeys([1,2,3,4,5], [10,10,10,5,1])

// const maxMintPerTX =  await erc155_nft.setBaseURI("ipfs://QmcYEtN6ua3isahyeNSzDDKvmvN7QNFb2Pm6MqaUfYow5e/")
// console.log("maxMintPerTX" ,  maxMintPerTX)


 const hexValue = ethers.utils.parseUnits("0.02", 18)
 const WEI_VALUE = hexValue.toString()
  
  await erc721_nft.addPhase(
	"public",
	 100,
	 100,
     "0x0000000000000000000000000000000000000000000000000000000000000000",
	 true,
     WEI_VALUE
  )



//   const isWhiteList = await erc721_nft.isWhiteList(
//      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
//      [],
//      1
//   )

//   console.log(" isWhiteList " , isWhiteList )


//   await erc721_nft.setUseReserveForTeam(false)
//   const useReserveForTeam  = await erc721_nft.useReserveForTeam()
 // const isTeamNFTMint = await erc721_nft._isTeamNFTsMinted()

//   console.log( " useReserveForTeam ",  useReserveForTeam  )
   //console.log( " isTeamNFTMint ",  isTeamNFTMint  )

//   await erc721_nft.addPhase(
// 	"private",
// 	 100,
// 	 10,
// 	 "0x6173647361647361647361647361646173647361640000000000000000000000",
// 	 true,
//      WEI_VALUE
//   )


    
 const  res =  await   erc721_nft.setPhaseStatus(1, 1)
 // console.log("set phase",  res)
  //const  tx =    await  erc155_nft.mint(1 ,{ value: ethers.utils.parseEther("0.005")})

// //  const  tx2 =    await  erc155_nft.mint(2 ,{ value: ethers.utils.parseEther("0.01")})
// //   //console.log("res" , res)
   


   const  tx  =   await  erc721_nft.mint(
      1 ,
      [],
    { value: ethers.utils.parseEther("0.02")})
// //  const  tx2  =   await  erc721_nft.mint(1 ,{ value: ethers.utils.parseEther("0.005")})
// //   const  tx3  =   await  erc721_nft.mint(1 ,{ value: ethers.utils.parseEther("0.005")})
   
// // // Mock

//    const  burnTx  = await  erc721_nft.burn(0);
//    console.log("burnTx" , burnTx)

//    const  receiptTxBurn = 
   
//    for (const event of receipt.events) {
//      console.log(`Event ${event.event} with args ${event.args}`);
//    }
   

  

// //   await erc721_nft.setBaseURI("ipfs://QmcYEtN6ua3isahyeNSzDDKvmvN7QNFb2Pm6MqaUfYow5e/", ".json")

  const receipt = await tx.wait()
  for (const event of receipt.events) {
    console.log(`Event ${event.event} with args ${event.args}`);
  }

  const  lastTx1 = await erc721_nft.getLastedMintTransection("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
  console.log("lastTx" , lastTx1)



//   const resBL =  await erc721_nft.balanceOf('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266')
//   console.log("resBL", resBL)
 
  

 const  availble =  await  erc721_nft.getMintAvailableAddress("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
  console.log("MintAvailableAddres",availble)


//   await erc721_nft.setAirdropActive(true)

 const setWhiteList  = await erc721_nft.addAirdropWhitelistAddresses(
    [

        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
        "0x60cc1b0a3543307acf398fc01676458555c4c62c",
        "0x60cc1b0a3543307acf398fc01676458555c4c62c",
        "0x60cc1b0a3543307acf398fc01676458555c4c62c",
        "0x60cc1b0a3543307acf398fc01676458555c4c62c",

    ])

  const  whitelistAddressesAirdrop = await erc721_nft.getWhitelistAddressesAirdrop()
//   console.log("whitelistAddressesAirdrop" ,whitelistAddressesAirdrop)

//   const whiteListIndex  = await erc721_nft.getWhitelistAddressesAirdropIndex("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")

//   console.log("whiteListIndex ",  whiteListIndex )

//   const whiteListIndex2c  = await erc721_nft.whitelistAddressesAirdropIndex("0x60cc1b0a3543307acf398fc01676458555c4c62c")
//   console.log("whiteListIndex2",  whiteListIndex2)


   const removeWhite  =  await erc721_nft.removeWhitelistAirdropByOwner("0x60cc1b0a3543307acf398fc01676458555c4c62c")
   

//    const removeWhite2  =  await erc721_nft.removeWhitelistAirdrop("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
   
//   const removeWhite3  =  await erc721_nft.removeWhitelistAirdrop("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
   
   const  isClaimedAirdrop  = await erc721_nft.isClaimedAirdrop("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
   console.log("isClaimedAirdrop",isClaimedAirdrop)
//   const removeWhite4  =  await erc721_nft.removeWhitelistAirdrop("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
   

//   console.log("removeWhite ",  removeWhite )

//   const whiteListIndex2  = await erc721_nft.whitelistAddressesAirdropIndex("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")

//   console.log("whiteListIndex ",  whiteListIndex2 )





//  const AfterwhiteListIndex  = await erc721_nft.whitelistAddressesAirdropIndex("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")

//  console.log("after whiteListIndex ",   AfterwhiteListIndex )

//  const removeWhite2  =  await erc721_nft.removeWhitelistAirdrop("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
//  const removeWhite3  =  await erc721_nft.removeWhitelistAirdrop("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
//  const removeWhite4  =  await erc721_nft.removeWhitelistAirdrop("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
//  const removeWhite5  =  await erc721_nft.removeWhitelistAirdrop("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")


//   const  isAddressInAirdropWhitelist   =  await  erc721_nft.isAddressInAirdropWhitelist("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
//    console.log("isAddressInAirdropWhitelist", isAddressInAirdropWhitelist)
 const setAirDropActive  = await erc721_nft.setAirdropActive(true)
 const  isAirdropActive  = await erc721_nft.isAirdropActive()
 console.log("isAirdropActive", isAirdropActive)

const  cliamAirDropStatusTX  =  await erc721_nft.claimAirdrop()
console.log("cliamAirDropStatus")

 const  claimAirdropTXreceipt = await cliamAirDropStatusTX.wait()
 for (const event of claimAirdropTXreceipt.events) {
 console.log(`Event ${event.event} with args ${event.args}`);
 }


//  const  isAddressInAirdrop =    await erc721_nft.isAddressInAirdropWhitelist("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
//  console.log("isAddressInAirdrop",isAddressInAirdrop)


 

//  const  whitelistAddressesAirdrop2 = await erc721_nft.getWhitelistAddressesAirdrop()
//  console.log("whitelistAddressesAirdrop" ,whitelistAddressesAirdrop2)



 await erc721_nft.setDisableOperatorFilter(true)

  

 const  contractBalance =   await erc721_nft.getBalance()
 console.log("contractBalance" ,  ethers.utils.formatEther( contractBalance))


 const currentArtistBalance = await provider.getBalance("0x70997970C51812dc3A010C7d01b50e0d17dc79C8");
 const currentArtistBalanceETH  = ethers.utils.formatEther(currentArtistBalance)
 console.log("currentArtistBalanceETH ",currentArtistBalanceETH )

 const  withdarwStatus  =  await erc721_nft.withdraw();
 const currentOwnerBalance = await provider.getBalance("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
 console.log("currentOwnerBalanceETH ", ethers.utils.formatEther(currentOwnerBalance))


  await happyMelody_nft.setPhaseStatus(1,1)
  await happyMelody_nft.mint(
    1 ,
    [],
  { value: ethers.utils.parseEther("0.02")})

    const  isOwnerCharecter  =  await  erc721_nft.isOwnerOfCharacter(0 , "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
    console.log("isOwnerCharecter" , isOwnerCharecter )

  const setTokenResultTx =  await erc721_nft.setUseToken(0, 0)
  const setTokenResultreceipt = await setTokenResultTx.wait();

//   for (const event of  setTokenResultreceipt.events) {
//       console.log(`Event ${event.event} with args ${event.args}`);
//    }


    const  isUseToken = await erc721_nft.isUseToken(0)
    console.log("isUseToken" ,isUseToken)
    const tokenURI = await erc721_nft.tokenURI(0)
    console.log("tokenURI" ,tokenURI)

    // const  tranferFormTX  =  await erc721_nft.transferFrom( "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
    //                                                         "0x70997970C51812dc3A010C7d01b50e0d17dc79C8" ,
    //                                                         0) 


    //console.log("tranferFormTX " , tranferFormTX )
  
 
   

  



//  const  isClaimedAirdrop  =  await erc721_nft.isClaimedAirdrop("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
//  console.log("isClaimedAirdrop", isClaimedAirdrop)
 
//  const  totalSupply =   await erc721_nft.totalSupply()
//  console.log(" totalSupply" , totalSupply)

// //  await erc721_nft.claimAirdropNFTs()

// const  token = await erc721_nft.tokenURI(0)
// console.log("Token", token)


// const balance0ETH = await provider.getBalance("0x70997970C51812dc3A010C7d01b50e0d17dc79C8");
  
//  const  bla = ethers.utils.formatEther(balance0ETH  )
//  console.log("balance0ETH ", initBA , bla  )

 


//   const  setAripDropWhiteList  =  await erc721_nft.addAirdropWhitelistAddresses(
//     ["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"]
//     )
// //   console.log("setAripDropWhiteList ",setAripDropWhiteList)


//     const  claimAirdopTx =   await erc721_nft.claimAirdrop()
//     // console.log("claimAirdop ", claimAirdop)

//     const receiptClaimAirdopTx  = await claimAirdopTx.wait()

//     for (const event of receiptClaimAirdopTx.events) {
//         console.log(`Event ${event.event} with args ${event.args}`);
//       }


//     const  lastTx = await erc721_nft.getLastedMintTransection("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
//     console.log("lastTx" , lastTx)



//      const isClaimedAirDrop  =  await  erc721_nft.isClaimedAirdrop("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
//      console.log("isClaimedAirDrop" , isClaimedAirDrop)


//    const mintTx = await erc155_nft.getLastedMintTransection("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
//    const tokenId  =  ethers.utils.formatUnits(mintTx[0], 0)
//    console.log("mintTx" ,  tokenId  )


//     const tokenUrl = await erc155_nft.uri(tokenId)
//     console.log("tokenUrl", tokenUrl)


//     const remian =    await erc155_nft.mintableLeft()
//     console.log("remain" , remian)


//     const max  =  await erc155_nft.maxSupply()
//     console.log("max" , max)


//     const phasetotalMint  =  await erc155_nft.getPhaseTotalMint(1)
//     console.log("phasetotalMint" ,phasetotalMint)


//     const mintAvalible  =  await erc155_nft.getMintAvailableAddress("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
//     console.log(" mintAvalible " , mintAvalible )



//  const  res2  =  await  erc721_nft.getAllPhase();
//  console.log(res2)


//   const factoryNFTContarct = await ethers.getContractFactory("FactoryNFT");
//   const factory_nft = await factoryNFTContarct.deploy();
//   await factory_nft.deployed()
//   console.log("Factory NFT Contract deployed to address:", factory_nft.address);
//   await factory_nft.setAddress721( factory_nft.address)


///verify  smart contract

//   await hre.run("verify:verify", {
//     address:  lib.address,
//     contract: "contracts/LibSalePhase.sol:LibSalePhase", //Filename.sol:ClassName
//     constructorArguments: [],
//   });


//   await hre.run("verify:verify", {
//     address: erc721_nft.address,
//     contract: "contracts/NFT_Template_721A.sol:Template721A", //Filename.sol:ClassName
//     constructorArguments: ['',''],
//   });


// await erc155_nft.deployTransaction.wait(5);

//   await hre.run("verify:verify", {
//     address:  erc155_nft.address,
//     contract: "contracts/Ko1155.sol:Ko1155", //Filename.sol:ClassName
//     constructorArguments: ['']
//   });


} // endmain

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
